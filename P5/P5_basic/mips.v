`include "def.v"
module mips (
    input clk,
    input reset
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

//阻塞是全局阻塞
STALL g_stall(
    .D_Instr(D_instr),
    .E_Instr(E_instr),
    .M_Instr(M_instr),
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

F_IFU f_ifu(
    .NPC(npc),
    .clk(clk),
    .reset(reset),
    .PCWE(PCwe),
    .PC(F_pc),
    .Instr(F_instr)
);

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

//E级内部控制信号
wire [2:0] ALUop,ALUBsel,E_GRFA3_sel,E_GRFWD_sel;
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
    .GRFWDSel(E_GRFWD_sel)
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
assign E_GRFwd = (E_GRFWD_sel == `GRFWDALU) ? E_c :
                 (E_GRFWD_sel == `GRFWDPC8) ? E_pc + 8 :
                 32'd0;

// assign E_GRFwd = (E_GRFWD_sel == `GRFWDPC8) ? E_pc + 8 : 32'd0;

E_ALU e_alu(
    .A(E_For_rs_data),
    .B(ALUb),
    .ALUOp(ALUop),
    .C(E_c)
);

//M级
//M级内部相连需要的信号
wire [31:0] M_rt_data;
wire [31:0] M_c;
wire [4:0] M_rt;
wire [4:0] M_rd;
wire [31:0] M_DMrd;     //out
//M级控制信号
wire [2:0] M_GRFA3_sel,M_GRFWD_sel;
wire DMwe;
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
    .M_PC(M_pc),
    .M_Instr(M_instr),
    .M_Rt_data(M_rt_data),
    .M_C(M_c)
);

CTRL m_ctrl(
    .Instr(M_instr),
    .Rt(M_rt),
    .Rd(M_rd),
    .GRFWDSel(M_GRFWD_sel),
    .GRFA3Sel(M_GRFA3_sel),
    .DMWE(DMwe)
);
assign M_For_rt_data = (M_rt == 5'd0) ? 32'd0 :
                       (M_rt == W_GRFa3) ? W_GRFwd :
                       M_rt_data;
assign M_GRFa3 = (M_GRFA3_sel == `GRFA3rt) ? M_rt :
                 (M_GRFA3_sel == `GRFA3rd) ? M_rd :
                 (M_GRFA3_sel == `GRFA331) ? 5'd31 :
                 5'd0;
assign M_GRFwd = (M_GRFWD_sel == `GRFWDALU) ? M_c :
                 (M_GRFWD_sel == `GRFWDDM) ? M_DMrd :
                 (M_GRFWD_sel == `GRFWDPC8) ? M_pc + 8 :
                 32'd0;
// assign M_GRFwd = (M_GRFWD_sel == `GRFWDALU) ? M_c :
//                  (M_GRFWD_sel == `GRFWDPC8) ? M_pc + 8 :
//                 32'd0;

M_DM m_dm(
    .clk(clk),
    .reset(reset),
    .DMWE(DMwe),
    .PC(M_pc),
    .Addr(M_c),
    .WD(M_For_rt_data),
    .RD(M_DMrd)
);

//W级
//W级内部相连需要的变量
wire [31:0] W_DMrd;
wire [31:0] W_c;
wire [4:0] W_rd;
wire [4:0] W_rt;
wire [2:0] W_GRFA3_sel,W_GRFWD_sel;

W_reg w_reg (
    .clk(clk),
    .reset(reset),
    .Flush(W_reg_flush),
    .WE(W_reg_we),
    .M_PC(M_pc),
    .M_Instr(M_instr),
    .M_RD(M_DMrd),
    .M_C(M_c),
    .W_PC(W_pc),
    .W_Instr(W_instr),
    .W_RD(W_DMrd),
    .W_C(W_c)
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
                 32'd0;
endmodule