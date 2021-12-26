import org.zeromq.SocketType;
import org.zeromq.ZContext;
import org.zeromq.ZMQ;
import qlua.rpc.GetParamEx;
import qlua.rpc.GetQuoteLevel2;
import qlua.rpc.RPC;

import java.util.concurrent.atomic.AtomicLong;

/**
 * Polls order books (GetQuoteLevel2 + GetParamEx BID/OFFER) through quik-lua-rpc as fast as it answers.
 * Usage: java -cp <qlua.rpc classes + jeromq + protobuf-javalite> LoadGen.java <seconds> <clients> [sub]
 * Each client has its own REQ socket, so several clients put concurrent load on the RPC endpoint.
 * With "sub", also subscribes to the PUB endpoint (5561) and counts the events it receives.
 */
public class LoadGen {
    static final String[] SECS = {"SBER", "GAZP", "LKOH", "GMKN", "NVTK", "ROSN", "TATN", "MGNT", "MTSS", "YDEX"};
    static final AtomicLong ok = new AtomicLong(), failed = new AtomicLong(), events = new AtomicLong();

    public static void main(String[] a) throws Exception {
        long seconds = Long.parseLong(a[0]);
        int clients = Integer.parseInt(a[1]);
        long end = System.currentTimeMillis() + seconds * 1000;
        try (ZContext ctx = new ZContext()) {
            Thread[] threads = new Thread[clients];
            for (int i = 0; i < clients; i++) {
                threads[i] = new Thread(() -> run(ctx, end));
                threads[i].start();
            }
            Thread sub = null;
            if (a.length > 2 && a[2].equals("sub")) {
                sub = new Thread(() -> subscribe(ctx, end));
                sub.start();
            }
            long start = System.currentTimeMillis();
            while (System.currentTimeMillis() < end) {
                Thread.sleep(5000);
                System.out.printf("loadgen: %ds ok=%d failed=%d events=%d%n", (System.currentTimeMillis() - start) / 1000, ok.get(), failed.get(), events.get());
            }
            for (Thread t : threads) t.join();
            if (sub != null) sub.join();
        }
        System.out.printf("loadgen RESULT: ok=%d failed=%d events=%d%n", ok.get(), failed.get(), events.get());
        System.exit(failed.get() == 0 && ok.get() > 0 ? 0 : 1);
    }

    static ZMQ.Socket open(ZContext ctx) {
        ZMQ.Socket s = ctx.createSocket(SocketType.REQ);
        s.setPlainUsername("test_user");
        s.setPlainPassword("test_password");
        s.setReceiveTimeOut(5000);
        s.setSendTimeOut(5000);
        s.setLinger(0);
        s.connect("tcp://127.0.0.1:5560");
        return s;
    }

    static void run(ZContext ctx, long end) {
        ZMQ.Socket s = open(ctx);
        int n = 0;
        while (System.currentTimeMillis() < end) {
            String sec = SECS[n++ % SECS.length];
            RPC.Request req = switch (n % 3) {
                case 0 -> RPC.Request.newBuilder().setType(RPC.ProcedureType.GET_QUOTE_LEVEL2)
                        .setArgs(GetQuoteLevel2.Args.newBuilder().setClassCode("TQBR").setSecCode(sec).build().toByteString()).build();
                default -> RPC.Request.newBuilder().setType(RPC.ProcedureType.GET_PARAM_EX)
                        .setArgs(GetParamEx.Args.newBuilder().setClassCode("TQBR").setSecCode(sec)
                                .setParamName(n % 3 == 1 ? "BID" : "OFFER").build().toByteString()).build();
            };
            try {
                byte[] resp = s.send(req.toByteArray()) ? s.recv() : null;
                if (resp == null) throw new IllegalStateException("no reply within 5s");
                RPC.Response r = RPC.Response.parseFrom(resp);
                if (r.getIsError()) throw new IllegalStateException(RPC.Error.parseFrom(r.getResult()).getMessage());
                if (req.getType() == RPC.ProcedureType.GET_QUOTE_LEVEL2) {
                    if (GetQuoteLevel2.Result.parseFrom(r.getResult()).getBidsCount() != 20) throw new IllegalStateException("bad order book");
                } else if (GetParamEx.Result.parseFrom(r.getResult()).getParamEx().getParamValue().isEmpty()) {
                    throw new IllegalStateException("empty param");
                }
                ok.incrementAndGet();
            } catch (Exception e) {
                if (failed.incrementAndGet() <= 5) System.out.println("loadgen: " + e.getMessage());
                s.close();
                s = open(ctx);
            }
        }
        s.close();
    }

    static void subscribe(ZContext ctx, long end) {
        ZMQ.Socket s = ctx.createSocket(SocketType.SUB);
        s.setPlainUsername("admin");
        s.setPlainPassword("letmein");
        s.setReceiveTimeOut(500);
        s.connect("tcp://127.0.0.1:5561");
        s.subscribe(new byte[0]);
        while (System.currentTimeMillis() < end) {
            byte[] frame = s.recv();
            if (frame != null && !s.hasReceiveMore()) events.incrementAndGet();
        }
        s.close();
    }
}
