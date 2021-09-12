package ATE;

interface Ifc_Counter#(numeric type size);
    method Action reset;
    method UInt#(size) read;
endinterface

module mkCounter(Ifc_Counter#(size));
    Reg#(UInt#(size)) count <- mkReg(0);

    rule rl_increment;
        count <= count + 1;
    endrule

    method Action reset;
        count <= 0;
    endmethod

    method UInt#(size) read;
        return count;
    endmethod

endmodule

interface Ifc_Top;
    method Bit#(4) led;
endinterface

(* synthesize,
   reset_prefix = "rst",
   clock_prefix = "clk",
   always_ready = "led" *)
module mkTop(Ifc_Top);
    Ifc_Counter#(28) counter <- mkCounter();

    method Bit#(4) led;
        let count = counter.read;
        let packed_count = pack(count);
        return packed_count[27:24];
    endmethod
endmodule

endpackage
