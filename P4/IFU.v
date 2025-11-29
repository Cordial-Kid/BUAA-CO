`include "def.v"
module IFU (
    input [31:0] NPC,
    output [31:0] PC,
    output [31:0] instruct,
    input clk,
    input reset
);

  reg [31:0] IM[0:4095];
  reg [31:0] _PC;
  integer i;

  initial begin
    for (i = 0; i < 4096; i = i + 1) begin
      IM[i] = 32'b0;
    end
    _PC = 32'h00003000;
    $readmemh("code.txt", IM);
  end
 
  always @(posedge clk) begin
    if (reset) begin
      _PC <= 32'h00003000;
    end else begin
      _PC <= NPC;
    end 
  end 

  assign PC = _PC;
  assign instruct = IM[(_PC-32'h00003000)>>2];

endmodule