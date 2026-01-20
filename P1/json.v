module json (
    input clk,
    input reset,
    input [7:0] char,
    output reg [7:0] cur_num,
    output reg [7:0] max_num
);
  localparam IDLE = 2'b00;
  localparam READ = 2'b01;
  localparam CHECK = 2'b10;

  reg [1:0] state;
  reg [1:0] next_state;
  reg invalid_flag;
  reg [9:0] number1;  //number1用来存储"数量
  reg [3:0] tmp_cnt;  //引号之间的单词数

  always @(posedge clk, posedge reset) begin
    if (reset) begin
      state <= IDLE;  
    end else begin
      state <= next_state;
    end
  end

  always @(*) begin
    case (state)
      IDLE: begin
        if (char == "{") begin
          next_state = READ;
        end
      end
      READ: begin
        if (char == "}") begin
          next_state = CHECK;
        end
      end
      CHECK: begin
        if (char == " ") begin
          next_state = IDLE;
        end else if (char == "{") begin
          next_state = READ;
        end
      end
      default: begin
        next_state = IDLE;
      end
    endcase
  end

  always @(posedge clk, posedge reset) begin
    if (reset) begin
      invalid_flag <= 0;
      cur_num <= 0;
      max_num <= 0;
      tmp_cnt <= 0;            // number of character between ""
      number1 <= 0;
    end else begin
      case (state)
        IDLE: begin
          number1 <= 0;            // number of "
          invalid_flag <= 0;
        end
        READ: begin
          if (char == 8'h22) begin
            number1 <= number1 + 1;
            if (is_even(number1 + 1) && tmp_cnt == 0) begin
              invalid_flag <= 1;
            end
            tmp_cnt <= 0;
          end else begin
            tmp_cnt <= tmp_cnt + 1;
          end
          // 注意变化时间，往往在read里面需要做出一定的赋值
          //}也是在READ里面读到的啊
          if (char == "}") begin
            if (invalid_flag == 1) begin
              cur_num <= 0;
            end else begin
              cur_num <= number1 >> 2;
            end
            // 别忘了cur_num的值传不过来,max_num把cur_num的值复写了以后还需要
            // 把条件也搬过来，别只搬个值就结束了
            if (invalid_flag == 0) begin
              if (number1 >> 2 > max_num) begin
                max_num <= number1 >> 2;
              end
            end
          end
        end
        CHECK: begin
          number1 <= 0;
          invalid_flag <= 0;
        end
        default: begin
        end

      endcase
    end
  end

  function is_even;
    input [9:0] num;
    if (num % 2 == 0) begin
      is_even = 1;
    end else begin
      is_even = 0;
    end

  endfunction
endmodule
