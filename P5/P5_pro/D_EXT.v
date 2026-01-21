`include "def.v" 
module D_EXT (
    input [15:0] Imm,
    output [31:0] Ext,
    input EXTOp
);
    assign Ext = (EXTOp == 1) ? {{16{Imm[15]}},Imm} : {16'b0,Imm};
endmodule