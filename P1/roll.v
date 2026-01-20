module roll (
    input  [31:0] a,
    output [31:0] out
);

  reg  [8:0] a0;
  reg  [8:0] a1;
  reg  [8:0] a2;
  reg  [8:0] a3;
  reg  [8:0] a4;
  reg  [8:0] a5;
  reg  [8:0] a6;
  reg  [8:0] a7;
  wire [3:0] t0 = a[3:0];
  wire [3:0] t1 = a[7:4];
  wire [3:0] t2 = a[11:8];
  wire [3:0] t3 = a[15:12];
  wire [3:0] t4 = a[19:16];
  wire [3:0] t5 = a[23:20];
  wire [3:0] t6 = a[27:24];
  wire [3:0] t7 = a[31:28];

  always @(*) begin
    a0 = t0;
    if (a0 + t1 > 4'b1111) begin
      a1 = (a0 + t1) % 4'd16;
    end else begin
      a1 = a0 + t1;
    end

    if (a0 + a1 + t2 > 4'b1111) begin
      a2 = (a0 + a1 + t2) % 4'd16;
    end else begin
      a2 = a0 + a1 + t2;
    end

    if (a0 + a1 + a2 + t3 > 4'b1111) begin
      a3 = (a0 + a1 + a2 + t3) % 4'd16;
    end else begin
      a3 = a0 + a1 + a2 + t3;
    end

    if (a0 + a1 + a2 + a3 + t4 > 4'b1111) begin
      a4 = (a0 + a1 + a2 + a3 + t4) % 4'd16;
    end else begin
      a4 = a0 + a1 + a2 + a3 + t4;
    end

    if (a0 + a1 + a2 + a3 + a4 + t5 > 4'b1111) begin
      a5 = (a0 + a1 + a2 + a3 + a4 + t5) % 4'd16;
    end else begin
      a5 = a0 + a1 + a2 + a3 + a4 + t5;
    end

    if (a0 + a1 + a2 + a3 + a4 + a5 + t6 > 4'b1111) begin
      a6 = (a0 + a1 + a2 + a3 + a4 + a5 + t6) % 4'd16;
    end else begin
      a6 = a0 + a1 + a2 + a3 + a4 + a5 + t6;
    end

    if (a0 + a1 + a2 + a3 + a4 + a5 + a6 + t7 > 4'b1111) begin
      a7 = (a0 + a1 + a2 + a3 + a4 + a5 + a6 + t7) % 4'd16;
    end else begin
      a7 = a0 + a1 + a2 + a3 + a4 + a5 + a6 + t7;
    end
  end
  assign out = {a7[3:0], a6[3:0], a5[3:0], a4[3:0], a3[3:0], a2[3:0], a1[3:0], a0[3:0]};
endmodule


