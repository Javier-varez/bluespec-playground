
package CpuMemory;

import Assert::*;
import Vector::*;
import Types::*;

typedef enum { Load, Store } MemOp deriving(Bits, Eq);

typedef struct {
    MemOp op;
    Word address;
    Word data;
} MemRequest deriving(Bits, Eq);

interface Memory#(numeric type size);
    method ActionValue#(Word) request(MemRequest r);
endinterface

// This one is an implementation of distributed memory in the form of registers in the FPGA
module mkDistributedMemory(Memory#(size));
    Vector#(size, Reg#(Word)) mem_array <- replicateM(mkReg(0));

    method ActionValue#(Word) request(MemRequest r);
        case (r.op) matches
            Load:
                begin
                    return mem_array[r.address];
                end
            Store:
                begin
                    mem_array[r.address] <= r.data;
                    return 0;
                end
        endcase
    endmethod
endmodule

endpackage
