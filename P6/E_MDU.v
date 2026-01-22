`include "def.v"
module E_MDU (
    input clk,
    input reset,
    input [3:0] MDUOp,
    input [31:0] A,
    input [31:0] B,
    input Start,

    output Busy,
    output [31:0] MDUC
);

reg [31:0] HIreg,LOreg;
reg [3:0] cnt;

initial begin
    HIreg = 32'b0;
    LOreg = 32'b0;
    cnt = 4'b0;
end

always @(posedge clk) begin
    if (reset) begin
        HIreg <= 32'b0;
        LOreg <= 32'b0;
        cnt <= 4'b0;
    end
    else begin
        if (MDUOp == `MDU_MULT) begin
            {HIreg,LOreg} <= $signed(A) * $signed(B);
        end
        else if (MDUOp == `MDU_MULTU) begin
            {HIreg,LOreg} <= A * B;
        end
        else if (MDUOp == `MDU_DIV) begin
            HIreg <= $signed(A) % $signed(B);
            LOreg <= $signed(A) / $signed(B); 
        end
        else if (MDUOp == `MDU_DIVU) begin
            HIreg <= A % B;
            LOreg <= A / B;
        end
        else if (MDUOp == `MDU_MTHI) begin
            HIreg <= A;
        end
        else if (MDUOp == `MDU_MTLO) begin
            LOreg <= A;
        end

        if (Start) begin
            if (MDUOp == `MDU_DIV || MDUOp == `MDU_DIVU) begin
                cnt <= 4'd10;
            end
            else if(MDUOp == `MDU_MULT || MDUOp == `MDU_MULTU) begin
                cnt <= 4'd5;
            end
        end

        if (cnt > 4'd0) begin
            cnt <= cnt - 1;
        end
    end
end

    assign MDUC = (MDUOp == `MDU_MFHI) ? HIreg :
                  (MDUOp == `MDU_MFLO) ? LOreg :
                  32'd0;

    assign Busy = (cnt != 4'd0) ? 1 : 0;
    
endmodule
