`timescale 1ns / 1ps

module top_counter_up_down (
    input        clk,
    input        reset,
    input        rx,
    output [3:0] fndCom,
    output [7:0] fndFont,
    output tx
);
    wire [13:0] fndData;
    wire [ 3:0] fndDot;
    wire w_en, w_clear, w_mode;
    wire [7:0] w_rx_data, w_tx_data;
    wire w_rx_done, w_tx_done;
    wire w_tick;
    wire w_tx_busy;
    wire w_echo;

    uart_rx U_uart_rx(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tick(w_tick),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done) 
    );

    control_unit U_control_unit (
        .clk(clk),
        .reset(reset),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done),
        .tx_busy(w_tx_busy),
        .echo(w_echo),
        .tx_data(w_tx_data),
        .en(w_en),
        .clear(w_clear),
        .mode(w_mode)
    );

    counter_up_down U_Counter (
        .clk(clk),
        .reset(reset),
        .mode(w_mode),
        .en(w_en),
        .clear(w_clear),
        .count(fndData),
        .dot_data(fndDot)
    );

    uart_tx U_uart_tx (
        .clk(clk),
        .reset(reset),
        .tick(w_tick),
        .start_trigger(w_echo),
        .data_in(w_tx_data),
        .tx(tx),
        .tx_busy(w_tx_busy),
        .tx_done(w_tx_done)
    );

    fndController U_FndController (
        .clk(clk),
        .reset(reset),
        .fndData(fndData),
        .fndDot(fndDot),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );

    baudrate U_baudrate (
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

endmodule


module control_unit (
    input clk,
    input reset,
    input [7:0] rx_data,
    input rx_done,
    input tx_busy,
    output echo,
    output [7:0] tx_data,
    output reg en,
    output reg clear,
    output reg mode
);

    localparam STOP = 0, RUN = 1, CLEAR = 2;

    reg [1:0] state, state_next;
    reg echo_reg, echo_next;
    reg [7:0] tx_data_reg, tx_data_next;

    assign tx_data = tx_data_reg;
    assign echo = echo_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STOP;
            mode <= 0;
            echo_reg <= 0;
            tx_data_reg <= 0;
        end else begin
            state <= state_next;
            echo_reg <= echo_next;
            tx_data_reg <= tx_data_next;
            if (rx_data == "m" && rx_done) begin
                mode <= ~mode; 
            end
        end
    end

    always @(*) begin
        state_next = state;
        en = 0;
        clear = 0;
        echo_next = 0;
        tx_data_next = tx_data_reg;
        if (rx_done && !tx_busy) begin 
            echo_next = 1;
            tx_data_next = rx_data;  
        end

        case (state)
            STOP: begin
                if (rx_data == "r" && rx_done) begin
                    state_next = RUN;
                end
                else if (rx_data == "c" && rx_done) begin
                    state_next = CLEAR;
                end
            end
            RUN: begin
                en = 1;
                if (rx_data == "s" && rx_done) begin
                    state_next = STOP;
                end 
            end
            CLEAR: begin
                clear = 1;
                state_next = STOP;
            end
        endcase
    end
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
    input         mode,
    input         en,
    input         clear,
    output [13:0] count,
    output [ 3:0] dot_data
);
    wire tick;

    clk_div_10hz U_Clk_Div_10Hz (
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .en(en),
        .tick(tick)
    );

    counter U_Counter_Up_Down (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .mode(mode),
        .en(en),
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
    input         mode,
    input         en,
    input         clear,
    output [13:0] count
);
    reg [$clog2(10000)-1:0] counter;

    assign count = counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else begin
            if (clear) begin
                counter <= 0;
            end
            if (en) begin
                if (mode == 1'b0) begin
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
    end
endmodule

module clk_div_10hz (
    input clk,
    input reset,
    input clear,
    input en,
    output reg tick
);
    reg [$clog2(10_000_000)-1:0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if (en) begin
                if (div_counter == 10_000_000 - 1) begin
                    div_counter <= 0;
                    tick <= 1'b1;
                end else begin
                    div_counter <= div_counter + 1;
                    tick <= 1'b0;
                end
            end
            if (clear) begin
                div_counter <= 0;
                tick <= 1'b1;
            end
        end
    end
endmodule
