`timescale 1ns / 1ps

module stopwatch_cu(
    input clk, reset, 
    input cs,
    input btn_left, btn_right, 
    output reg o_run, o_clear
    );

    // fsm 구조로 CU를 설계
    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;

    reg [1:0] state, next;

    // state register
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= STOP;
        end else begin
            state <= next;
        end
    end

    // next state
    always @(*) begin
        next = state;
        if (cs == 0) begin
            case(state)
                STOP:
                    if(btn_left) next = RUN;
                    else if (btn_right) next = CLEAR;

                RUN:
                    if(btn_left) next = STOP;

                CLEAR:
                    if (btn_right==0) next = STOP;

                endcase
            end
        end

    // output
    always @(*) begin
        o_run = 1'b0;
        o_clear = 1'b0;
        case(state)
            STOP: begin
                o_run = 1'b0;
                o_clear = 1'b0;
            end
            RUN: begin 
                o_run = 1'b1;
                o_clear = 1'b0;
            end
            CLEAR: begin
                o_clear = 1'b1;
            end
    endcase
    end


endmodule
