module top (
    input wire clk,
    output wire [3:0] led
);

  wire clk_bufg;
  BUFG BUFG (
      .I(clk),
      .O(clk_bufg)
  );

  // The PS7
  (* KEEP, DONT_TOUCH *)
  PS7 PS7 (
  );

  // Bluespec top module
  mkTop mkTop (
    .RST_N(1),
    .CLK(clk_bufg),
    .led(led)
  );

endmodule
