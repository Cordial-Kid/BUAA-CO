// Tuse和Tnew的大小决定是否需要暂停
// CTRL有两个用处
`include "def.v"
module STALL (
    input [31:0] D_Instr,  
    input [31:0] E_Instr,
    input [31:0] M_Instr,
    output Stall
);
    wire [31:0] D_instr,E_instr,M_instr;
    assign D_instr = D_Instr;
    assign E_instr = E_Instr;
    assign M_instr = M_Instr;
//要看阻不阻塞，先算Tuse和Tnew

    wire D_add,D_sub,D_ori,D_lw,D_sw,D_beq,D_lui,D_sll,D_j,D_jr,D_jal,D_jalr;
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
    .Jalr(D_jalr)
);

//D级只有Tuse
wire [2:0] rs_Tuse,rt_Tuse;

assign rs_Tuse = (D_beq | D_jr | D_jalr) ? 3'd0 :
                 (D_add | D_sub | D_ori | D_lw | D_sw | D_lui) ? 3'd1 :
                 3'd3;   //用不到的设的大一点就不会导致阻塞了
    
assign rt_Tuse = (D_beq ) ? 3'd0 :
                 (D_add | D_sub | D_sll) ? 3'd1 :
                 (D_sw) ? 3'd2 :
                 3'd3;


wire E_add,E_sub,E_ori,E_lw,E_sw,E_beq,E_lui,E_sll,E_j,E_jr,E_jal,E_jalr;
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
    .Jalr(E_jalr)
);

// 它经过多少个时钟周期可以算出结果并且存储到流水级寄存器里
// rs和rt的Tnew是一样的
wire [2:0] E_Tnew;

assign E_Tnew = (E_add | E_sub | E_ori | E_lui | E_sll ) ? 3'd1 :
                (E_lw) ? 3'd2 :
                3'd0;   //用不到的设小一点就不会阻塞了

assign E_GRFA3 = (E_GRFA3_sel == `GRFA3rt) ? E_rt :
                 (E_GRFA3_sel == `GRFA3rd) ? E_rd :
                 (E_GRFA3_sel == `GRFA331) ? 5'd31 : 
                 5'd0;

wire M_add,M_sub,M_ori,M_lw,M_sw,M_beq,M_lui,M_sll,M_j,M_jr,M_jal,M_jalr;
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
    .Jalr(M_jalr)
);

wire [2:0] M_Tnew;
assign M_Tnew = (M_lw) ? 3'd1 : 3'd0;
assign M_GRFA3 = (M_GRFA3_sel == `GRFA3rt) ? M_rt :
                 (M_GRFA3_sel == `GRFA3rd) ? M_rd :
                 (M_GRFA3_sel == `GRFA331) ? 5'd31 :
                 5'd0;

                 
// 目前只可能是GRF的读写冲突
// E级导致的阻塞，rs读写冲突
// 给0赋值默认不需要阻塞
wire E_stall_rs,E_stall_rt,M_stall_rs,M_stall_rt;
assign E_stall_rs = (D_rs == E_GRFA3 && (D_rs != 0)) && (rs_Tuse < E_Tnew);
assign E_stall_rt = (D_rt == E_GRFA3 && (D_rt != 0)) && (rt_Tuse < E_Tnew);
assign M_stall_rs = (D_rs == M_GRFA3 && (D_rs != 0)) && (rs_Tuse < M_Tnew);
assign M_stall_rt = (D_rt == M_GRFA3 && (D_rt != 0)) && (rt_Tuse < M_Tnew);
assign Stall = E_stall_rs | E_stall_rt | M_stall_rs | M_stall_rt;
endmodule