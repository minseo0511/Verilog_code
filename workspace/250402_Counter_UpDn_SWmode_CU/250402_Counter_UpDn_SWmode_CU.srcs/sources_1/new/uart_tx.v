`timescale 1ns / 1ps

module uart_tx (
    input clk,
    input reset,
    input tick,
    input start_trigger,
    input [7:0] data_in,
    output tx,
    output tx_busy,
    output tx_done
);
    // FSM 상태 정의
    parameter IDLE = 0, START = 1, DATA = 2, STOP = 3;
    parameter COUNT_BIT = 8;
    parameter BAUD_SPEED = 16;

    reg [3:0] state, next;
    reg tx_reg, tx_next;
    reg tx_done_reg, tx_done_next;
    reg tx_busy_reg, tx_busy_next;
    reg [3:0] bit_count_reg, bit_count_next;
    reg [3:0] tick_count_reg, tick_count_next;
    reg [7:0] temp_data_reg, temp_data_next;

    assign tx = tx_reg;
    assign tx_done = tx_done_reg;
    assign tx_busy = tx_busy_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state  <= IDLE;
            tx_reg <= 1'b1; // UART TX 초기값은 HIGH
            tx_done_reg <= 1'b0;
            tx_busy_reg <= 1'b0;
            bit_count_reg <= 0;
            tick_count_reg <= 0;
            temp_data_reg <= 0;
        end else begin
            state  <= next;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;
            tx_busy_reg <= tx_busy_next;
            bit_count_reg <= bit_count_next;
            tick_count_reg <= tick_count_next;
            temp_data_reg <= temp_data_next;
        end
    end

    always @(*) begin
        next = state;
        tx_next = tx_reg;
        tx_done_next = tx_done_reg; 
        tx_busy_next = tx_busy_reg; 
        bit_count_next = bit_count_reg;
        tick_count_next = tick_count_reg;
        temp_data_next = temp_data_reg;

        case (state)
            IDLE: begin
                tx_next = 1'b1;
                tx_done_next = 1'b0;  
                tx_busy_next = 1'b0;  
                tick_count_next = 4'h0;
                if (start_trigger) begin
                    tx_busy_next = 1'b1;  
                    next = START;    
                    temp_data_next = data_in;
                end
            end
            START: begin
                tx_next = 1'b0;
                tx_busy_next = 1'b1;
                if (tick == 1'b1) begin
                    if (tick_count_reg == BAUD_SPEED-1) begin
                        next = DATA;
                        bit_count_next = 0;
                        tick_count_next = 0;       
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            DATA: begin
                tx_next = temp_data_reg[bit_count_reg];
                tx_busy_next = 1'b1;
                if (tick == 1'b1) begin
                    if (tick_count_reg == BAUD_SPEED-1) begin
                        tick_count_next = 0;   
                        if (bit_count_reg == COUNT_BIT-1) begin
                            next = STOP;
                        end else begin
                            bit_count_next = bit_count_reg + 1;
                        end
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1'b1;
                tx_busy_next = 1'b1;
                if (tick == 1'b1) begin
                    if (tick_count_reg == BAUD_SPEED-1) begin
                        next = IDLE;
                        tx_done_next = 1'b1; 
                        tx_busy_next = 1'b0; 
                        tick_count_next = 0;   
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule
