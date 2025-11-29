// 相当于在对datapath做封装
`include "def.v"
module DATAPATH (
    input clk,
    input reset,
    input [2:0] NPCOp,
    input [2:0] WDSel,
    input WESel,
    input [2:0] WRA3Sel,
    input [2:0] ALUOp,
    input BSel,
    input EXTOp,
    input DMWr,
    output [5:0] opcode,
    output [5:0] func
);

  // 首先对模块实例化，其次要定义连线，
  // 这里定义的wire是真的wire
  wire [31:0] ifu_pc;
  wire ALU_zero;
  wire [31:0] instr;
  wire [31:0] IFU_npc;
  wire [31:0] NPC_pc_4;
  wire [4:0] grf_A3;
  wire [31:0] grf_WD;
  wire [31:0] grf_RD1;
  wire [31:0] grf_RD2;
  wire [31:0] ALU_C;
  wire [31:0] ext_imm;
  wire [31:0] ALU_B;
  wire [31:0] dm_rd;
  wire [31:0] dm_sub_rd;

  MUX mux (
      .WRA3MUX1(instr[20:16]),
      .WRA3MUX2(instr[15:11]),
      .WRA3MUX3(5'h1f),
      .WRA3Sel (WRA3Sel),

      .WDMUX1(ALU_C),
      .WDMUX2(dm_rd),
      .WDMUX3(NPC_pc_4),
      .WDMUX4(dm_sub_rd),
      .WDSel (WDSel),

      .BMUX1(grf_RD2),
      .BMUX2(ext_imm),
      .BSel (BSel),

      //output
      .A3(grf_A3),
      .WD(grf_WD),
      .ALU_B(ALU_B)
  );

  IFU ifu (
      .NPC(IFU_npc),
      .PC(ifu_pc),
      .instruct(instr),
      .clk(clk),  //out
      .reset(reset)  //out
  );

  NPC npc (
      .PC(ifu_pc),
      .RA(grf_RD1),
      .zero(ALU_zero),
      .npcOp(NPCOp),
      .imm(instr[25:0]),
      .NPC(IFU_npc),  //out
      .PC_4(NPC_pc_4)  //out
  );

  GRF grf (
      .PC(ifu_pc),
      .A1(instr[25:21]),
      .A2(instr[20:16]),
      .A3(grf_A3),
      .WD(grf_WD),
      .WE(WESel),
      .clk(clk),
      .reset(reset),
      .RD1(grf_RD1),  //out
      .RD2(grf_RD2)  // out
  );

  ALU alu (
      .PC(ifu_pc),
      .A(grf_RD1),
      .B(ALU_B),
      .ALUOp(ALUOp),
      .shamt(instr[10:6]),
      .C(ALU_C),
      .zero(ALU_zero)
  );

  DM dm (
      .PC(ifu_pc),
      .addr(ALU_C),
      .WD(grf_RD2),
      .WR(DMWr),
      .clk(clk),
      .reset(reset),
      .RD(dm_rd),  //out
      .sub_RD(dm_sub_rd)  //out
  );

  EXT ext (
      .imm(instr[15:0]),
      .EXTOp(EXTOp),
      .extend(ext_imm)  ///out
  );

  assign opcode = instr[31:26];
  assign func   = instr[5:0];

endmodule
