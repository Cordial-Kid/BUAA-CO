// Tuse和Tnew的大小决定是否需要暂停
// CTRL有两个用处
`include "def.v"
module STALL (
    input [31:0] D_Instr,  
    input [31:0] E_Instr,
    input [31:0] M_Instr,
    input Start,
    input Busy,
    output Stall
);
    wire [31:0] D_instr,E_instr,M_instr;
    assign D_instr = D_Instr;
    assign E_instr = E_Instr;
    assign M_instr = M_Instr;
//要看阻不阻塞，先算Tuse和Tnew

    wire D_add,D_sub,D_ori,D_lui,D_sll,D_j,D_jr,D_jal,D_jalr;
    wire D_and,D_or,D_slt,D_sltu,D_addi,D_andi;
    wire D_lh,D_lb,D_lw;
    wire D_sh,D_sb,D_sw;
    wire D_bne,D_beq;
    wire D_mult,D_multu,D_div,D_divu,D_mfhi,D_mflo,D_mthi,D_mtlo;
    wire [4:0] D_rs,D_rt;   //这是要读的寄存器

CTRL D_Ctrl (
    .Instr(D_instr),
    //output
    .Rs(D_rs),
    .Rt(D_rt),
    .Add(D_add),
    .Sub(D_sub),
    .Ori(D_ori),
    .Lw(D_lw),
    .Sw(D_sw),
    .Beq(D_beq),
    .Lui(D_lui),
    .Sll(D_sll),
    .J(D_j),
    .Jr(D_jr),
    .Jal(D_jal),
    .Jalr(D_jalr),
    ._And(D_and),
    ._Or(D_or),
    .Slt(D_slt),
    .Sltu(D_sltu),
    .Addi(D_addi),
    .Andi(D_andi),
    .Lh(D_lh),
    .Lb(D_lb),
    .Sh(D_sh),
    .Sb(D_sb),
    .Bne(D_bne),
    .Mult(D_mult),
    .Multu(D_multu),
    .Div(D_div),
    .Divu(D_divu),
    .Mfhi(D_mfhi),
    .Mflo(D_mflo),
    .Mthi(D_mthi),
    .Mtlo(D_mtlo)
);

//D级只有Tuse
wire [2:0] rs_Tuse,rt_Tuse;

assign rs_Tuse = (D_beq | D_jr | D_jalr | D_bne) ? 3'd0 :
                 (D_add | D_sub | D_ori | D_lw | D_sw | D_lui | D_and | D_or | D_slt | D_sltu | D_addi | D_andi | D_lh | D_lb | D_sh | D_sb | D_mult | D_multu | D_div | D_divu | D_mthi | D_mtlo) ? 3'd1 :
                 3'd3;   //用不到的设的大一点就不会导致阻塞了
    
assign rt_Tuse = (D_beq | D_bne) ? 3'd0 :
                 (D_add | D_sub | D_sll | D_and | D_or | D_slt | D_sltu | D_mult | D_multu | D_div | D_divu) ? 3'd1 :
                 (D_sw | D_sh | D_sb) ? 3'd2 :
                 3'd3;


wire E_add,E_sub,E_ori,E_lw,E_sw,E_beq,E_lui,E_sll,E_j,E_jr,E_jal,E_jalr;
wire E_and,E_or,E_slt,E_sltu,E_addi,E_andi;
wire E_lh,E_lb;
wire E_mfhi,E_mflo;
wire [2:0] E_GRFA3_sel;   //与rs，rt相比，是否冲突的判断条件
wire [4:0] E_GRFA3;
wire [4:0] E_rt;
wire [4:0] E_rd;

CTRL E_Ctrl (
    .Instr(E_instr),
    //output
    .GRFA3Sel(E_GRFA3_sel),
    .Rt(E_rt),
    .Rd(E_rd),
    .Add(E_add),
    .Sub(E_sub),
    .Ori(E_ori),
    .Lw(E_lw),
    .Sw(E_sw),
    .Beq(E_beq),
    .Lui(E_lui),
    .Sll(E_sll),
    .J(E_j),
    .Jr(E_jr),
    .Jal(E_jal),
    .Jalr(E_jalr),
    ._And(E_and),
    ._Or(E_or),
    .Slt(E_slt),
    .Sltu(E_sltu),
    .Addi(E_addi),
    .Andi(E_andi),
    .Lh(E_lh),
    .Lb(E_lb),
    .Mfhi(E_mfhi),
    .Mflo(E_mflo)
);

// 它经过多少个时钟周期可以算出结果并且存储到流水级寄存器里
// rs和rt的Tnew是一样的
wire [2:0] E_Tnew;

assign E_Tnew = (E_add | E_sub | E_ori | E_lui | E_sll | E_and | E_or | E_slt | E_sltu | E_addi | E_andi | E_mfhi | E_mflo) ? 3'd1 :
                (E_lw | E_lh | E_lb) ? 3'd2 :
                3'd0;   //用不到的设小一点就不会阻塞了

assign E_GRFA3 = (E_GRFA3_sel == `GRFA3rt) ? E_rt :
                 (E_GRFA3_sel == `GRFA3rd) ? E_rd :
                 (E_GRFA3_sel == `GRFA331) ? 5'd31 : 
                 5'd0;

wire M_add,M_sub,M_ori,M_lw,M_sw,M_beq,M_lui,M_sll,M_j,M_jr,M_jal,M_jalr;
wire M_lh,M_lb;
wire [2:0] M_GRFA3_sel;   
wire [4:0] M_GRFA3;
wire [4:0] M_rt;
wire [4:0] M_rd;

CTRL M_Ctrl (
    .Instr(M_instr),
    .GRFA3Sel(M_GRFA3_sel),
    .Rt(M_rt),
    .Rd(M_rd),
    .Add(M_add),
    .Sub(M_sub),
    .Ori(M_ori),
    .Lw(M_lw),
    .Sw(M_sw),
    .Beq(M_beq),
    .Lui(M_lui),
    .Sll(M_sll),
    .J(M_j),
    .Jr(M_jr),
    .Jal(M_jal),
    .Jalr(M_jalr),
    .Lh(M_lh),
    .Lb(M_lb)
);

wire [2:0] M_Tnew;
assign M_Tnew = (M_lw | M_lh | M_lb) ? 3'd1 : 3'd0;
assign M_GRFA3 = (M_GRFA3_sel == `GRFA3rt) ? M_rt :
                 (M_GRFA3_sel == `GRFA3rd) ? M_rd :
                 (M_GRFA3_sel == `GRFA331) ? 5'd31 :
                 5'd0;

                 
// 目前只可能是GRF的读写冲突
// E级导致的阻塞，rs读写冲突
// 给0赋值默认不需要阻塞
wire E_stall_rs,E_stall_rt,M_stall_rs,M_stall_rt,E_stall_MDU;
assign E_stall_rs = (D_rs == E_GRFA3 && (D_rs != 0)) && (rs_Tuse < E_Tnew);
assign E_stall_rt = (D_rt == E_GRFA3 && (D_rt != 0)) && (rt_Tuse < E_Tnew);
assign M_stall_rs = (D_rs == M_GRFA3 && (D_rs != 0)) && (rs_Tuse < M_Tnew);
assign M_stall_rt = (D_rt == M_GRFA3 && (D_rt != 0)) && (rt_Tuse < M_Tnew);

assign E_stall_MDU = ((D_mult | D_multu | D_div | D_divu | D_mfhi | D_mflo | D_mthi | D_mtlo) && (Start | Busy));

assign Stall = E_stall_rs | E_stall_rt | M_stall_rs | M_stall_rt | E_stall_MDU;
endmodule