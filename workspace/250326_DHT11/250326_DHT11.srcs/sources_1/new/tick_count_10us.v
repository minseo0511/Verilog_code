`timescale 1ns / 1ps

// 1us tick input 사용 => 1000count하면 1ms
module tick_count_10us #(parameter TICK_COUNT = 10, BIT_WIDTH = 4)(
    input clk, 
    input reset,
    input tick,
    output o_tick
);

    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;  // 출력용

    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            count_reg <= 0;
            tick_reg <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next = 1'b0;  
        if (tick == 1'b1) begin
            if(count_reg == TICK_COUNT-1) begin
                count_next = 0;
                tick_next = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next = 1'b0;
            end
        end
    end
endmodule