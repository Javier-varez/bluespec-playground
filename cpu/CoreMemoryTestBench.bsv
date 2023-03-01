package CoreMemoryTestBench;

import Assert::*;
import Types::*;
import Memory::*;

(* synthesize *)
module mkTestBench (Empty);
    Reg#(Bit#(8)) step <- mkReg(0);

    // 32 words of memory
    Memory#(32) memory <- mkDistributedMemory();

    rule keep_stepping;
        step <= step + 1;
    endrule

    rule step0_store if (step == 0);
        memory.request(MemRequest{ op: Store, address: 3, data: 'h12345678 });
    endrule

    rule step1_load_issue if (step == 1);
        memory.request(MemRequest{ op: Load, address: 3, data: ? });
    endrule

    rule step2_load_issue if (step == 2);
        memory.request(MemRequest{ op: Load, address: 4, data: ? });
    endrule

    rule step2_load_response if (step == 2);
        let rsp <- memory.response();
        $display("mem[3] = %x", rsp);
        dynamicAssert(rsp == 'h12345678, "Invalid value at [3]");
    endrule

    rule step3_load_response if (step == 3);
        let rsp <- memory.response();
        $display("mem[4] = %x", rsp);
        dynamicAssert(rsp == 'h0, "Invalid value at [4]");
    endrule

    rule step4 if (step == 4);
        $display("Tests done!");
        $finish;
    endrule
endmodule

endpackage
