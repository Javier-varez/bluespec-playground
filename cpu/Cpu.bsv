package Cpu;

import Types::*;
import RegisterFile::*;
import CoreMemory::*;

interface Cpu;
    (* prefix = "" *)
    method Bit#(4) led;

    (* prefix = "", always_enabled *)
    method Action buttons(Bit#(4) btn);

    (* prefix = "" *)
    method Bit#(1) uart_tx;
endinterface

typedef Reg#(Bit#(32)) Pc;
typedef RegFile#(32, Word, RegIndex) CpuRegFile;
typedef Memory#(1024) InstMemory;
typedef Memory#(1024) DataMemory;

(* synthesize *)
module mkCpu#(string inst_file, string data_file)(Empty);
    Pc pc <- mkReg(0);
    CpuRegFile register_file <- mkRegFile();
    InstMemory inst_memory <- mkDistributedMemory(inst_file);
    DataMemory data_memory <- mkDistributedMemory(data_file);

    rule readInstMem;
        inst_memory.request(MemRequest { op: Load, address: pc, data: ? });
    endrule

    rule execute;
        Word instruction <= inst_memory.response();
        DecodedInstruction dec_inst <= decodeInstruction(instruction);
        ControlSignals control_signals <= generateControlSignals(dec_inst);

        let rs1 <= register_file.read_port1(dec_inst.rs1);
        let rs2 <= register_file.read_port2(dec_inst.rs2);

        let op2 <= rs1;
        if control_signals.imm_source
            let op2 <= dec_inst.imm;
        else
            let op2 <= rs2;

        // Instantiate ALU
        let aluResult = alu(op1, op2, control_signals.alu_op)

        // Mem access
        if control_signals.mem_op
        begin
            // TODO: Implement
        end

        // Write back
        if control_signals.write_back
            register_file.write_port(aluResult);

        pc <= pc + 4;
    endrule

endmodule

endpackage
