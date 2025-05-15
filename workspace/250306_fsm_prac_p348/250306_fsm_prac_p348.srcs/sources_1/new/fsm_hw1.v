`timescale 1ns / 1ps

module fsm_hw1(
    input clk,
    input reset,
    input din_bit,
    output reg o_detect_twice
    );

    parameter START = 3'b000, rd0_once = 3'b001, rd1_once = 3'b010, rd0_twice = 3'b011, rd1_twice = 3'b100;

    reg [2:0]state, next;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= START;
            o_detect_twice <= 0;
        end
        else begin
            state <= next;
            case (next)
                rd0_twice: begin
                    o_detect_twice <= 1;
                end
                rd1_twice: begin
                    o_detect_twice <= 1;
                end
                default: o_detect_twice <= 0;
            endcase
        end
    end

    always @(*) begin
        next = state;
        case (state)
            START: begin
                if(din_bit == 0) begin
                    next = rd0_once;
                end
                else if(din_bit == 1) begin
                    next = rd1_once;
                end
            end 

            rd0_once: begin
                if(din_bit == 0) begin
                    next = rd0_twice;
                end
                else if(din_bit == 1) begin
                    next = rd1_once;
                end
            end

            rd1_once: begin
                if(din_bit == 0) begin
                    next = rd0_once;
                end
                else if(din_bit == 1) begin
                    next = rd1_twice;
                end
            end

            rd0_twice: begin
                if(din_bit == 0) begin
                    next = state;
                end
                else if(din_bit == 1) begin
                    next = rd1_once;
                end
            end

            rd1_twice: begin
                if(din_bit == 0) begin
                    next = rd0_once;
                end
                else if(din_bit == 1) begin
                    next = state;
                end
            end

            default: begin
                next = state;
            end
        endcase
    end

endmodule
