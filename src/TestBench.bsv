package TestBench;

import Assert::*;
import Cpu::*;
import Types::*;

(* synthesize *)
module mkTestBench (Empty);
    rule rl_display_info;
        let alu_result = alu(21, 12, Add);
        $display("Addition %0d", alu_result);
        dynamicAssert(alu_result == 33, "Add failed!");

        alu_result = alu(21, 12, Sub);
        $display("Subtraction %0d", alu_result);
        dynamicAssert(alu_result == 9, "Sub failed!");

        alu_result = alu('h15, 10, Sll);
        $display("Sll 0x%0x", alu_result);
        dynamicAssert(alu_result == 'h5400, "Sll failed!");

        alu_result = alu(15, 10, Slt);
        $display("Slt 0x%0x", alu_result);
        dynamicAssert(alu_result == 0, "Slt failed!");

        alu_result = alu(10, 10, Slt);
        $display("Slt 0x%0x", alu_result);
        dynamicAssert(alu_result == 0, "Slt failed!");

        alu_result = alu(9, 10, Slt);
        $display("Slt 0x%0x", alu_result);
        dynamicAssert(alu_result == 1, "Slt failed!");

        alu_result = alu(-9, -8, Slt);
        $display("Slt 0x%0x", alu_result);
        dynamicAssert(alu_result == 1, "Slt failed!");

        alu_result = alu(128, 129, Sltu);
        $display("Sltu 0x%0x", alu_result);
        dynamicAssert(alu_result == 1, "Sltu failed!");

        alu_result = alu(129, 128, Sltu);
        $display("Sltu 0x%0x", alu_result);
        dynamicAssert(alu_result == 0, "Sltu failed!");

        alu_result = alu('h12, 'h46, Xor);
        $display("Xor 0x%0x", alu_result);
        dynamicAssert(alu_result == 'h54, "Xor failed!");

        alu_result = alu('h12, 'h46, Or);
        $display("Or 0x%0x", alu_result);
        dynamicAssert(alu_result == 'h56, "Or failed!");

        alu_result = alu('h12, 'h46, And);
        $display("And 0x%0x", alu_result);
        dynamicAssert(alu_result == 'h02, "And failed!");

        alu_result = alu('h12, 2, Srl);
        $display("Srl 0x%0x", alu_result);
        dynamicAssert(alu_result == 'h04, "Srl failed!");

        alu_result = alu('hffffff88, 4, Srl);
        $display("Srl 0x%0x", alu_result);
        dynamicAssert(alu_result == 'hffffff8, "Srl failed!");

        alu_result = alu('hffffff88, 4, Sra);
        $display("Sra 0x%0x", alu_result);
        dynamicAssert(alu_result == 'hfffffff8, "Srl failed!");

        $finish;
    endrule
endmodule

endpackage
