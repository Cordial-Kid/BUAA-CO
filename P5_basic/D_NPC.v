//为什么NPC在D级
//为什么会输入D_PC 和F_PC
`include "def.v"
module D_NPC (
    input [31:0] F_PC,   //正常计算F_PC+4
    input [31:0] D_PC,   //流水
    input Beq_jump,
    input [2:0] NPCOp,
    input [31:0] RA,     //jr和jalr用
    input [25:0] IMM,
    output [31:0] NPC
    );

    wire [31:0] PC_4;
    wire [31:0] IMM_BEQ,IMM_J_Jal;

    assign PC_4 = F_PC + 4;
    assign IMM_BEQ = {{14{IMM[15]}},IMM[15:0],2'b0} + D_PC + 4;
    assign IMM_J_Jal = {D_PC[31:28],IMM,2'b0};   

    assign NPC = (NPCOp == `NPC_PC4) ? PC_4 :
                 (NPCOp == `NPC_BEQ && Beq_jump == 1) ? IMM_BEQ :
                 (NPCOp == `NPC_BEQ && Beq_jump == 0) ? PC_4:
                 (NPCOp == `NPC_J_Jal) ? IMM_J_Jal :
                 (NPCOp == `NPC_Jr_Jalr) ? RA : PC_4;

endmodule