`include "def.v"
module ALU (
    input [31:0] PC,
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUOp,
    input [4:0] shamt,
    output [31:0] C,
    output zero
);
  reg [31:0] complement;

  always @(*) begin
    if (A[31] == 1'b0) begin
      complement = A;
    end
    else begin
      complement = {1'b1,~(A[30:0])} + 1'b1;
    end
  end

  // lui跟左移不一样
  assign C = (ALUOp == `ALU_add) ? A + B :
               (ALUOp == `ALU_sub) ? A - B :
               (ALUOp == `ALU_ori) ? A | B :
               (ALUOp == `ALU_lui) ? (B << 16) :
               (ALUOp == `ALU_sll) ? (B << shamt) :
               (ALUOp == `ALU_tftc) ? complement :
               (ALUOp == `ALU_pcadd) ? PC + A :
               A;
  assign zero = (A == B) ? 1'b1 : 1'b0;
endmodule

// assign zero = ($signed(A) > $signed(B)) ? A : B;

//循环右移的实现
// answer = (data >> offset) + (data << (32 - offset));