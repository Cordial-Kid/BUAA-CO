module ext (
    input [15:0] imm,
    input [1:0] EOp,
    output reg [31:0] ext
);
  reg tmp;
  always @(*) begin
    case (EOp)
      2'b00: begin
        tmp = imm[15];
        ext = {{16{tmp}}, imm[15:0]};
      end
      2'b01: begin
        tmp = 0;
        ext = {
          {16{tmp}}, imm[15:0]
        };  //{}代表拼接，要把16个1位数拼起来需要两层括号
      end
      2'b10: begin
        tmp = 0;
        ext = {imm[15:0], {16{tmp}}};
      end
      2'b11: begin
        tmp = imm[15];
        ext = {{16{tmp}}, imm[15:0]};
        ext = ext << 2;
      end
      default: begin
        ext = 32'b0;
      end
    endcase
  end
endmodule
