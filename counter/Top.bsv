package Top;

import Utils::*;
import Zybo::*;

(* synthesize *)
module mkTop(Ifc_Top);
    Ifc_Counter#(28) counter <- mkCounter;

    method Bit#(4) led;
        let count = counter.read;
        let packed_count = pack(count);
        return packed_count[27:24];
    endmethod

    method Action buttons(Bit#(4) btn);
    endmethod
endmodule

endpackage
