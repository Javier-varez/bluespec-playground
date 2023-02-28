package Decoder;

import Types::*;

function InstrFormat instrFormat(Opcode opcode);
    case (opcode) matches
        Load:
            return Itype;
        LoadFP:
            return Itype;
        MiscMem:
            return Itype;
        OpImm:
            return Itype;
        AuiPc:
            return Utype;
        OpImm32:
            return Itype;
        OpImm32:
            return Itype;
        Store:
            return Stype;
        StoreFP:
            return Stype;
        Amo:
            return Rtype;
        Op:
            return Rtype;
        Lui:
            return Utype;
        Op32:
            return Rtype;
        Madd:
            return Rtype;
        Msub:
            return Rtype;
        NmSub:
            return Rtype;
        NmAdd:
            return Rtype;
        OpFp:
            return Rtype;
        Branch:
            return Btype;
        Jalr:
            return Itype;
        Jal:
            return Jtype;
        System:
            return Itype;
    endcase
endfunction

function DecodedInstruction decodeInstruction(Instruction instruction);
    Opcode opcode = unpack(instruction[6:0]);

    let format = instrFormat(opcode);
    case (format) matches
        Rtype:
            begin
                return DecodedInstruction {
                    opcode: opcode,
                    rd: unpack(instruction[11:7]),
                    rs1: unpack(instruction[19:15]),
                    rs2: unpack(instruction[24:20]),
                    funct3: instruction[14:12],
                    funct7: instruction[31:25],
                    imm: ?
                };
            end
        Itype:
            begin
                return DecodedInstruction {
                    opcode: opcode,
                    rd: unpack(instruction[11:7]),
                    rs1: unpack(instruction[19:15]),
                    rs2: ?,
                    funct3: instruction[14:12],
                    funct7: ?,
                    imm: signExtend(instruction[31:20])
                };
            end
        Stype:
            begin
                Bit#(12) imm = {instruction[31:25], instruction[11:7]};
                return DecodedInstruction {
                    opcode: opcode,
                    rd: ?,
                    rs1: unpack(instruction[19:15]),
                    rs2: unpack(instruction[24:20]),
                    funct3: instruction[14:12],
                    funct7: ?,
                    imm: signExtend(imm)
                };
            end
        Btype:
            begin
                Bit#(13) imm = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                return DecodedInstruction {
                    opcode: opcode,
                    rd: ?,
                    rs1: unpack(instruction[19:15]),
                    rs2: unpack(instruction[24:20]),
                    funct3: instruction[14:12],
                    funct7: ?,
                    imm: signExtend(imm)
                };
            end
        Utype:
            begin
                Bit#(32) imm = {instruction[31:12], 12'b0};
                return DecodedInstruction {
                    opcode: opcode,
                    rd: unpack(instruction[11:7]),
                    rs1: ?,
                    rs2: ?,
                    funct3: ?,
                    funct7: ?,
                    imm: signExtend(imm)
                };
            end
        Jtype:
            begin
                Bit#(21) imm = {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                return DecodedInstruction {
                    opcode: opcode,
                    rd: unpack(instruction[11:7]),
                    rs1: ?,
                    rs2: ?,
                    funct3: ?,
                    funct7: ?,
                    imm: signExtend(imm)
                };
            end
    endcase
endfunction

endpackage
