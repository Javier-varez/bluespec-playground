package Cpu;

import Types::*;
import CpuMemory::*;
import Vector::*;

interface RegFile#(numeric type size, type stored_type, type index_type);
    method stored_type read_port1(index_type index);
    method stored_type read_port2(index_type index);
    method Action write_port(index_type index, stored_type value);
endinterface

module mkRegFile(RegFile#(size, stored_type, index_type))
    provisos(Literal#(stored_type),
             Bits#(stored_type, st_size),
             PrimIndex#(index_type, idx),
             Bits#(index_type, it_size));
    Vector#(size, Reg#(stored_type)) regs <- replicateM(mkReg(0));

    method stored_type read_port1(index_type index) = regs[index];

    method stored_type read_port2(index_type index) = regs[index];

    method Action write_port(index_type index, stored_type value);
        if (index != 0)
        begin
            regs[index] <= value;
        end
    endmethod
endmodule

function Word alu(Word rs1, Word rs2, AluOp op);
    case (op) matches
        Add: return rs1 + rs2;
        Sub: return rs1 - rs2;
        Sll: return rs1 << rs2;
        Slt:
            begin
                Int#(32) signed_rs1 = unpack(rs1);
                Int#(32) signed_rs2 = unpack(rs2);
                return signed_rs1 < signed_rs2 ? 1 : 0;
            end
        Sltu:
            begin
                UInt#(32) unsigned_rs1 = unpack(rs1);
                UInt#(32) unsigned_rs2 = unpack(rs2);
                return unsigned_rs1 < unsigned_rs2 ? 1 : 0;
            end
        Xor: return rs1 ^ rs2;
        Srl: return zeroExtend(rs1 >> rs2);
        Sra:
            begin
                Int#(32) signed_rs1 = unpack(rs1);
                return pack(signed_rs1 >> rs2);
            end
        Or: return rs1 | rs2;
        And: return rs1 & rs2;
    endcase
endfunction

endpackage
