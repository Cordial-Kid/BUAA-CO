`include "def.v"
module F_PC (
    input clk,
    input reset,
    input [31:0] NPC,
    input PCWE,
    output [31:0] PC
);

  reg [31:0] PCReg;

  initial begin
    PCReg = 32'h00003000;
  end

  always @(posedge clk) begin
    if (reset) begin
      PCReg <= 32'h00003000;
    end else begin
      if (PCWE) begin
        PCReg <= NPC;
      end
    end
  end

  assign PC = PCReg;
endmodule
