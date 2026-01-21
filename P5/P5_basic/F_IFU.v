`include "def.v"
module F_IFU (
    input [31:0] NPC,
    input clk,
    input reset,
    input PCWE,
    output [31:0] PC,
    output [31:0] Instr
);

reg [31:0] IM [0:4095];
reg [31:0] PCReg;
integer i;

initial begin
    for (i = 0 ; i < 4096 ; i = i + 1) begin
        IM[i] = 32'b0;
    end
    PCReg = 32'h00003000;
    $readmemh("code.txt",IM);
end

always @(posedge clk) begin
    if (reset) begin
        PCReg <= 32'h00003000;
    end else if (PCWE) begin
        PCReg <= NPC;
    end
end

    assign PC = PCReg;
    assign Instr = IM[(PCReg - 32'h00003000)>>2];
endmodule