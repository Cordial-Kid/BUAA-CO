//D级流水线寄存器，负责传递PC和instr
`include "def.v"
module D_reg (
    input clk,
    input reset,
    input Flush,   
    input WE,    
    input [31:0] F_PC,
    input [31:0] F_Instr,
    output [31:0] D_PC,
    output [31:0] D_Instr
);
reg [31:0] PCReg;
reg [31:0] instrReg;

initial begin
    PCReg = 32'b0;
    instrReg = 32'b0;
end

always @(posedge clk) begin
    if (reset || Flush) begin
        PCReg <= 32'b0;
        instrReg <= 32'b0;
    end else begin
        if (WE) begin
            PCReg <= F_PC;
            instrReg <= F_Instr;
        end
    end
end
    assign D_PC = PCReg;
    assign D_Instr = instrReg;
endmodule