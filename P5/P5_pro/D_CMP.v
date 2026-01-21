`include "def.v"
module D_CMP (
    input [31:0] RS_Data,
    input [31:0] RT_Data,
    input [2:0] CMPOp,    //提前为其他转移信号留下接口
    output B_jump,
    output Flush_check
);

reg isop;
always @(*) begin
    if (RS_Data == 32'h80000000 && RT_Data == 32'h80000000) begin
        isop = 0;
    end
    else if(RS_Data + RT_Data == 0) begin
        isop = 1;
    end
    else begin
        isop = 0;
    end
end

assign B_jump = (CMPOp == `CMP_BEQ && RS_Data == RT_Data) ? 1'b1 :
                  (CMPOp == `CMP_BLZTAL && RS_Data[31] == 1) ? 1'b1 :
                  (CMPOp == `CMP_BONALL && isop == 1) ? 1'b1 :
                  1'b0;
assign Flush_check = (CMPOp == `CMP_BONALL && !B_jump);
    
endmodule