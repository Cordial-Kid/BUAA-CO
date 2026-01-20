// 这里借用推箱子的例子简单说明
module push (
    input dx,
    input dy,
    input clk,
    input clr,
    output reg out,
    output reg hit
);

// 这里举例子定义两个陷阱
    parameter x0 =1 ;
    parameter y0 = 0;
    parameter ansx = 1;
    parameter ansy = 2; 
    reg [2:0] state_x = 0;
    reg [2:0] state_y = 0;
    reg [2:0] next_state_x;
    reg [2:0] next_state_y;

    always @(posedge clk,posedge clr) begin
        if (clr == 1) begin
            state_x <= 0;
            state_y <= 0;
        end else begin
            state_x <= next_state_x;
            state_y <= next_state_y; 
        end
    end

    // 这里体现输入dx,dy对次态的影响
    always @(state_x,state_y,dx,dy) begin
        next_state_x =state_x + dx;
        next_state_y = state_y + dy;
        hit = 0;   //这么写hit不就是个Mealy机了吗
        if(state_x + dx >1 || state_y + dy > 2 || (state_x + dx == x0 && state_y + dy == y0)) begin
            next_state_x = state_x;
            next_state_y = state_y;
            // 这里要延迟一个周期对hit赋值怎么考量，或者说logisim中的寄存器有什么用
            hit = 1;
        end 
    end
    // in影响的是next_state,in还要影响输出，那只能next_state影响输出
    // 符合真值表中的 in 加 前态 决定输出
    always @(state_x,state_y,dx,dy) begin
        if (state_x == 1 && state_y == 1) begin
            if (dx == 0 && dy == 1) begin
                out = 1;
            end
            else begin
                out = 0;
            end
        end
        else if (state_x == 0 && state_y == 2) begin
            if (dx == 1 && dy == 0) begin
                out = 1;
            end
            else begin
                out = 0;
            end
        end
        else begin
            out = 0;
        end
    end
endmodule