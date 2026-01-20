module alu (
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUOp,
    output reg [31:0] C
);
  localparam add = 3'b000;
  localparam sub = 3'b001;
  localparam And = 3'b010;
  localparam Or = 3'b011;
  localparam logic_right = 3'b100;
  localparam math_right = 3'b101;
  always @(*) begin
    case (ALUOp)
      add: begin
        C = A + B;
      end
      sub: begin
        C = A - B;
      end
      And: begin
        C = A & B;
      end
      Or: begin
        C = A | B;
      end
      logic_right: begin
        C = A >> B;
      end
      math_right: begin
        C = $signed(A) >>> B;
      end
      default: begin
        C = 32'b0;
      end
    endcase
  end
endmodule
