`timescale 1ns / 1ps

module top_counter_up_down (
    input        clk,
    input        reset,
    input  [2:0] sw,
    output [3:0] fndCom,
    output [7:0] fndFont
);
    wire [13:0] fndData;
    wire [ 3:0] fndDot;
    wire w_up_down, w_run_stop, w_clear;

    counter_up_down U_Counter (
        .clk(clk),
        .reset(reset),
        .up_down(w_up_down),
        .run_stop(w_run_stop),
        .clear(w_clear),
        .count(fndData),
        .dot_data(fndDot)
    );

    fndController U_FndController (
        .clk(clk),
        .reset(reset),
        .fndData(fndData),
        .fndDot(fndDot),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );

    Control_Unit U_Control_Unit (
        .sw(sw),
        .clk(clk),
        .reset(reset),
        .up_down(w_up_down),
        .run_stop(w_run_stop),
        .clear(w_clear)
    );

endmodule

module comp_dot (
    input  [13:0] count,
    output [ 3:0] dot_data
);

    assign dot_data = ((count % 10) < 5) ? 4'b1101 : 4'b1111;
endmodule

module counter_up_down (
    input         clk,
    input         reset,
    input         up_down,
    input         run_stop,
    input         clear,
    output [13:0] count,
    output [ 3:0] dot_data
);
    wire tick;

    clk_div_10hz U_Clk_Div_10Hz (
        .clk  (clk),
        .reset(reset),
        .tick (tick)
    );

    counter U_Counter_Up_Down (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .up_down(up_down),
        .run_stop(run_stop),
        .clear(clear),
        .count(count)
    );

    comp_dot U_Comp_Dot (
        .count(count),
        .dot_data(dot_data)
    );

endmodule


module counter (
    input         clk,
    input         reset,
    input         tick,
    input         up_down,
    input         run_stop,
    input         clear,
    output [13:0] count
);
    reg [$clog2(10000)-1:0] counter;

    assign count = counter;

    always @(posedge clk, posedge reset) begin
        if (reset || clear) begin
            counter <= 0;
        end else if (run_stop) begin
            counter <= counter;
        end else begin
            if (up_down == 1'b1) begin
                if (tick) begin
                    if (counter == 9999) begin
                        counter <= 0;
                    end else begin
                        counter <= counter + 1;
                    end
                end
            end else begin
                if (tick) begin
                    if (counter == 0) begin
                        counter <= 9999;
                    end else begin
                        counter <= counter - 1;
                    end
                end
            end
        end
    end
endmodule

module clk_div_10hz (
    input  wire clk,
    input  wire reset,
    output reg  tick
);
    reg [$clog2(10_000_000)-1:0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if (div_counter == 10_000_000 - 1) begin
                div_counter <= 0;
                tick <= 1'b1;
            end else begin
                div_counter <= div_counter + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule
