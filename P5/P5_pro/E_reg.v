//流水线寄存器只需要存取东西就行 
module E_reg (
    input clk,
    input reset,
    input Flush,
    input WE,
    input [31:0] D_PC,
    input [31:0] D_Instr,
    input [31:0] D_EXT,   //要用于ALU的计算
    input [31:0] D_Rs_data, 
    input [31:0] D_Rt_data,
    input D_B_Jump,
    output [31:0] E_PC,
    output [31:0] E_Instr,
    output [31:0] E_EXT,
    output [31:0] E_Rs_data,   
    output [31:0] E_Rt_data,
    output E_B_Jump
);

// 流水线寄存器需要流水的数据
reg [31:0] PCReg,instrReg,extReg,rs_data_Reg,rt_data_Reg;
reg b_jump_reg;

initial begin
    PCReg = 32'b0;
    instrReg = 32'b0;
    extReg = 32'b0;
    rs_data_Reg = 32'b0;
    rt_data_Reg = 32'b0;
    b_jump_reg = 0;
end

always @(posedge clk) begin
    if (reset || Flush) begin
        PCReg <= 32'b0;
        instrReg <= 32'b0;
        extReg <= 32'b0;
        rs_data_Reg <= 32'b0;
        rt_data_Reg <= 32'b0;
        b_jump_reg <= 0;
    end else begin
        if (WE) begin
            PCReg <= D_PC;
            instrReg <= D_Instr;
            extReg <= D_EXT;
            rs_data_Reg <= D_Rs_data;
            rt_data_Reg <= D_Rt_data;
            b_jump_reg <= D_B_Jump;
        end
    end
end
    
    assign E_PC = PCReg;
    assign E_Instr = instrReg;
    assign E_EXT = extReg;
    assign E_Rs_data = rs_data_Reg;
    assign E_Rt_data = rt_data_Reg;
    assign E_B_Jump = b_jump_reg;
endmodule