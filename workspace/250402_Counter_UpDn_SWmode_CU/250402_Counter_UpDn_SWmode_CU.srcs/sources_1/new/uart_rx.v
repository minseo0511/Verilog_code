`timescale 1ns / 1ps

module uart_rx (
    input clk,
    input reset,
    input tick,
    input rx,
    output rx_done,
    output [7:0] rx_data
);
    
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0] state, next;
    reg rx_done_reg, rx_done_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg [4:0] tick_count_reg, tick_count_next; 
    reg [7:0] rx_data_reg, rx_data_next;

    assign rx_done = rx_done_reg;
    assign rx_data = rx_data_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
            rx_done_reg <= 0;
            bit_count_reg <= 0;
            tick_count_reg <= 0;
            rx_data_reg <= 0;
        end
        else begin
            state <= next;
            rx_done_reg <= rx_done_next;
            bit_count_reg <= bit_count_next;
            tick_count_reg <= tick_count_next;
            rx_data_reg <= rx_data_next;
        end
    end

    always @(*) begin
        next = state;
        rx_done_next = rx_done_reg;
        bit_count_next = bit_count_reg;
        tick_count_next = tick_count_reg;
        rx_data_next = rx_data_reg;
        rx_done_next = 0;
        case (state)
            IDLE: begin
                tick_count_next = 0;
                bit_count_next = 0;
                rx_done_next = 0;
                if (rx == 0) begin
                    next = START;
                end
            end  
            START: begin
                if(tick) begin
                    if(tick_count_reg == 7) begin
                        next = DATA;
                        tick_count_next = 0;
                    end
                    else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
                
            end  
            DATA: begin
                rx_data_next[bit_count_reg] = rx;
                if (tick) begin
                    if(tick_count_reg == 15) begin
                        // read data
                        tick_count_next = 0;
                        if (bit_count_reg == 7) begin
                            next = STOP;
                        end
                        else begin
                            next = DATA;
                            bit_count_next = bit_count_reg + 1;
                        end
                    end
                    else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end  
            STOP: begin
                if(tick) begin
                    if (tick_count_reg == 23) begin
                        rx_done_next = 1;
                        next = IDLE;
                    end
                    else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end  
        endcase
    end

endmodule
module baudrate (
    input clk,
    input reset,
    output reg tick
);

    parameter BAUD_RATE = (100_000_000/9600)/16;

    reg [$clog2(BAUD_RATE)-1:0] count;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            count <= 0;
        end
        else begin
            if(count == BAUD_RATE-1) begin
                count <= 0;
                tick <= 1;
            end
            else begin
                count <= count + 1;
                tick <= 0;    
            end
        end
     end
endmodule
