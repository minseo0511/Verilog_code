`timescale 1ns / 1ps

module uart_cu(
    input clk,
    input reset,
    input [7:0] data_in,
    output reg btn_run,
    output reg btn_clear,
    output reg btn_hour,
    output reg btn_min,
    output reg btn_sec 
    );
    reg [2:0] state, next;

    parameter STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010, HOUR_PLUS = 3'b011, MIN_PLUS = 3'b100, SEC_PLUS = 3'b110;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= STOP;
        end
        else begin
            state <= next;
        end
    end

    always @(*) begin
        next = state;
        case (state)
            STOP: begin
                if (data_in == "R") begin
                    next <= RUN;
                end
                else if(data_in == "C") begin
                    next <= CLEAR;
                end
                else if(data_in == "H") begin
                    next <= HOUR_PLUS;
                end
                else if(data_in == "M") begin
                    next <= MIN_PLUS;
                end
                else if(data_in == "S") begin
                    next <= SEC_PLUS;
                end
            end
            RUN: begin
                if (data_in == "R") begin
                    next <= STOP;
                end
            end
            CLEAR: begin
                if (data_in != "C") begin
                    next <= STOP;
                end
            end
            HOUR_PLUS: begin
                if (data_in != "H") begin
                    next <= STOP;
                end
            end
            MIN_PLUS: begin
                if (data_in != "M") begin
                    next <= STOP;
                end
            end
            SEC_PLUS: begin
                if (data_in != "S") begin
                    next <= STOP;
                end
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
                btn_hour = 0;
                btn_min = 0;
                btn_sec = 0;
            end
            CLEAR: begin
                btn_run = 0;
                btn_clear = 1;
                btn_hour = 0;
                btn_min = 0;
                btn_sec = 0;
            end
            HOUR_PLUS: begin
                btn_run = 0;
                btn_clear = 0;
                btn_hour = 1;
                btn_min = 0;
                btn_sec = 0;
            end
            MIN_PLUS: begin
                btn_run = 0;
                btn_clear = 0;
                btn_hour = 0;
                btn_min = 1;
                btn_sec = 0;
            end
            SEC_PLUS: begin
                btn_run = 0;
                btn_clear = 0;
                btn_hour = 0;
                btn_min = 0;
                btn_sec = 1;
            end
        endcase
    end
endmodule
