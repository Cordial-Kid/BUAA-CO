`include "def.v"
module E_ALU (
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALUOp,
    output [31:0] C  
);

assign C = (ALUOp == `ALU_add) ? A + B :
           (ALUOp == `ALU_sub) ? A - B :
           (ALUOp == `ALU_ori) ? A | B :
           (ALUOp == `ALU_sll) ? A << B[10:6] :
           (ALUOp == `ALU_lui) ? {B[15:0],16'b0} :
           (ALUOp == `ALU_and) ? A & B :
           (ALUOp == `ALU_slt) ? $signed(A) < $signed(B) :
           (ALUOp == `ALU_sltu) ? A < B :
           A;
    
endmodule