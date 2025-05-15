`timescale 1ns / 1ps

module uart_cu(
    input clk,
    input reset,
    input [7:0] data_in,
    input empty_rx_b,
    output reg btn_run,
    output reg btn_clear,
    output reg btn_hour,
    output reg btn_min,
    output reg btn_sec 
    );
    reg [2:0] state, next;
    reg [7:0] data_in_reg, data_in_next;

    parameter STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010, HOUR = 3'b011, MIN = 3'b100, SEC = 3'b110;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= STOP;
            //data_in_reg <= 0;
        end
        else begin
            state <= next;
            //data_in_reg <= data_in_next;
        end
    end

    always @(*) begin
        next = state;
        case (state)
            STOP: begin
                if (empty_rx_b) begin
                   if (data_in == "R") begin
                        next <= RUN;
                    end
                    else if(data_in == "C") begin
                        next <= CLEAR;
                    end
                    else if(data_in == "H") begin
                        next <= HOUR;
                    end
                    else if(data_in == "M") begin
                        next <= MIN;
                    end
                    else if(data_in == "S") begin
                        next <= SEC;
                    end 
                end
            end
            RUN: begin
                if (empty_rx_b) begin
                    if (data_in == "R") begin
                        next <= STOP;
                    end
                end
            end
            CLEAR: begin
                    next <= STOP;
            end
            HOUR: begin
                    next <= STOP;
            end
            MIN: begin
                    next <= STOP;
            end
            SEC: begin
                    next <= STOP;
            end 
        endcase
    end

    always @(*) begin
        btn_run = 0;
        btn_clear = 0;
        btn_hour = 0;
        btn_min = 0;
        btn_sec = 0;
        case (state)
            STOP: begin
                btn_run = 0;
                btn_clear = 0;
                btn_hour = 0;
                btn_min = 0;
                btn_sec = 0;
            end
            RUN: begin
                btn_run = 1;
                btn_clear = 0;
            end
            CLEAR: begin
                btn_clear = 1;
            end
            HOUR: begin
                btn_hour = 1;
                btn_min = 0;
                btn_sec = 0;
            end
            MIN: begin
                btn_hour = 0;
                btn_min = 1;
                btn_sec = 0;
            end
            SEC: begin
                btn_hour = 0;
                btn_min = 0;
                btn_sec = 1;
            end
        endcase
    end
endmodule
