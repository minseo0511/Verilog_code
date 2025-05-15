`timescale 1ns / 1ps

// FSM input = [2:0]sw, led1,2 = [1:0]led
module fsm_led(
        input clk,
        input reset,
        input [2:0]sw,
        output [1:0]led
    );

    parameter [1:0]IDLE = 2'b00, LED01 = 2'b01, LED02 = 2'b10;

    reg [1:0]state, next_state;
    reg [1:0]w_led;
    assign led = w_led;

    // state 저장
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
        end

        // next_state를 present_state로 change
        else begin
            // 상태 관리, next를 현재상태로 바꿔라
            state <= next_state;
        end
    end

    // next_state combinational logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if(sw == 3'b001) begin
                    next_state = LED01;
                end
                else begin
                    next_state = state;
                end
            end
            LED01: begin
                if(sw == 3'b011) begin
                    next_state = LED02;
                end
                else begin
                    next_state = state;
                end
            end
            LED02: begin if(sw == 3'b110) begin
                    next_state = LED01;
                end
                else if(sw == 3'b111) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = state;
                end
            end 
            default: next_state = state;
        endcase
    end

    // output combinational logic
    always @(*) begin
        case (next_state)
            IDLE: begin
                w_led = 2'b00;
            end 
            LED01: begin
                w_led = 2'b10;
            end 
            LED02: begin
                w_led = 2'b01;
            end 
            default: w_led = 2'b00;
        endcase
    end

endmodule
