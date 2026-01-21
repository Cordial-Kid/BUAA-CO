`include "def.v"
module M_DM (
    input clk,
    input reset,
    input DMWE,
    input [31:0] PC,
    input [31:0] Addr,
    input [31:0] WD,
    input [2:0] DMOp,
    output [31:0] RD,
    output Condition1

);

reg [31:0] DM [0:3071];
integer i;

reg [31:0] memword;
reg [1:0] byte;
reg _condition1;
reg [31:0] extended;


always @(*) begin
    memword = DM[Addr[13:2]];
    byte = Addr[1:0];
    if (memword[7+8*byte]==0) begin
        _condition1 = 1;
    end
    else begin
        _condition1 = 0;
    end
    extended = sign_ext(memword[8*byte +:8]);
end
assign Condition1 = _condition1;


initial begin
    for (i = 0 ; i < 3072 ; i = i + 1) begin
        DM[i] = 32'b0;
    end
end
    
    always @(posedge clk ) begin
        if (reset) begin
            for (i = 0 ; i < 3072 ; i = i + 1) begin
                DM[i] <= 32'b0;
            end
        end
        else begin
            if (DMWE) begin
                DM[Addr[13:2]] <= WD;
                $display("%d@%h: *%h <= %h",$time,PC,{Addr[31:2],2'b0},WD);
            end
        end
    end
    assign RD = (DMOp == `DMOPBASE) ? DM[Addr[13:2]] :
                (DMOp == `DMOPLBGET) ? extended :
                32'd0;


function [31:0] sign_ext;
    input [7:0] in;
    sign_ext = {{24{in[7]}},in};
endfunction
endmodule