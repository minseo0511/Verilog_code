`timescale 1ns / 1ps

module fsm_exam(
    input clk,
    input reset,
    input [2:0]sw,
    output [2:0]led
    );
    parameter [2:0]IDLE = 3'b000, ST1 = 3'b001, ST2 = 3'b010, ST3 = 3'b011, ST4 = 3'b100;

    reg [2:0]state, next_state;
    reg [2:0]w_led;
    assign led = w_led;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE:begin
                if(sw==3'b001) begin
                    next_state = ST1;
                end
                else if(sw==3'b010) begin
                    next_state = ST2;
                end
                else begin
                    next_state = state;
                end
            end
             
            ST1:begin
                if(sw==3'b010) begin
                    next_state = ST2;
                end
                else begin
                    next_state = state;
                end
            end
             
            ST2:begin
                if(sw==3'b100) begin
                    next_state = ST3;
                end
                else begin
                    next_state = state;
                end
            end
             
            ST3:begin
                if(sw==3'b000) begin
                    next_state = IDLE;
                end
                else if(sw==3'b001) begin
                    next_state = ST1;
                end
                else if(sw==3'b111) begin
                    next_state = ST4;
                end
                else begin
                    next_state = state;
                end
            end
             
            ST4:begin
                if(sw==3'b100) begin
                    next_state = ST3;
                end
                else begin
                    next_state = state;
                end
            end
            default: next_state = state;
        endcase
    end

    always @(*) begin
        case (next_state)
            IDLE : begin
                w_led = 3'b000;
            end 
            ST1 : begin
                w_led = 3'b001;
            end
            ST2 : begin
                w_led = 3'b010;
            end
            ST3 : begin
                w_led = 3'b100;
            end 
            ST4 : begin
                w_led = 3'b111;
            end
            default: w_led = 3'b000;
        endcase
    end
endmodule
