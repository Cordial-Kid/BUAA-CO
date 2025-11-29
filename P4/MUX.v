module MUX (
    input  [4:0] WRA3MUX1,
    input  [4:0] WRA3MUX2,
    input  [4:0] WRA3MUX3,
    input  [2:0] WRA3Sel,
    output [4:0] A3,

    input  [31:0] WDMUX1,
    input  [31:0] WDMUX2,
    input  [31:0] WDMUX3,
    input  [31:0] WDMUX4,
    input  [ 2:0] WDSel,
    output [31:0] WD,

    input [31:0] BMUX1,
    input [31:0] BMUX2,
    input BSel,
    output [31:0] ALU_B
);
  assign A3 = (WRA3Sel == 3'b0) ? WRA3MUX1 :
                (WRA3Sel == 3'b1) ? WRA3MUX2 :
                (WRA3Sel == 3'd2) ? WRA3MUX3 :
                0;

  assign WD = (WDSel == 3'b0) ? WDMUX1 : (WDSel == 3'b1) ? WDMUX2 : (WDSel == 3'd2) ? WDMUX3 : (WDSel == 3'd3) ? WDMUX4 : 0;

  assign ALU_B = (BSel == 1'b0) ? BMUX1 : (BSel == 1'b1) ? BMUX2 : 0;
endmodule
