package Types;

typedef Bit#(32) Word;
typedef Bit#(16) HalfWord;
typedef Bit#(8) Byte;

typedef enum { Add, Sub, Sll, Slt, Sltu, Xor, Srl, Sra, Or, And } AluOp deriving(Bits, Eq);

endpackage
