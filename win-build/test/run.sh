#!/bin/sh
# Runs quik-lua-rpc inside quikemu (fake QUIK with QUIK's own lua53.dll) under load.
#
#   run.sh <package dir> <work dir> <seconds> <callbacks/s> <clients> <client classpath> [sub]
#
# <package dir> is an install package laid out like the QUIK folder: DLLs at the top,
# Lua code under lua/. <client classpath> is a ';'-separated Java classpath with JeroMQ,
# protobuf-javalite and the Java classes generated from qlua/rpc/*.proto (see
# win-build/README.md). Needs gcc (w64devkit) and java on PATH, LUA_INC pointing at
# Lua 5.3 headers.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
pkg=$1 work=$2 seconds=$3 rate=$4 clients=$5 cp_list=$6 sub=${7:-}
redist=$here/../../quik_redist

rm -rf "$work"
mkdir -p "$work/quik"
cp -r "$pkg"/. "$work/quik/"
cp "$redist/lua53.dll" "$work/quik/"
cp "$here/config.json" "$work/quik/lua/quik-lua-rpc/config.json"
gcc -O2 -Wall -I"$LUA_INC" "$here/quikemu.c" "$work/quik/lua53.dll" -o "$work/quik/quikemu.exe"

# PowerShell keeps the full 32-bit exit code, so a crash shows as e.g. C0000374.
wq=$(cygpath -w "$work/quik")
powershell -NoProfile -Command "\$p = Start-Process -FilePath '$wq\\quikemu.exe' -ArgumentList '$wq\\lua\\quik-lua-rpc',$seconds,$rate -NoNewWindow -PassThru -Wait -RedirectStandardOutput '$wq\\..\\quikemu.log' -RedirectStandardError '$wq\\..\\quikemu.err'; 'quikemu exit code: 0x{0:X8}' -f \$p.ExitCode" > "$work/exitcode.txt" 2>&1 &
emu=$!
sleep 3
java -cp "$cp_list" "$here/LoadGen.java" $((seconds - 6)) "$clients" $sub > "$work/loadgen.log" 2>&1 || true
wait $emu || true
tail -n 3 "$work/loadgen.log"
tail -n 5 "$work/quikemu.log"
cat "$work/exitcode.txt"
