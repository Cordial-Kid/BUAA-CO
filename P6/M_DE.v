//数据扩展模块
`include "def.v"
module M_DE (
    input [31:0] Addr,
    input [2:0] DEOp,
    input [31:0] M_Data_Rdata,   //DM输出的东西，应为DM没有判断能力，需要在这里扩展 ; 一会儿看一下哪来的
    output reg [31:0] RD
);

always @(*) begin
    case (DEOp)
        `DE_LW : begin 
            RD = M_Data_Rdata;
        end 
        `DE_LH : begin
            RD = {{16{M_Data_Rdata[16 * Addr[1] + 15]}},M_Data_Rdata[(16 * Addr[1] + 15) -: 16]};
        end
        `DE_LB : begin
            RD = {{24{M_Data_Rdata[8 * Addr[1:0] + 7]}},M_Data_Rdata[(8 * Addr[1:0] + 7) -: 8]};
        end
        default: begin
            RD = 32'b0;
        end
    endcase
end
endmodule