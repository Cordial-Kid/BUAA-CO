//字节使能模块
`include "def.v"
module M_BE (
    input      [ 2:0] BEOp,
    input      [31:0] Addr,
    input      [31:0] WD,
    output reg [ 3:0] M_Data_Byteen,  //字节使能
    output reg [31:0] M_Data_Wdata    //M级DM待写入的数据
);

  always @(*) begin
    case (BEOp)
      `BE_SW: begin
        M_Data_Byteen = 4'b1111;
        M_Data_Wdata  = WD;
      end
      `BE_SH: begin
        if (Addr[1] == 0) begin
          M_Data_Byteen = 4'b0011;
          M_Data_Wdata  = {16'b0, WD[15:0]};
        end else begin
          M_Data_Byteen = 4'b1100;
          M_Data_Wdata  = {WD[15:0], 16'b0};
        end
      end
      `BE_SB: begin
        if (Addr[1:0] == 2'b00) begin
          M_Data_Byteen = 4'b0001;
          M_Data_Wdata  = {24'b0, WD[7:0]};
        end else if (Addr[1:0] == 2'b01) begin
          M_Data_Byteen = 4'b0010;
          M_Data_Wdata  = {16'b0, WD[7:0], 8'b0};
        end else if (Addr[1:0] == 2'b10) begin
          M_Data_Byteen = 4'b0100;
          M_Data_Wdata  = {8'b0, WD[7:0], 16'b0};
        end else begin
          M_Data_Byteen = 4'b1000;
          M_Data_Wdata  = {WD[7:0], 24'b0};
        end
      end
      default: begin
        M_Data_Byteen = 4'b0000;
        M_Data_Wdata  = 32'b0;
      end
    endcase
  end

endmodule
