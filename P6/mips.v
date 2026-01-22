`include "def.v"
module mips (
    input clk,
    input reset,
    input [31:0] i_inst_rdata,      //F级PC对应的32位指令
    input [31:0] m_data_rdata,      //M级DM存储的相应数据
    output [31:0] i_inst_addr,      //F级PC
    output [31:0] m_data_addr,      //M级DM待写入的相应地址
    output [31:0] m_data_wdata,     //M级DM待写入的数据
    output [3:0] m_data_byteen,     //4位字节使能
    output [31:0] m_inst_addr,      //M级PC
    output w_grf_we,                //GRF写使能
    output [4:0] w_grf_addr,        //GRF待写入寄存器编号
    output [31:0] w_grf_wdata,      //GRF中待写入的数据
    output [31:0] w_inst_addr       //W级PC
);

//各级PC和Instr
wire [31:0] F_pc,F_instr,D_pc,D_instr,E_pc,E_instr,M_pc,M_instr,W_pc,W_instr;
//阻塞信号
wire stall;
//各级流水线寄存器使能信号和刷新信号
wire D_reg_flush,E_reg_flush,M_reg_flush,W_reg_flush,D_reg_we,E_reg_we,M_reg_we,W_reg_we;
//PC的使能信号
wire PCwe;
//转发用的信号
wire [4:0] E_GRFa3;  //out
wire [31:0] E_GRFwd;   //out
wire [4:0] M_GRFa3;  //out
wire [4:0] W_GRFa3;
wire [31:0] M_GRFwd,W_GRFwd;

//阻塞用的信号
wire E_start,E_busy;

//阻塞是全局阻塞
STALL g_stall(
    .D_Instr(D_instr),
    .E_Instr(E_instr),
    .M_Instr(M_instr),
    .Start(E_start),
    .Busy(E_busy),
    .Stall(stall)
);

//阻塞影响Flush和流水线寄存器的WE
assign D_reg_we = !stall;
assign E_reg_we = 1;
assign M_reg_we = 1;
assign W_reg_we = 1;
assign PCwe = !stall;
assign D_reg_flush = 0;
assign E_reg_flush = stall;
assign M_reg_flush = 0;
assign W_reg_flush = 0;

//F级
wire [31:0] npc;

F_PC f_pc(
    .NPC(npc),
    .clk(clk),
    .reset(reset),
    .PCWE(PCwe),
    .PC(F_pc)
);

assign i_inst_addr = F_pc;
assign F_instr = i_inst_rdata;

//D级

//D级内部相连需要的信号
wire [4:0] D_rs,D_rt;
wire [15:0] D_imm1;
wire [25:0] D_imm2;
wire [31:0] D_rs_data,D_rt_data;
wire beq_jump;
wire [31:0] D_ext;  //out
//D级的控制信号
wire [2:0] CMPop,NPCop;
wire EXTop;
//D级的转发信号
wire [31:0] D_For_rs_data,D_For_rt_data;

D_reg d_reg(
    .clk(clk),
    .reset(reset),
    .Flush(D_reg_flush),
    .WE(D_reg_we),
    .F_PC(F_pc),
    .F_Instr(F_instr),
    .D_PC(D_pc),
    .D_Instr(D_instr)
);

CTRL d_ctrl(
    .Instr(D_instr),
    .Rs(D_rs),
    .Rt(D_rt),
    .Imm1(D_imm1),
    .Imm2(D_imm2),
    .EXTOp(EXTop),
    .CMPOp(CMPop),
    .NPCOp(NPCop)
);
    
D_EXT d_ext(
    .Imm(D_imm1),
    .Ext(D_ext),
    .EXTOp(EXTop)
);

D_GRF d_grf(
    .PC(W_pc),
    .A1(D_rs),
    .A2(D_rt),
    .A3(W_GRFa3),  //
    .WD(W_GRFwd),   ///
    .clk(clk),
    .reset(reset),
    .RD1(D_rs_data),
    .RD2(D_rt_data)
);

//W级不需要转发，因为W级已经实现了内部转发
assign D_For_rs_data = (D_rs == 5'd0) ? 32'd0 :
                       (D_rs == E_GRFa3) ? E_GRFwd :
                       (D_rs == M_GRFa3) ? M_GRFwd :
                       D_rs_data;
assign D_For_rt_data = (D_rt == 5'd0) ? 32'd0 :
                       (D_rt == E_GRFa3) ? E_GRFwd :
                       (D_rt == M_GRFa3) ? M_GRFwd :
                       D_rt_data;


//下面就需要用到转发数据了
D_NPC d_npc(
    .F_PC(F_pc),
    .D_PC(D_pc),
    .Beq_jump(beq_jump),
    .NPCOp(NPCop),
    .RA(D_For_rs_data),
    .IMM(D_imm2),
    .NPC(npc)
);
D_CMP d_cmp(
    .RS_Data(D_For_rs_data),
    .RT_Data(D_For_rt_data),
    .CMPOp(CMPop),
    .Beq_jump(beq_jump)
);

//E级
//E级内部相连需要的信号
wire [31:0] E_ext;
wire [31:0] E_rs_data,E_rt_data;
wire [4:0] E_rs,E_rt,E_rd;
wire [31:0] E_c;   //out
wire [31:0] ALUb;
wire [31:0] E_MDUc;

//E级内部控制信号
wire [2:0] ALUBsel,E_GRFA3_sel,E_GRFWD_sel;
wire [3:0] ALUop;
wire [3:0] MDUop;

//E级转发信号
wire [31:0] E_For_rs_data,E_For_rt_data;

E_reg e_reg(
    .clk(clk),
    .reset(reset),
    .Flush(E_reg_flush),
    .WE(E_reg_we),
    .D_PC(D_pc),
    .D_Instr(D_instr),
    .D_EXT(D_ext),
    .D_Rs_data(D_For_rs_data),
    .D_Rt_data(D_For_rt_data),
    .E_PC(E_pc),
    .E_Instr(E_instr),
    .E_EXT(E_ext),
    .E_Rs_data(E_rs_data),
    .E_Rt_data(E_rt_data)
);

CTRL e_ctrl(
    .Instr(E_instr),
    .Rs(E_rs),
    .Rt(E_rt),
    .Rd(E_rd),
    .ALUOp(ALUop),
    .ALUBSel(ALUBsel),
    .GRFA3Sel(E_GRFA3_sel),
    .GRFWDSel(E_GRFWD_sel),
    .Start(E_start),
    .MDUOp(MDUop)
);

//没有内部转发，所以把w转发了
assign E_For_rs_data = (E_rs == 5'd0) ? 32'd0 :
                       (E_rs == M_GRFa3) ? M_GRFwd :
                       (E_rs == W_GRFa3) ? W_GRFwd :
                       E_rs_data;
assign E_For_rt_data = (E_rt == 5'd0) ? 32'd0 :
                       (E_rt == M_GRFa3) ? M_GRFwd :
                       (E_rt == W_GRFa3) ? W_GRFwd :
                       E_rt_data;
assign ALUb = (ALUBsel == `ALUBrt) ? E_For_rt_data :
              (ALUBsel == `ALUBimm) ? E_ext :
              32'b0;
assign E_GRFa3 = (E_GRFA3_sel == `GRFA3rt) ? E_rt :
                 (E_GRFA3_sel == `GRFA3rd) ? E_rd :
                 (E_GRFA3_sel == `GRFA331) ? 5'd31 :
                 5'd0;
// assign E_GRFwd = (E_GRFWD_sel == `GRFWDALU) ? E_c :
//                  (E_GRFWD_sel == `GRFWDPC8) ? E_pc + 8 :
//                  32'd0;

assign E_GRFwd = (E_GRFWD_sel == `GRFWDPC8) ? E_pc + 8 : 32'd0;

E_ALU e_alu(
    .A(E_For_rs_data),
    .B(ALUb),
    .ALUOp(ALUop),
    .C(E_c)
);

E_MDU e_mdu(
    .clk(clk),
    .reset(reset),
    .MDUOp(MDUop),
    .A(E_For_rs_data),
    .B(E_For_rt_data),
    .Start(E_start),
    .Busy(E_busy),
    .MDUC(E_MDUc)
);


//M级
//M级内部相连需要的信号
wire [31:0] M_rt_data;
wire [31:0] M_c;
wire [4:0] M_rt;
wire [4:0] M_rd;
wire [31:0] M_DMrd;     //out
wire [31:0] M_MDUc;
//M级控制信号
wire [2:0] M_GRFA3_sel,M_GRFWD_sel,M_BEop,M_DEop;
//M级转发信号
wire [31:0] M_For_rt_data;

M_reg m_reg(
    .Flush(M_reg_flush),
    .WE(M_reg_we),
    .clk(clk),
    .reset(reset),
    .E_PC(E_pc),
    .E_Instr(E_instr),
    .E_Rt_data(E_For_rt_data),
    .E_C(E_c),
    .E_MDU_C(E_MDUc),
    .M_PC(M_pc),
    .M_Instr(M_instr),
    .M_Rt_data(M_rt_data),
    .M_C(M_c),
    .M_MDU_C(M_MDUc)
);

CTRL m_ctrl(
    .Instr(M_instr),
    .Rt(M_rt),
    .Rd(M_rd),
    .GRFWDSel(M_GRFWD_sel),
    .GRFA3Sel(M_GRFA3_sel),
    .BEOp(M_BEop),
    .DEOp(M_DEop)
);
assign M_For_rt_data = (M_rt == 5'd0) ? 32'd0 :
                       (M_rt == W_GRFa3) ? W_GRFwd :
                       M_rt_data;
assign M_GRFa3 = (M_GRFA3_sel == `GRFA3rt) ? M_rt :
                 (M_GRFA3_sel == `GRFA3rd) ? M_rd :
                 (M_GRFA3_sel == `GRFA331) ? 5'd31 :
                 5'd0;
// assign M_GRFwd = (M_GRFWD_sel == `GRFWDALU) ? M_c :
//                  (M_GRFWD_sel == `GRFWDDM) ? M_DMrd :
//                  (M_GRFWD_sel == `GRFWDPC8) ? M_pc + 8 :
//                  32'd0;
assign M_GRFwd = (M_GRFWD_sel == `GRFWDALU) ? M_c :
                 (M_GRFWD_sel == `GRFWDPC8) ? M_pc + 8 :
                 (M_GRFWD_sel == `GRFWDMDU) ? M_MDUc :
                32'd0;

M_BE m_be(
    .BEOp(M_BEop),
    .Addr(M_c),
    .WD(M_For_rt_data),
    .M_Data_Byteen(m_data_byteen),
    .M_Data_Wdata(m_data_wdata)
);

assign m_data_addr = M_c;
assign m_inst_addr = M_pc;

//DE也是CPU的一部分，负责处理DM处理完的不完全的结果 m_data_rdata
M_DE m_de(
    .Addr(M_c),
    .DEOp(M_DEop),
    .M_Data_Rdata(m_data_rdata),
    .RD(M_DMrd)   //这里是经过处理的
);
//W级
//W级内部相连需要的变量
wire [31:0] W_DMrd;
wire [31:0] W_c;
wire [4:0] W_rd;
wire [4:0] W_rt;
wire [2:0] W_GRFA3_sel,W_GRFWD_sel;
wire [31:0] W_MDUc;

W_reg w_reg (
    .clk(clk),
    .reset(reset),
    .Flush(W_reg_flush),
    .WE(W_reg_we),
    .M_PC(M_pc),
    .M_Instr(M_instr),
    .M_RD(M_DMrd),
    .M_C(M_c),
    .M_MDU_C(M_MDUc),
    .W_PC(W_pc),
    .W_Instr(W_instr),
    .W_RD(W_DMrd),
    .W_C(W_c),
    .W_MDU_C(W_MDUc)
);

CTRL w_ctrl (
    .Instr(W_instr),
    .Rd(W_rd),
    .Rt(W_rt),
    .GRFA3Sel(W_GRFA3_sel),
    .GRFWDSel(W_GRFWD_sel)
);

assign W_GRFa3 = (W_GRFA3_sel == `GRFA3rt) ? W_rt :
                 (W_GRFA3_sel == `GRFA3rd) ? W_rd :
                 (W_GRFA3_sel == `GRFA331) ? 5'd31 :
                 5'd0;
assign W_GRFwd = (W_GRFWD_sel == `GRFWDALU) ? W_c :
                 (W_GRFWD_sel == `GRFWDDM) ? W_DMrd :
                 (W_GRFWD_sel == `GRFWDPC8) ? W_pc + 8 :
                 (W_GRFWD_sel == `GRFWDMDU) ? W_MDUc :
                 32'd0;

assign w_grf_we = 1'b1;
assign w_grf_addr = W_GRFa3;
assign w_grf_wdata = W_GRFwd;
assign w_inst_addr = W_pc;
endmodule