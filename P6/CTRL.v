// 开头译码会导致每个流水线寄存器传递大量数据，因此选择CTRL在每一级分别译码
`include "def.v"
module CTRL (
    input [31:0] Instr,
      
    output [4:0] Rs,     //转发冲突判断
    output [4:0] Rt,     //转发冲突判断
    output [4:0] Rd,     //转发冲突判断的待选择信号
    output [15:0] Imm1,  //EXT用
    output [25:0] Imm2,  //NPC用

    output EXTOp,
    output [2:0] CMPOp,
    output [2:0] NPCOp,
    output [3:0] ALUOp,
    output [2:0] ALUBSel,
    output [2:0] GRFWDSel,
    output [2:0] GRFA3Sel,
    output [2:0] BEOp,
    output [2:0] DEOp,
    // output DMWE,
    output Start,
    output [3:0] MDUOp,
    
    output Add, Sub, _And, _Or, Slt, Sltu, Lui,
    output Addi,Andi,Ori,
    output Lb,Lh,Lw,Sb,Sh,Sw,
    output Mult,Multu,Div,Divu,Mfhi,Mflo,Mthi,Mtlo,
    output Beq,Bne,Jal,Jr,
    output J,Jalr,Sll
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
    assign _And = (func == `_AND) && (opcode == `SPECIAL);
    assign _Or = (opcode == `SPECIAL) && (func == `_OR);
    assign Slt = (opcode == `SPECIAL) && (func == `SLT);
    assign Sltu = (opcode == `SPECIAL) && (func == `SLTU);
    assign Addi = (opcode == `ADDI);
    assign Andi = (opcode == `ANDI);
    assign Lh = (opcode == `LH);
    assign Lb = (opcode == `LB);
    assign Sh = (opcode == `SH);
    assign Sb = (opcode == `SB);
    assign Bne = (opcode == `BNE);
    assign Mult = (opcode == `SPECIAL) && (func == `MULT);
    assign Multu = (opcode == `SPECIAL) && (func == `MULTU);
    assign Div = (opcode == `SPECIAL) && (func == `DIV);
    assign Divu = (opcode == `SPECIAL) && (func == `DIVU);
    assign Mfhi = (opcode == `SPECIAL) && (func == `MFHI);
    assign Mflo = (opcode == `SPECIAL) && (func == `MFLO);
    assign Mthi = (opcode == `SPECIAL) && (func == `MTHI);
    assign Mtlo = (opcode == `SPECIAL) && (func == `MTLO);


//在这里译出控制信号
    assign EXTOp = (Lw | Sw | Addi | Lh | Lb | Sh | Sb) ? `EXT_SIGN : `EXT_ZERO;

    assign CMPOp = (Beq) ? `CMP_BEQ :
                   (Bne) ? `CMP_BNE :
                   `CMP_BEQ;       //这里可以选其他

    assign NPCOp = (Beq | Bne) ? `NPC_BEQ :
                   (J | Jal) ? `NPC_J_Jal :
                   (Jr | Jalr) ? `NPC_Jr_Jalr :
                   `NPC_PC4;

    assign ALUOp = (Add | Addi) ? `ALU_add :
                   (Sub) ? `ALU_sub :
                   (Ori | _Or) ? `ALU_ori :
                   (Lui) ? `ALU_lui :
                   (Sll) ? `ALU_sll :
                   (_And | Andi) ? `ALU_and :
                   (Slt) ? `ALU_slt :
                   (Sltu) ? `ALU_sltu :
                   `ALU_add;        //lw和sw也用加

    assign ALUBSel = (Ori | Lui | Sll | Lw | Sw | Addi | Andi | Lh | Lb | Sh | Sb) ? `ALUBimm : `ALUBrt;

    assign GRFWDSel = (Add | Sub | Ori | Lui | Sll | _And | _Or | Slt | Sltu | Addi | Andi) ? `GRFWDALU :
                      (Lw | Lh | Lb) ? `GRFWDDM :
                      (Jal | Jalr) ? `GRFWDPC8 :
                      (Mfhi | Mflo) ? `GRFWDMDU :
                       `GRFWDALU;

    assign GRFA3Sel = (Add | Sub | Sll | Jalr | _And | _Or | Slt | Sltu | Mfhi | Mflo) ? `GRFA3rd :
                      (Ori | Lw | Lui | Addi | Andi | Lh | Lb) ? `GRFA3rt :
                      (Jal) ? `GRFA331 :
                      `GRFA30;

    assign DEOp = (Lw) ? `DE_LW :
                  (Lh) ? `DE_LH :
                  (Lb) ? `DE_LB :
                  `DE_LW;

    assign BEOp = (Sw) ? `BE_SW :
                  (Sh) ? `BE_SH :
                  (Sb) ? `BE_SB :
                  `BE_NULL;

    // assign DMWE = (Sw) ? `DMWE_ONE : `DMWE_ZERO;

    assign GRFWE = (Add | Sub | Sll | Jalr | _And | _Or | Slt | Sltu | Ori | Lw | Lui | Addi | Andi | Lh | Lb | Jal | Mfhi | Mflo);

    assign MDUOp = (Mult) ? `MDU_MULT :
                   (Multu) ? `MDU_MULTU :
                   (Mfhi) ? `MDU_MFHI :
                   (Mflo) ? `MDU_MFLO :
                   (Mthi) ? `MDU_MTHI :
                   (Mtlo) ? `MDU_MTLO :
                   (Div) ? `MDU_DIV :
                   (Divu) ? `MDU_DIVU :
                   `MDU_NULL;
                
    assign Start = Mult | Multu | Div | Divu;
endmodule

    // output Load,
    // output Store,
    // output Calr,
    // output Cali,
    // output MCal,
    // output Mf,
    // output Mt,
    // output Jump_addr,
    // output Jump_link,
    // output Jump_reg,
    // output Branch,
    // output Sll