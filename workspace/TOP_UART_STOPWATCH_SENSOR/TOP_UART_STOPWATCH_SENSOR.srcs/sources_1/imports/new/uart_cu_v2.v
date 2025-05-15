`timescale 1ns / 1ps

module uart_cu_v2(
    input clk,
    input reset,
    input [7:0] data_in,
    input empty_rx_b,
    output reg btn_left,
    output reg btn_right,
    output reg btn_down
    );
    reg [1:0] state, next;
    reg [7:0] data_in_reg, data_in_next;

    parameter STOP = 2'b00, LEFT = 2'b01, RIGHT = 2'b10, DOWN = 2'b11;

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
                if (empty_rx_b) begin
                   if (data_in == "R" || data_in == "S") begin
                        next <= LEFT;
                    end
                    else if(data_in == "C" || data_in == "H") begin
                        next <= RIGHT;
                    end
                    else if(data_in == "M") begin
                        next <= DOWN;
                    end
                end
            end
            LEFT: begin
                next <= STOP;
            end
            RIGHT: begin
                next <= STOP;
            end
            DOWN: begin
                next <= STOP;
            end
        endcase
    end

    always @(*) begin
        btn_left = 0;
        btn_right = 0;
        btn_down = 0;
        case (state)
            STOP: begin
                btn_left = 0;
                btn_right = 0;
                btn_down = 0;
            end
            LEFT: begin
                btn_left = 1;
                btn_right = 0;
            end
            RIGHT: begin
                btn_right = 1;
            end
            DOWN: begin
                btn_down = 1;
            end
        endcase
    end
endmodule
