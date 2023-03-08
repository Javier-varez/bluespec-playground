package CoreMemory;

import Assert::*;
import Vector::*;
import Types::*;
import RegFile::*;

typedef enum { Load, Store } MemOp deriving(Bits, Eq);

typedef struct {
    MemOp op;
    Word address;
    Word data;
} MemRequest deriving(Bits, Eq);

interface Memory#(numeric type size);
    // Requests a memory transaction. If it is a load, the value will be visible in response.
    method Action request(MemRequest r);

    // Accesses the value of the memory load request.
    method ActionValue#(Word) response();
endinterface

// This one is an implementation of distributed memory in the form of registers in the FPGA
module mkDistributedMemory#(String file) (Memory#(sizeType));
    Address addrSize = fromInteger(valueOf(sizeType));
    RegFile#(Address, Word) mem_array <- mkRegFileLoad(file, 0, addrSize - 1);

    Reg#(Word) out_buf <- mkReg(0);
    Reg#(Bool) valid[2] <- mkCReg(2, False);

    method Action request(MemRequest r) if (!valid[1]);
        case (r.op) matches
            Load:
                begin
                    out_buf <= mem_array.sub(r.address);
                    valid[1] <= True;
                end
            Store:
                begin
                    mem_array.upd(r.address, r.data);
                end
        endcase
    endmethod

    method ActionValue#(Word) response() if (valid[0]);
        valid[0] <= False;
        return out_buf;
    endmethod
endmodule

endpackage
