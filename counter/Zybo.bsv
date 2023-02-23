package Zybo;

(* always_ready *)
interface Ifc_Top;
    (* prefix = "" *)
    method Bit#(4) led;
    (* prefix = "", always_enabled *)
    method Action buttons(Bit#(4) btn);
endinterface

endpackage
