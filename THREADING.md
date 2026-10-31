# Threads in quik-lua-rpc (QUIK 12.x)

QUIK runs a Lua script on two threads that share one Lua state:

| Thread | Runs |
|---|---|
| QUIK main (terminal) thread | the script body at load, and every callback: `OnQuote`, `OnParam`, `OnAllTrade`, `OnStop`, `OnClose`... |
| Script thread | `main()`, which here is the ZeroMQ poll loop serving requests |

QUIK's `lua53.dll` serializes the two threads. Every Lua API call takes a lock that QUIK installs with `QLuaSetSynchronization(lock, unlock)`, and a C function called from Lua runs with the lock released. So:

1. **Every native module must link against QUIK's `lua53.dll`.** A module linked against another Lua build (the old `liblua.dll`) calls a Lua API without the lock. It then changes the shared state while the other thread is running, and the heap gets corrupted. QUIK dies with `0xC0000374` in `ntdll.dll`.
2. **A ZeroMQ socket must stay on one thread.** A C call into libzmq runs without the Lua lock, so a callback that sends on a socket can run while `main()` is inside `zmq_poll` on the same socket. libzmq sockets are not thread-safe, and that also corrupts the heap.

## Rules in this code

- `main()` (script thread) owns every ZeroMQ socket: RPC, PUB and the ZAP handler. It creates them, polls them, sends on them and closes them.
- Callbacks (terminal thread) never touch ZeroMQ. `publish()` in `service.lua` converts the event and appends it to `event_queue`, a plain Lua table. Appends are safe because of QUIK's lock.
- The poll loop wakes at least every `EVENT_FLUSH_MS` (50 ms) and `flush_events()` sends the queued events from the script thread.
- The queue is capped at `MAX_QUEUED_EVENTS` (10,000). If no one drains it, newer events are dropped and counted. The count is reported once at shutdown.
- `OnStop` and `OnClose` only call `service.stop()`, which sets a flag. `main()` sees it within 50 ms, leaves the loop and calls `service.terminate()` on the script thread, which closes the sockets and the ZeroMQ context.
- The PUB socket is not added to the poller. Nothing needs to wait for it to become writable, because PUB drops messages when a subscriber is slow.

## Builds

`win-build/build.sh` builds `lzmq.dll` and `pb.dll` against `quik_redist/lua53.dll` (taken from QUIK 12.8.0.6) and checks that both import `lua53.dll` and not `liblua`. The 2021 package, which shipped `liblua.dll`, is kept in `built/archive/` as a fallback.

`win-build/test/` holds `quikemu`, a stand-in for QUIK that uses QUIK's own `lua53.dll` and lock. It runs `main()` on one thread, fires `OnQuote`/`OnParam` from another and serves order-book requests (`getQuoteLevel2`, `getParamEx`). On 2026-10-27 the 2021 build crashed with `0xC0000374` within seconds in every run. With only one of the two fixes it still crashed. With both, it ran clean.
