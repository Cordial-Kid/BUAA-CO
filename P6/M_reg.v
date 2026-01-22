`include "def.v"
module M_reg (
    input Flush,
    input WE,  
    input clk,
    input reset,
    input [31:0] E_PC,      
    input [31:0] E_Instr,
    input [31:0] E_Rt_data,  //sw用
    input [31:0] E_C,
    input [31:0] E_MDU_C,
    output [31:0] M_PC,
    output [31:0] M_Instr,
    output [31:0] M_Rt_data,
    output [31:0] M_C,
    output [31:0] M_MDU_C

);
    reg [31:0] PCReg,instrReg,rt_data_Reg,CReg,MDUCreg;

    initial begin
        PCReg = 32'b0;
        instrReg = 32'b0;
        rt_data_Reg = 32'b0;
        CReg = 32'b0;
        MDUCreg = 32'b0;
    end

    always @(posedge clk) begin
        if (reset || Flush) begin
            PCReg <= 32'b0;
            instrReg <= 32'b0;
            rt_data_Reg <= 32'b0;
            CReg <= 32'b0;
            MDUCreg <= 32'b0;
        end else begin
            if (WE) begin
                PCReg <= E_PC;
                instrReg <= E_Instr;
                rt_data_Reg <= E_Rt_data;
                CReg <= E_C;
                MDUCreg <= E_MDU_C;
            end
        end
    end

    assign M_PC = PCReg;
    assign M_Instr = instrReg;
    assign M_Rt_data = rt_data_Reg;
    assign M_C = CReg;
    assign M_MDU_C = MDUCreg;
endmodule