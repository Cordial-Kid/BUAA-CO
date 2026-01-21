module W_reg (
    input clk,
    input reset,
    input Flush,
    input WE,
    input [31:0] M_PC,
    input [31:0] M_Instr,
    input [31:0] M_RD,
    input [31:0] M_C,        //往GRF写入某些东西可能与ALU的运算结果有关
    input M_B_Jump,
    input M_Condition1,
    output [31:0] W_PC,
    output [31:0] W_Instr,
    output [31:0] W_RD,
    output [31:0] W_C,
    output W_B_Jump,
    output W_Condition1
);

reg [31:0] PCReg,instrReg,RDReg,CReg;
reg b_jump_reg,condition1_reg;

initial begin
    PCReg = 32'b0;
    instrReg = 32'b0;
    RDReg = 32'b0;
    CReg = 32'b0;
    b_jump_reg = 0;
    condition1_reg = 0;
end

always @(posedge clk) begin
    if (reset || Flush) begin
        PCReg <= 32'b0;
        instrReg <= 32'b0;
        RDReg <= 32'b0;
        CReg <= 32'b0;
        b_jump_reg <= 0;
        condition1_reg <= 0;
    end
    else begin
        if (WE) begin
            PCReg <= M_PC;
            instrReg <= M_Instr;
            RDReg <= M_RD;
            CReg <= M_C;
            b_jump_reg <= M_B_Jump;
            condition1_reg <= M_Condition1;
        end
    end
end
    assign W_PC = PCReg;
    assign W_Instr = instrReg;
    assign W_RD = RDReg;
    assign W_C = CReg;
    assign W_B_Jump = b_jump_reg;
    assign W_Condition1 = condition1_reg;
endmodule