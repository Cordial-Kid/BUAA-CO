//为什么NPC在D级
//为什么会输入D_PC 和F_PC
`include "def.v"
module D_NPC (
    input [31:0] F_PC,   //正常计算F_PC+4
    input [31:0] D_PC,   //流水
    input B_jump,
    input [2:0] NPCOp,
    input [31:0] RA,     //jr和jalr用
    input [25:0] IMM,
    input [31:0] RT_Data,   //新增接口
    output [31:0] NPC
    );

    wire [31:0] PC_4;
    wire [31:0] IMM_BEQ,IMM_J_Jal;
    wire [31:0] IMM_BLZTAL;          //这条指令要用rt,需要更改阻塞和转发的相关设置，在mips里面给接口接全
    wire [31:0] tmp1_blztal;
    wire [31:0] tmp2_blztal;
    wire [31:0] tmp3_blztal;
    wire [31:0] IMM_BONALL;

    assign PC_4 = F_PC + 4;
    assign IMM_BEQ = {{14{IMM[15]}},IMM[15:0],2'b0} + D_PC + 4;   //正常写在指令集里面的PC就是D_PC
    assign IMM_BONALL = {{14{IMM[15]}},IMM[15:0],2'b0} + D_PC + 4;
    assign IMM_J_Jal = {D_PC[31:28],IMM,2'b0};   
    assign tmp1_blztal = 2 + RT_Data[1:0];
    assign tmp2_blztal = IMM[15:0] << tmp1_blztal;
    assign tmp3_blztal = $signed(tmp2_blztal) << (16 - tmp1_blztal) >>> (16 - tmp1_blztal);
    assign IMM_BLZTAL = tmp3_blztal + F_PC;

    assign NPC = (NPCOp == `NPC_PC4) ? PC_4 :
                 (NPCOp == `NPC_BEQ && B_jump == 1) ? IMM_BEQ :
                 (NPCOp == `NPC_BEQ && B_jump == 0) ? PC_4:
                 (NPCOp == `NPC_J_Jal) ? IMM_J_Jal :
                 (NPCOp == `NPC_Jr_Jalr) ? RA : 
                 (NPCOp == `NPC_BLZTAL && B_jump == 1) ? IMM_BLZTAL :
                 (NPCOp == `NPC_BONALL && B_jump == 1) ? IMM_BONALL :
                 PC_4;

endmodule