`timescale 1ns / 1ps

module uart (
    input  clk,
    input  rst,
    input  btn_start,
    input [7:0] tx_data_in,
    output tx,
    output tx_done
);

    wire w_tick;

    uart_tx U_uart_tx (
        .clk (clk),
        .rst (rst),
        .tick(w_tick),
        .start_trigger(btn_start),
        .data_in(tx_data_in),                //입력값 0
        .o_tx(tx),
        .tx_done(tx_done)
    );

    baud_tick_gen U_baud_tick_gen (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_tick)
    );
endmodule

module uart_tx (
    input clk,
    input rst,
    input tick,
    input start_trigger,
    input [7:0] data_in,
    output o_tx,
    output tx_done
);
    // fsm
    parameter IDLE = 4'h0, START = 4'h1, DATA = 4'h2, STOP = 4'h3;
    parameter BIT = 8;

    reg [3:0] state, next;
    reg tx_reg, tx_next, tx_done_reg, r_tx_done_next;
    reg [3:0]counter_reg, counter_next;


    assign o_tx = tx_reg;
    assign tx_done = tx_done_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state  <= 0;
            tx_reg <= 1'b1; // Uart tx line을 초기에 항상 1로 만들기 위함.
            tx_done_reg <= 0;
            counter_reg <= 0;
        end else begin
            state  <= next;
            tx_reg <= tx_next;
            tx_done_reg <= r_tx_done_next;
            counter_reg <= counter_next;
        end
    end

    // next

    always @(*) begin
        next = state;
        tx_next = tx_reg;
        r_tx_done_next = tx_done_reg;
        counter_next = counter_reg;
        case (state)
            IDLE: begin
                tx_next = 1'b1;
                if (start_trigger) begin
                    next = START;
                    r_tx_done_next = 1'b1;
                end
            end
            START: begin
                if (tick == 1'b1) begin
                    tx_next = 1'b0;  //출력                    
                    next = DATA;
                end
            end
            DATA: begin
                if(tick == 1'b1) begin
                    tx_next = data_in[counter_reg];
                    if(counter_reg == BIT-1) begin
                        next = STOP;
                        counter_next = 0;
                    end
                    else begin
                        counter_next = counter_reg + 1;
                        next = state; 
                    end
                end
            end
            STOP: begin
                if (tick == 1'b1) begin
                    tx_next = 1'b1;
                    next = IDLE;
                    r_tx_done_next = 1'b0;
                end
            end
        endcase
    end
endmodule

module baud_tick_gen (
    input  clk,
    input  rst,
    output baud_tick
);
    parameter BAUD_RATE = 9600;  //, BAUD_RATE_192000 = 192000, ;
    localparam BAUD_COUNT = 100_000_000 / BAUD_RATE;
    reg [$clog2(BAUD_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;
    // output
    assign baud_tick = tick_reg;
    always @(posedge clk, posedge rst) begin
        if (rst == 1) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    //next
    always @(*) begin
        count_next = count_reg;
        tick_next  = tick_reg;
        if (count_reg == BAUD_COUNT - 1) begin
            count_next = 0;
            tick_next  = 1'b1;
        end else begin
            count_next = count_reg + 1;
            tick_next  = 1'b0;
        end
    end
endmodule
