package Fifo;

interface Fifo#(type t);
    method Action enq(t v);
    method Action deq();
    method t first();
endinterface

module mkFifo(Fifo#(t)) provisos(Bits#(t, sz));
    Reg#(t) value <- mkRegU();
    Reg#(Bool) valid[2] <- mkCReg(2, False);

    method Action enq(t v) if (!valid[1]);
        value <= v;
        valid[1] <= True;
    endmethod

    method Action deq() if (valid[0]);
        valid[0] <= False;
    endmethod

    method t first() if (valid[0]);
        return value;
    endmethod
endmodule

endpackage
