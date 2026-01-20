// Mealy真值表首先要考虑状态转移图的最后能不能画出来？
// 我给不给S4这个状态


module fsm_1010 (
    input clk,
    input in,
    input clr,
    output reg out
);

reg [2:0] state = 0;
reg [2:0] next_state;

// 描述状态转移的时序逻辑
always @(posedge clk or posedge clr) begin
    if (clr == 1) begin
        state <= 0;
        //这里跟next_state没关系
    end else begin
        state <= next_state;
    end
end

// 判断状态转移条件的组合逻辑
always @(state, in) begin
    case (state)
        0:
            begin
                next_state = in == 1 ? 1 : 0;
            end
        1:
            begin
                next_state = in == 1 ? 1 : 2;
            end
        2:
            begin
                next_state = in == 1 ? 3 : 0;
            end
        3:
            begin
                next_state = in == 1 ? 1 : 4;
            end
        4:
            begin
                next_state = in == 1 ? 3 : 0;
            end
        default:
            begin
                next_state = 0;
            end
    endcase
end

// 产生输出的组合逻辑
// 这里输入也对它产生了影响
always @(state,in) begin
    out = 0;
    case (state)
        3:begin
            if (in == 0) begin
                out = 1;
            end
        end 
        default: out = 0;
    endcase
end

endmodule