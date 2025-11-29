`include "def.v"
module GRF (
    input [31:0] PC,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD,
    input WE,
    input clk,
    input reset,
    output [31:0] RD1,
    output [31:0] RD2
);

  reg [31:0] register[0:31];
  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      register[i] = 32'b0;
    end
  end

  always @(posedge clk) begin
    if (reset) begin
      for (i = 0; i < 32; i = i + 1) begin
        register[i] <= 32'b0;
      end
    end else begin
      if (WE == 1'b1 && A3 != 0) begin
        register[A3] <= WD;
        // 只有写使能有效的时候才观测add和data
        $display("@%h: $%d <= %h", PC, A3, WD);
      end
    end
  end

  assign RD1 = register[A1];
  assign RD2 = register[A2];
endmodule
