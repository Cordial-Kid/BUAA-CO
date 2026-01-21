module M_DM (
    input clk,
    input reset,
    input DMWE,
    input [31:0] PC,
    input [31:0] Addr,
    input [31:0] WD,
    output [31:0] RD
);

reg [31:0] DM [0:3071];
integer i;

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
    assign RD = DM[Addr[13:2]];
endmodule