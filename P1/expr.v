module expr (
    input clk,
    input clr,
    input [7:0] in,
    output reg out
);
    reg [1:0] state;
    reg [1:0] next_state;

    initial begin
        state = 0;
        next_state = 0;
    end

    always @(posedge clk,posedge clr) begin
        if (clr == 1) begin
            state <= 0;
        end else begin
            state <= next_state;
        end
    end

    always @(state,in) begin
        case (state)
            2'b00:begin
                next_state = (in >=48 && in <= 57) ? 1 : 3;
            end 
            2'b01:begin
                next_state = (in == 42 || in == 43) ? 2 : 3;
            end
            2'b10:begin
                next_state = (in >= 48 && in <= 57) ? 1 : 3;
            end
            2'b11: begin
                next_state = 3;
            end
            default : begin
                next_state = 0;
            end
        endcase
    end

    always @(state) begin
        out = (state == 1) ? 1 : 0;
    end
endmodule