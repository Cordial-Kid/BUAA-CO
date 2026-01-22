module W_reg (
    input clk,
    input reset,
    input Flush,
    input WE,
    input [31:0] M_PC,
    input [31:0] M_Instr,
    input [31:0] M_RD,
    input [31:0] M_C,        //往GRF写入某些东西可能与ALU的运算结果有关
    input [31:0] M_MDU_C,
    output [31:0] W_PC,
    output [31:0] W_Instr,
    output [31:0] W_RD,
    output [31:0] W_C,
    output [31:0] W_MDU_C
);

reg [31:0] PCReg,instrReg,RDReg,CReg,MDUCreg;

initial begin
    PCReg = 32'b0;
    instrReg = 32'b0;
    RDReg = 32'b0;
    CReg = 32'b0;
    MDUCreg = 32'b0;
end

always @(posedge clk) begin
    if (reset || Flush) begin
        PCReg <= 32'b0;
        instrReg <= 32'b0;
        RDReg <= 32'b0;
        CReg <= 32'b0;
        MDUCreg <= 32'b0;
    end
    else begin
        if (WE) begin
            PCReg <= M_PC;
            instrReg <= M_Instr;
            RDReg <= M_RD;
            CReg <= M_C;
            MDUCreg <= M_MDU_C;
        end
    end
end
    assign W_PC = PCReg;
    assign W_Instr = instrReg;
    assign W_RD = RDReg;
    assign W_C = CReg;
    assign W_MDU_C = MDUCreg;
endmodule