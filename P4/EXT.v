`include "def.v"
module EXT (
    input [15:0] imm,
    input EXTOp,
    output [31:0] extend
);

  assign extend = (EXTOp == `EXT_zero) ? {16'b0, imm} : {{16{imm[15]}}, imm};

endmodule