package Fifo;

interface Fifo;
    method Action enq(Bit#(32) v);
    method Action deq();
    method Bit#(32) first();
endinterface

module mkFifo(Fifo);
    Reg#(Bit#(32)) value <- mkReg(0);
    Reg#(Bool) valid[2] <- mkCReg(2, False);

    method Action enq(Bit#(32) v) if (!valid[1]);
        value <= v;
        valid[1] <= True;
    endmethod

    method Action deq() if (valid[0]);
        valid[0] <= False;
    endmethod

    method Bit#(32) first() if (valid[0]);
        return value;
    endmethod
endmodule

endpackage
