package FifoTestBench;

import Assert::*;
import Fifo::*;

(* synthesize *)
module mkTestBench (Empty);
    Reg#(Bit#(8)) step <- mkReg(0);

    Fifo#(Bit#(32)) fifo <- mkFifo();

    rule keep_stepping;
        step <= step + 1;
    endrule

    rule step0 if (step == 0);
        let value = 'h1234;
        fifo.enq(value);
        $display("enqueueing %x", value);
    endrule

    rule step1_enqueue if (step == 1);
        let value = 'h1235;
        fifo.enq(value);
        $display("enqueueing %x", value);
    endrule

    rule step1_dequeue if (step == 1);
        let value = fifo.first();
        fifo.deq();
        dynamicAssert(value == 'h1234, "Invalid value at step1");
        $display("dequeued %x", value);
    endrule

    rule step2_enqueue if (step == 2);
        let value = 'h1236;
        fifo.enq(value);
        $display("enqueueing %x", value);
    endrule

    rule step2_dequeue if (step == 2);
        let value = fifo.first();
        fifo.deq();
        dynamicAssert(value == 'h1235, "Invalid value at step2");
        $display("dequeued %x", value);
    endrule

    rule step3 if (step == 3);
        $display("Tests done!");
        $finish;
    endrule
endmodule

endpackage
