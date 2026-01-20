module gray (
    input Clk,
    input Reset,
    input En,
    output [2:0] Output,
    output reg Overflow
);
  reg [2:0] binary_cnt;
  initial begin
    binary_cnt = 0;
    Overflow   = 0;
  end
  always @(posedge Clk) begin
    if (Reset == 1) begin
      Overflow   <= 0;
      binary_cnt <= 0;
    end else begin
      if (En == 1) begin
        binary_cnt <= (binary_cnt + 1) > 7 ? 0 : binary_cnt + 1;
        if (Overflow == 0) begin
          Overflow <= (binary_cnt + 1) > 7 ? 1 : 0;
        end
      end
    end
  end
  assign Output = binary_cnt ^ (binary_cnt >> 1);
endmodule


