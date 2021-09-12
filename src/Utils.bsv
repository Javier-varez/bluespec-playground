package Utils;

interface Ifc_Counter#(numeric type size);
    method UInt#(size) read;
endinterface

module mkCounter(Ifc_Counter#(size));
    Reg#(UInt#(size)) count <- mkReg(0);

    rule rl_increment;
        count <= count + 1;
    endrule

    method UInt#(size) read;
        return count;
    endmethod

endmodule


endpackage
