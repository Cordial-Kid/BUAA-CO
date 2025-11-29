`include "def.v"
module DM (
    input [31:0] PC,
    input [31:0] addr,
    input [31:0] WD,
    input WR,
    input clk,
    input reset,
    output [31:0] RD,
    //这个接口是用来操作半字指令的
    output [31:0] sub_RD
);

  reg [1:0] _byte;
  wire [31:0] memword;
  reg [31:0] sub_tmp;
  reg [2:0] temp;

  reg [31:0] DM[0:3071];
  integer i;

  initial begin
    for (i = 0; i < 3072; i = i + 1) begin
      DM[i] = 32'b0;
    end
  end

  always @(posedge clk) begin
    if (reset) begin
      for (i = 0; i < 3072; i = i + 1) begin
        DM[i] <= 32'b0;
      end
    end else begin
      if (WR) begin
        DM[addr[13:2]] <= WD;
        $display("@%h: *%h <= %h", PC, {addr[31:2], 2'b0}, WD);
      end
    end
  end

  assign RD = DM[addr[13:2]];
  
  assign memword = DM[addr[13:2]];
  always @(*) begin
    _byte = addr[1:0];
    temp = 0;
    for (i = 0; i < 8; i = i + 1) begin
      temp = temp + memword[8*_byte+i];
    end
    if (temp == 4) begin
      //从起始索引开始，向上扩展宽度位
      sub_tmp = sign_ext(memword[8*_byte +: 8]);
    end else begin
      sub_tmp = 0;
    end
  end
  assign sub_RD = sub_tmp;

  //return 的就是sign_ext
  function [31:0] sign_ext;
    input [7:0] pre_code;
    sign_ext = {{24{pre_code[7]}}, pre_code};
  endfunction

  function [7:0] reverse;
    input [7:0] incode;
    for (i = 0 ; i < 8 ; i = i + 1) begin
      reverse[i] = incode[7-i];
    end
  endfunction
endmodule

