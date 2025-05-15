`timescale 1ns / 1ps

module counter_up_down(
    input clk,
    input reset,
    input mode,
    output [13:0] count
    );

    wire w_tick;

    clk_div_10hz #(.BIT_WIDTH(10_000_000)) U_Clk_Div_10hz(
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    counter U_Counter_Up_Down(
        .clk(clk),
        .reset(reset),
        .tick(w_tick),
        .mode(mode),
        .count(count) 
    );

endmodule

module counter (
    input clk,
    input reset,
    input tick,
    input mode,
    output [13:0] count 
);

    reg [$clog2(10_000)-1:0] counter;
    assign count = counter;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            counter <= 0;
        end
        else begin
            if(tick) begin
                if(mode == 0) begin
                    if(counter == 9999) begin
                        counter <= 0;
                    end
                    else begin
                        counter <= counter + 1;
                    end
                end
                else begin
                    if(counter == 0) begin
                        counter <= 9999;
                    end
                    else begin
                        counter <= counter - 1;
                    end
                end
            end
        end
    end
endmodule

module clk_div_10hz #(parameter BIT_WIDTH = 10_000_000)(
    input clk,
    input reset,
    output reg tick
);

    reg [$clog2(BIT_WIDTH)-1:0] div_counter;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end
        else begin
            if(div_counter == BIT_WIDTH - 1) begin
                div_counter <= 0;
                tick <= 1'b1;
            end
            else begin
                div_counter <= div_counter + 1;
                tick <= 1'b0;
            end
        end
    end   
endmodule