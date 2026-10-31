/*
 * quikemu: a minimal stand-in for QUIK that runs quik-lua-rpc the way QUIK 12.8 does.
 *
 * - Uses QUIK's own lua53.dll and installs a lock through QLuaSetSynchronization,
 *   so every Lua API call is serialized, like in the terminal.
 * - Loads main.lua in the "terminal" thread, then runs main() in a separate script thread.
 * - Fires OnQuote / OnParam from the terminal thread while main() serves requests,
 *   which is where the real crashes happened.
 * - Stubs the handful of QLua functions an order-book client needs (getQuoteLevel2, getParamEx,
 *   ParamRequest).
 *
 * Usage: quikemu.exe <script dir> <seconds> <callbacks per second>
 * Exit code 0 means main() stopped cleanly after OnStop. A crash ends the process with the
 * exception code (for example 0xC0000374 for heap corruption).
 */
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

__declspec(dllimport) void QLuaSetSynchronization(void (*lock)(lua_State *), void (*unlock)(lua_State *));

static CRITICAL_SECTION lua_cs;
static void quik_lock(lua_State *L) { (void)L; EnterCriticalSection(&lua_cs); }
static void quik_unlock(lua_State *L) { (void)L; LeaveCriticalSection(&lua_cs); }

static char root_dir[MAX_PATH];
static char script_dir[MAX_PATH];
static volatile LONG script_done = 0;
static volatile LONG requests_served = 0;
static LARGE_INTEGER t0, freq;

static double now_s(void) {
    LARGE_INTEGER t;
    QueryPerformanceCounter(&t);
    return (double)(t.QuadPart - t0.QuadPart) / (double)freq.QuadPart;
}

static void slashes(char *s) {
    for (; *s; s++) if (*s == '\\') *s = '/';
}

/* ---- QLua stubs ---- */

static int q_message(lua_State *L) {
    printf("[%8.3f] message: %s\n", now_s(), luaL_optstring(L, 1, ""));
    fflush(stdout);
    return 0;
}

static int q_getScriptPath(lua_State *L) { lua_pushstring(L, script_dir); return 1; }
static int q_getWorkingFolder(lua_State *L) { lua_pushstring(L, root_dir); return 1; }
static int q_isConnected(lua_State *L) { lua_pushinteger(L, 1); return 1; }

static int q_getInfoParam(lua_State *L) {
    const char *name = luaL_checkstring(L, 1);
    lua_pushstring(L, strcmp(name, "VERSION") == 0 ? "12.8.0.6" : "");
    return 1;
}

static int q_sleep(lua_State *L) {
    Sleep((DWORD)luaL_checkinteger(L, 1));
    lua_pushinteger(L, 1);
    return 1;
}

static void push_levels(lua_State *L, const char *field, int count, int base, int step) {
    char buf[32];
    lua_createtable(L, count, 0);
    for (int i = 0; i < count; i++) {
        lua_createtable(L, 0, 2);
        snprintf(buf, sizeof buf, "%d.%02d", base + i * step, (i * 7) % 100);
        lua_pushstring(L, buf);
        lua_setfield(L, -2, "price");
        snprintf(buf, sizeof buf, "%d", 10 + (rand() % 5000));
        lua_pushstring(L, buf);
        lua_setfield(L, -2, "quantity");
        lua_rawseti(L, -2, i + 1);
    }
    lua_setfield(L, -2, field);
}

static int q_getQuoteLevel2(lua_State *L) {
    luaL_checkstring(L, 1);
    luaL_checkstring(L, 2);
    InterlockedIncrement(&requests_served);
    lua_createtable(L, 0, 4);
    lua_pushstring(L, "20");
    lua_setfield(L, -2, "bid_count");
    lua_pushstring(L, "20");
    lua_setfield(L, -2, "offer_count");
    push_levels(L, "bid", 20, 280, -1);
    push_levels(L, "offer", 20, 281, 1);
    return 1;
}

static int q_getParamEx(lua_State *L) {
    char buf[32];
    luaL_checkstring(L, 1);
    luaL_checkstring(L, 2);
    luaL_checkstring(L, 3);
    InterlockedIncrement(&requests_served);
    lua_createtable(L, 0, 4);
    lua_pushstring(L, "1");
    lua_setfield(L, -2, "param_type");
    snprintf(buf, sizeof buf, "%d.%02d", 250 + rand() % 50, rand() % 100);
    lua_pushstring(L, buf);
    lua_setfield(L, -2, "param_value");
    lua_pushstring(L, buf);
    lua_setfield(L, -2, "param_image");
    lua_pushstring(L, "1");
    lua_setfield(L, -2, "result");
    return 1;
}

static int q_true(lua_State *L) { lua_pushboolean(L, 1); return 1; }

static const char *prelude =
    "table.sinsert = table.insert\n"
    "table.sremove = table.remove\n"
    "QTABLE_INT_TYPE, QTABLE_DOUBLE_TYPE, QTABLE_INT64_TYPE = 1, 2, 3\n"
    "QTABLE_CACHED_STRING_TYPE, QTABLE_TIME_TYPE, QTABLE_DATE_TYPE, QTABLE_STRING_TYPE = 4, 5, 6, 7\n"
    "INTERVAL_TICK, INTERVAL_M1, INTERVAL_M2, INTERVAL_M3, INTERVAL_M4, INTERVAL_M5 = 0, 1, 2, 3, 4, 5\n"
    "INTERVAL_M6, INTERVAL_M10, INTERVAL_M15, INTERVAL_M20, INTERVAL_M30 = 6, 10, 15, 20, 30\n"
    "INTERVAL_H1, INTERVAL_H2, INTERVAL_H4, INTERVAL_D1, INTERVAL_W1, INTERVAL_MN1 = 60, 120, 240, 1440, 10080, 23200\n";

static void install_qlua(lua_State *L) {
    lua_register(L, "message", q_message);
    lua_register(L, "getScriptPath", q_getScriptPath);
    lua_register(L, "getWorkingFolder", q_getWorkingFolder);
    lua_register(L, "isConnected", q_isConnected);
    lua_register(L, "getInfoParam", q_getInfoParam);
    lua_register(L, "sleep", q_sleep);
    lua_register(L, "getQuoteLevel2", q_getQuoteLevel2);
    lua_register(L, "getParamEx", q_getParamEx);
    lua_register(L, "ParamRequest", q_true);
    lua_register(L, "CancelParamRequest", q_true);
    if (luaL_dostring(L, prelude) != LUA_OK) {
        fprintf(stderr, "prelude: %s\n", lua_tostring(L, -1));
        exit(2);
    }
    /* QUIK looks for modules in <QUIK>\lua and native modules next to info.exe. */
    lua_getglobal(L, "package");
    lua_pushfstring(L, "%s/lua/?.lua;%s/lua/?/init.lua", root_dir, root_dir);
    lua_setfield(L, -2, "path");
    lua_pushfstring(L, "%s/?.dll", root_dir);
    lua_setfield(L, -2, "cpath");
    lua_pop(L, 1);
}

/* ---- threads ---- */

static DWORD WINAPI script_thread(LPVOID arg) {
    lua_State *T = (lua_State *)arg;
    lua_getglobal(T, "main");
    if (lua_pcall(T, 0, 0, 0) != LUA_OK) {
        printf("[%8.3f] main() failed: %s\n", now_s(), lua_tostring(T, -1));
        lua_pop(T, 1);
    }
    InterlockedExchange(&script_done, 1);
    return 0;
}

static int fire(lua_State *L, const char *callback, const char *class_code, const char *sec_code) {
    lua_getglobal(L, callback);
    if (!lua_isfunction(L, -1)) {
        lua_pop(L, 1);
        return 0;
    }
    lua_pushstring(L, class_code);
    lua_pushstring(L, sec_code);
    if (lua_pcall(L, 2, 0, 0) != LUA_OK) {
        printf("[%8.3f] %s failed: %s\n", now_s(), callback, lua_tostring(L, -1));
        lua_pop(L, 1);
    }
    return 1;
}

static const char *securities[] = {
    "SBER", "GAZP", "LKOH", "GMKN", "NVTK", "ROSN", "TATN", "MGNT", "MTSS", "YDEX",
    "PLZL", "CHMF", "NLMK", "ALRS", "MOEX", "VTBR", "AFLT", "SNGS", "PHOR", "RUAL",
};

int main(int argc, char **argv) {
    if (argc < 4) {
        fprintf(stderr, "usage: quikemu <script dir> <seconds> <callbacks per second>\n");
        return 2;
    }
    QueryPerformanceFrequency(&freq);
    QueryPerformanceCounter(&t0);
    setvbuf(stdout, NULL, _IONBF, 0);

    GetModuleFileNameA(NULL, root_dir, MAX_PATH);
    *strrchr(root_dir, '\\') = '\0';
    slashes(root_dir);
    GetFullPathNameA(argv[1], MAX_PATH, script_dir, NULL);
    slashes(script_dir);
    double seconds = atof(argv[2]);
    int rate = atoi(argv[3]);

    InitializeCriticalSection(&lua_cs);
    QLuaSetSynchronization(quik_lock, quik_unlock);

    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    install_qlua(L);

    char main_lua[MAX_PATH + 16];
    snprintf(main_lua, sizeof main_lua, "%s/main.lua", script_dir);
    printf("[%8.3f] loading %s (%s)\n", now_s(), main_lua, LUA_RELEASE);
    if (luaL_dofile(L, main_lua) != LUA_OK) {
        printf("[%8.3f] main.lua failed: %s\n", now_s(), lua_tostring(L, -1));
        return 2;
    }

    lua_State *T = lua_newthread(L);
    luaL_ref(L, LUA_REGISTRYINDEX);
    HANDLE th = CreateThread(NULL, 0, script_thread, T, 0, NULL);
    printf("[%8.3f] main() started, firing OnQuote/OnParam at ~%d/s for %.0fs\n", now_s(), rate, seconds);

    long fired = 0;
    double next_report = 5.0;
    size_t nsec = sizeof securities / sizeof securities[0];
    while (now_s() < seconds && !script_done) {
        double target = now_s() * rate;
        while (fired < target) {
            const char *sec = securities[fired % nsec];
            fire(L, (fired & 1) ? "OnParam" : "OnQuote", "TQBR", sec);
            fired++;
        }
        if (now_s() >= next_report) {
            printf("[%8.3f] alive: %ld callbacks, %ld QLua calls from requests\n", now_s(), fired, requests_served);
            next_report += 5.0;
        }
        Sleep(1);
    }
    if (script_done) {
        printf("[%8.3f] RESULT: main() ended on its own\n", now_s());
        return 4;
    }

    printf("[%8.3f] calling OnStop\n", now_s());
    lua_getglobal(L, "OnStop");
    lua_pushinteger(L, 1);
    if (lua_pcall(L, 1, 1, 0) != LUA_OK) printf("OnStop failed: %s\n", lua_tostring(L, -1));
    lua_pop(L, 1);

    if (WaitForSingleObject(th, 10000) != WAIT_OBJECT_0) {
        printf("[%8.3f] RESULT: main() did not stop within 10s\n", now_s());
        return 3;
    }
    lua_close(L);
    printf("[%8.3f] RESULT: clean stop. %ld callbacks, %ld QLua calls from requests\n", now_s(), fired, requests_served);
    return 0;
}
