`timescale 1ns / 1ps

module Control_Unit(
    input [2:0] sw,
    input clk,
    input reset,
    output reg up_down,
    output reg run_stop,
    output reg clear
    );

    parameter STOP = 0, MODE_UP = 1, MODE_DN = 2, RUN = 3, CLEAR = 4;

    reg [2:0] state, next;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= 0;
        end
        else begin
            state <= next;
        end
    end

    always @(*) begin
        next = state;
        case (state)
            STOP: begin
                if(sw[0]) begin
                    next = MODE_DN;
                end
                else if(sw[0] == 0) begin
                    next = MODE_UP;
                end
                else if(sw[1]) begin
                    next = RUN;
                end
                else if(sw[2]) begin
                    next = CLEAR;
                end
            end 
            MODE_UP: begin
                if(sw[0] == 0) begin
                    next = MODE_DN;
                end
                else if(sw[1]) begin
                    next = RUN;
                end
                else if(sw[2]) begin
                    next = CLEAR;
                end
            end
            MODE_DN: begin
                if(sw[0]) begin
                    next = MODE_UP;
                end
                else if(sw[1]) begin
                    next = RUN;
                end
                else if(sw[2]) begin
                    next = CLEAR;
                end
            end
            RUN: begin
                if(sw[1] == 0) begin
                    next = STOP;
                end
                else if(sw[2]) begin
                    next = CLEAR;
                end
            end 
            CLEAR: begin
                if(sw[2] == 0) begin
                    next = STOP;
                end
            end 
        endcase
    end

    always @(*) begin
        up_down = 0;
        run_stop = 0;
        clear = 0;
        case (state)    
            STOP: begin
                up_down = 0;
                run_stop = 0;
                clear = 0;
            end 
            MODE_UP: begin
                up_down = 0;
            end
            MODE_DN: begin
                up_down = 1;
            end
            RUN: begin
                run_stop = 1;
            end 
            CLEAR: begin
                clear = 1;
            end 
        endcase
    end
endmodule
