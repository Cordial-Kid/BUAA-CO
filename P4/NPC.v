`include "def.v"
module NPC (
    input [31:0] RA,
    input [31:0] PC,
    input zero,
    input [2:0] npcOp,
    input [25:0] imm,
    output [31:0] NPC,
    output [31:0] PC_4
);

  wire [31:0] IMM_BEQ;
  wire [31:0] IMM_JAL;

  assign IMM_BEQ = {{14{imm[15]}}, imm[15:0], 2'b0} + PC + 4;
  assign IMM_JAL = {PC[31:28], imm, 2'b0};
  assign PC_4 = PC + 4;
  assign NPC = (npcOp == `NPC_PC_4) ? PC + 4 :
             (npcOp == `NPC_BEQ && zero == 0) ? PC + 4:
             (npcOp == `NPC_BEQ && zero != 0) ? IMM_BEQ:
             (npcOp == `NPC_JAL) ? IMM_JAL:
             (npcOp == `NPC_JR) ? RA : PC_4;
endmodule