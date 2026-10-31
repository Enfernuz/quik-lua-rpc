# Windows build for QUIK 12.x

This build replaces the 2021 Docker/SCons package. It stops QUIK 12.8 from crashing with heap corruption (`0xC0000374`) while quik-lua-rpc serves requests. [THREADING.md](../THREADING.md) explains why.

| | 2021 package (`built/archive/`) | QUIK 12 package (`built/quik_lua_rpc_quik12/`) |
|---|---|---|
| `lzmq.dll` | linked to the bundled `liblua.dll` | linked to QUIK's `lua53.dll` |
| `pb.dll` | linked to QUIK 9.2's `lua53.dll` | linked to QUIK 12.8's `lua53.dll` |
| `liblua.dll` | shipped | not shipped, must be removed |
| `libzmq.dll`, `libsodium-23.dll`, `libgcc_s_seh-1.dll`, `libstdc++-6.dll` | 2021 | same files, unchanged |
| `service.lua`, `main.lua` | PUB socket used from QUIK callbacks | callbacks only queue events; `main()` sends them |

## Build

Needs [w64devkit](https://github.com/skeeto/w64devkit) 2.10.0 (GCC 16.2) on `PATH`, plus git and curl (Git for Windows has both).

```sh
PATH=/path/to/w64devkit/bin:$PATH sh win-build/build.sh
```

The script fetches pinned sources: Lua 5.3.6 headers, lzmq `210609b`, lua-protobuf 0.3.2 and libzmq 4.2.5 `zmq.h`. It writes the package with `SHA256SUMS` and fails if a module does not import `lua53.dll`.

## Test

```sh
LUA_INC=win-build/work/lua-5.3.6/src sh win-build/test/run.sh built/quik_lua_rpc_quik12 /tmp/run 60 500 1 "$CLIENT_CP" sub
```

The arguments are: package, work dir, seconds, callbacks per second, client sockets, the client classpath, and optionally `sub` to also read the PUB stream. A good run ends with `quikemu exit code: 0x00000000` and `loadgen RESULT: ... failed=0`.

The client classpath (`;`-separated) holds JeroMQ 0.5 (with jnacl), the protobuf 3.x Java runtime (`protobuf-java` or `protobuf-javalite`) and the Java classes generated from `qlua/rpc/*.proto`. To build them with `protoc` 3.x (tested with 3.18.1):

```sh
protoc -I . --java_out=lite:/tmp/qlua-src qlua/rpc/*.proto qlua/rpc/*/*.proto
javac -cp protobuf-java.jar -d /tmp/qlua-classes $(find /tmp/qlua-src -name '*.java')
CLIENT_CP="/tmp/qlua-classes;jeromq.jar;jnacl.jar;protobuf-java.jar"
```

On Windows, pass `protoc`, `javac` and `java` Windows-style paths (`cygpath -w`).

## Install on a QUIK machine

1. Stop the quik-lua-rpc script and close QUIK. QUIK keeps the DLLs locked while it runs.
2. Back up the QUIK folder's `liblua.dll`, `lzmq.dll`, `pb.dll` and `lua\quik-lua-rpc\`.
3. Copy `lzmq.dll` and `pb.dll` from the package into the QUIK folder, replacing the old ones.
4. Delete or rename `liblua.dll` in the QUIK folder.
5. Copy `lua\quik-lua-rpc\` from the package over the installed one. **Keep the existing `config.json`**: the package only has `config.json.example`.
6. `lua\lzmq\`, `lua\lua-protobuf\`, `libzmq.dll` and the other runtime DLLs are unchanged and can stay.
7. Start QUIK and the script. Check that the QUIK message window shows no errors and that the RPC port answers.

The script must run under Lua 5.3, which QUIK uses unless the script is set to 5.4.

## Roll back (plan B)

Close QUIK. Put the backed-up `liblua.dll`, `lzmq.dll`, `pb.dll` and `lua\quik-lua-rpc\*.lua` back, leaving `config.json` as it is, then start QUIK. The original 2021 release is in `built/archive/quik_lua_rpc-v2.0-alpha-2021-12.tar.xz`.
