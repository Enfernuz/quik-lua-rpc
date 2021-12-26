#!/bin/sh
# Builds lzmq.dll and pb.dll for QUIK 12.x on Windows and assembles the install package.
#
# Unlike the 2021 Docker/SCons build, both modules link against QUIK's own lua53.dll
# (quik_redist/lua53.dll) and no separate liblua.dll is shipped. QUIK's lua53.dll locks
# every Lua API call (QLuaSetSynchronization), and a second Lua runtime skips that lock,
# which corrupted the heap when QUIK callbacks and main() ran at the same time.
# See THREADING.md.
#
# Requirements: w64devkit 2.10.0 (GCC 16.2) on PATH, plus git, curl and tar.
#   sh win-build/build.sh [work dir]
# Output: built/quik_lua_rpc_quik12/ (DLLs at the top, Lua code under lua/, like the QUIK folder).
set -eu

repo=$(cd "$(dirname "$0")/.." && pwd)
work=${1:-$repo/win-build/work}
out=$repo/built/quik_lua_rpc_quik12
old=$repo/built/quik_lua_rpc   # 2021 package: source of the unchanged libzmq / libsodium / mingw runtime DLLs

LUA_VERSION=5.3.6                                        # headers only; the code runs on QUIK's lua53.dll
LZMQ_COMMIT=210609b27c6955854a9f44e5b6df1ac8b06cc8f8     # zeromq/lzmq master, 2020-07-20 (same Lua files as the 2021 package)
PROTOBUF_COMMIT=9bff16eff2666bbcbfbc439b2a0b110ebfc85c32 # starwing/lua-protobuf 0.3.2 (same Lua files as the 2021 package)
LIBZMQ_TAG=v4.2.5                                        # zmq.h only; the 2021 libzmq.dll is reused

mkdir -p "$work"
cd "$work"

[ -d "lua-$LUA_VERSION" ] || { curl -fsSLO "https://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz"; tar -xzf "lua-$LUA_VERSION.tar.gz"; }
[ -d lzmq ] || git clone -q https://github.com/zeromq/lzmq
git -C lzmq checkout -q "$LZMQ_COMMIT"
[ -d lua-protobuf ] || git clone -q https://github.com/starwing/lua-protobuf
git -C lua-protobuf checkout -q "$PROTOBUF_COMMIT"
mkdir -p libzmq/include
[ -f libzmq/include/zmq.h ] || curl -fsSL -o libzmq/include/zmq.h "https://raw.githubusercontent.com/zeromq/libzmq/$LIBZMQ_TAG/include/zmq.h"

lua_inc=$work/lua-$LUA_VERSION/src
lua_dll=$repo/quik_redist/lua53.dll
cflags="-O2 -m64 -DLUA_BUILD_AS_DLL -static-libgcc"

rm -rf "$out"
mkdir -p "$out/lua"

gcc $cflags -shared -I"$lua_inc" lua-protobuf/pb.c "$lua_dll" -o "$out/pb.dll"
gcc $cflags -shared -DDLL_EXPORT -DFD_SETSIZE=16384 -DZMQ_USE_SELECT \
    -I"$lua_inc" -Ilibzmq/include lzmq/src/*.c "$lua_dll" "$old/libzmq.dll" -o "$out/lzmq.dll"

for f in libzmq.dll libsodium-23.dll libgcc_s_seh-1.dll libstdc++-6.dll; do cp "$old/$f" "$out/"; done

cp -r lzmq/src/lua/lzmq "$out/lua/lzmq"
mkdir -p "$out/lua/lua-protobuf"
cp lua-protobuf/*.lua "$out/lua/lua-protobuf/"
mkdir -p "$out/lua/quik-lua-rpc"
(cd "$repo" && cp -r auth impl json qlua utils main.lua service.lua curve_keypair_generator.lua "$out/lua/quik-lua-rpc/")
# Shipped as an example so an install never overwrites the live config.json.
cp "$repo/config.json" "$out/lua/quik-lua-rpc/config.json.example"

# The new modules must import QUIK's lua53.dll and nothing called liblua.
for f in pb.dll lzmq.dll; do
    imports=$(objdump -p "$out/$f" | grep "DLL Name")
    echo "$imports" | grep -q "lua53.dll" || { echo "$f does not import lua53.dll"; exit 1; }
    if echo "$imports" | grep -qi "liblua"; then echo "$f imports liblua"; exit 1; fi
done

(cd "$out" && sha256sum *.dll > SHA256SUMS)
cat "$out/SHA256SUMS"
echo "Package: $out"
