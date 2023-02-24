package Cpu;

import Types::*;

interface Cpu;
    method Address read();
    method Action write(Address address);
endinterface

endpackage
