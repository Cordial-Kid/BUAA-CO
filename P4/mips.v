//当只有两个接口时名字可以都一样
// always change ALU,CTRL
// sometimes NPC
`include "def.v"
    
module mips (
    input clk,
    input reset
);

  wire [2:0] NPCOp, WDSel, WRA3Sel, ALUOp;
  wire WESel, BSel, EXTOp, DMWr;
  wire [5:0] opcode;
  wire [5:0] func;

  DATAPATH datapath (
      .clk(clk),
      .reset(reset),
      .NPCOp(NPCOp),
      .WDSel(WDSel),
      .WESel(WESel),
      .WRA3Sel(WRA3Sel),
      .ALUOp(ALUOp),
      .BSel(BSel),
      .EXTOp(EXTOp),
      .DMWr(DMWr),
      .opcode(opcode),  //out
      .func(func)     //out
  );
  
  CTRL ctrl ( 
      .opcode(opcode),
      .func(func),
      .NPCOp(NPCOp),
      .WDSel(WDSel),
      .WESel(WESel),
      .WRA3Sel(WRA3Sel),
      .ALUOp(ALUOp),
      .BSel(BSel),
      .EXTOp(EXTOp),
      .DMWr(DMWr)
  );

endmodule