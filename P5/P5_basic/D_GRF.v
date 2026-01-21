`include "def.v"
module D_GRF (
    input [31:0] PC,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,  
    input [31:0] WD,
    input clk,
    input reset,
    output [31:0] RD1,
    output [31:0] RD2
);

reg [31:0] register [0:31];
integer i;

initial begin
    for (i = 0 ;i < 32 ; i = i + 1) begin
        register[i] = 32'b0;
    end
end

always @(posedge clk) begin
    if (reset) begin
        for (i = 0 ; i < 32 ; i = i + 1) begin
            register[i] <= 32'b0;
        end
    end
    else begin
        if (A3 != 0) begin
            register[A3] <= WD;
            $display("%d@%h: $%d <= %h",$time,PC,A3,WD);
        end
    end
end

//如果要同时读写的话,读出来的一定是要往里写的
assign RD1 = (A1 == 0) ? 32'b0 : (A1 == A3) ? WD : register[A1];
assign RD2 = (A2 == 0) ? 32'b0 : (A2 == A3) ? WD : register[A2];
    
endmodule