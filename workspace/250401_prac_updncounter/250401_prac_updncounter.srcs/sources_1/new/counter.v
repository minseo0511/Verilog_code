`timescale 1ns / 1ps

module counter(
    input clk,
    input reset,
    input tick_10ms,
    input sw_mode,
    output [$clog2(10000)-1:0] count
    );
           
    parameter BIT_WIDTH = 10_000;

    reg  [$clog2(BIT_WIDTH)-1:0] count_reg, count_next;

    assign count = count_reg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            count_reg <= 0;
        end
        else begin
            count_reg <= count_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        if(sw_mode == 0) begin
            if(tick_10ms) begin
                if(count_reg == BIT_WIDTH-1) begin
                    count_next = 0;
                end 
                else begin
                    count_next = count_reg + 1;
                end
            end
        end
        else if(sw_mode == 1) begin
            if(tick_10ms) begin
                if(count_reg == 0) begin
                    count_next = 9999;
                end
                else begin
                    count_next = count_reg - 1;
                end
            end
        end
    end
endmodule
