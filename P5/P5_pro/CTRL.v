// 开头译码会导致每个流水线寄存器传递大量数据，因此选择CTRL在每一级分别译码
`include "def.v"
module CTRL (
    input [31:0] Instr,
    input Condition1,   //lbget
    input Blztal_jump,    //blztal
      
    output [4:0] Rs,     //转发冲突判断
    output [4:0] Rt,     //转发冲突判断
    output [4:0] Rd,     //转发冲突判断的待选择信号
    output [15:0] Imm1,  //EXT用
    output [25:0] Imm2,  //NPC用

    output EXTOp,
    output [2:0] CMPOp,
    output [2:0] NPCOp,
    output [2:0] ALUOp,
    output [2:0] DMOp,
    output ALUBSel,
    output [2:0] GRFWDSel, 
    output [2:0] GRFA3Sel,
    output DMWE,

    output Add,
    output Sub,
    output Ori,
    output Lw,
    output Sw,
    output Beq,
    output Lui,
    output Sll,
    output J,
    output Jal,
    output Jr,
    output Jalr,
    output Blztal,
    output Lbget,
    output Bonall
);

    wire [5:0] opcode,func;

    assign opcode = Instr[31:26];
    assign func = Instr[5:0];
    assign Rs = Instr[25:21];
    assign Rt = Instr[20:16];
    assign Rd = Instr[15:11];
    assign Imm1 = Instr[15:0];
    assign Imm2 = Instr[25:0];

    assign Add = (opcode == `SPECIAL) && (func == `ADD);
    assign Sub = (opcode == `SPECIAL) && (func == `SUB);
    assign Ori = (opcode == `ORI);
    assign Lw = (opcode == `LW);
    assign Sw = (opcode == `SW);
    assign Beq = (opcode == `BEQ);
    assign Lui = (opcode == `LUI);
    assign Sll = (func == `SLL) && (opcode == `SPECIAL);
    assign J = (opcode == `J);
    assign Jal = (opcode == `JAL);
    assign Jr = (func == `JR) && (opcode == `SPECIAL);
    assign Jalr = (func == `JALR) && (opcode == `SPECIAL);
    assign Blztal = (opcode == `BLZTAL);
    assign Lbget = (opcode == `LBGET);
    assign Bonall = (opcode == `BONALL);

//在这里译出控制信号
    assign EXTOp = (Lw | Sw | Lbget) ? `EXT_SIGN : `EXT_ZERO;

    assign CMPOp = (Beq) ? `CMP_BEQ : 
                   (Blztal) ? `CMP_BLZTAL :
                   (Bonall) ? `CMP_BONALL :
                   `CMP_BEQ;       //这里可以选其他

    assign NPCOp = (Beq) ? `NPC_BEQ :
                   (J | Jal) ? `NPC_J_Jal :
                   (Jr | Jalr) ? `NPC_Jr_Jalr :
                   (Blztal) ? `NPC_BLZTAL :
                   (Bonall) ? `NPC_BONALL :
                   `NPC_PC4;

    assign ALUOp = (Add) ? `ALU_add :
                   (Sub) ? `ALU_sub :
                   (Ori) ? `ALU_ori :
                   (Lui) ? `ALU_lui :
                   (Sll) ? `ALU_sll :
                   `ALU_add;        //lw和sw也用加

    assign ALUBSel = (Ori | Lui | Sll | Lw | Sw | Lbget) ? `ALUBimm : `ALUBrt;

    assign GRFWDSel = (Add | Sub | Ori | Lui | Sll ) ? `GRFWDALU :
                      (Lw | Lbget) ? `GRFWDDM :
                      (Jal | Jalr | (Blztal && Blztal_jump) | Bonall) ? `GRFWDPC8 : `GRFWDALU;

    assign GRFA3Sel = (Add | Sub | Sll | Jalr) ? `GRFA3rd :
                      (Ori | Lw | Lui ) ? `GRFA3rt :
                      (Jal | (Blztal && Blztal_jump) | Bonall) ? `GRFA331 :
                      `GRFA30;

    assign DMWE = (Sw) ? `DMWE_ONE : `DMWE_ZERO;

    assign DMOp = (Lbget) ? `DMOPLBGET :
                  `DMOPBASE;

endmodule