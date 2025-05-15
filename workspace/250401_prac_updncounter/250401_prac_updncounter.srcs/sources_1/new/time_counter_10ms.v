`timescale 1ns / 1ps

module time_counter_10ms #(parameter BIT_WIDTH = 1_000_000)(
    input clk,
    input reset,
    output reg o_tick
    );

    reg [$clog2(BIT_WIDTH)-1:0]count_reg, count_next;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            count_reg <= 0;
        end
        else begin
            count_reg <= count_next;
        end
    end

    always @(*) begin
        if(count_reg == BIT_WIDTH - 1) begin
            count_next = 0;
            o_tick = 1;
        end
        else begin
            count_next = count_reg + 1;
            o_tick = 0;
        end
    end
endmodule
