`include "def.v"
module D_CMP (
    input [31:0] RS_Data,
    input [31:0] RT_Data,
    input [2:0] CMPOp,    //提前为其他转移信号留下接口
    output Beq_jump
);

assign Beq_jump = (CMPOp == `CMP_BEQ && RS_Data == RT_Data) ? 1'b1 : 1'b0;
    
endmodule