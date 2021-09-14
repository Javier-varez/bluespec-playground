package TestBench;

(* synthesize *)
module mkTestBench (Empty);
    rule rl_display_info;
        $display("Hello world!");
        $finish;
    endrule
endmodule

endpackage
