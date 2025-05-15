`timescale 1ns / 1ps

// TRIG = '1->0' 후  ECHO = '1'을 유지하는 time을 usec로 측정하여 거리 계산
module ultrasonic_sensor(
    input clk,
    input reset,
    input trigger,
    input tick,
    input echo,
    output [8:0] distance, // 4m
    output echo_done
    );

    reg [1:0] state, next;
    reg [14:0] count_dis_reg, count_dis_next;
    reg [8:0] distance_reg, distance_next;
    reg echo_done_reg, echo_done_next;

    assign echo_done = echo_done_reg;

    assign distance = distance_reg;
    parameter STOP = 2'b00, IDLE = 2'b01, ECHO = 2'b10;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= 0;
            count_dis_reg <= 0;
            distance_reg <= 0;
            echo_done_reg <= 0;
        end
        else begin
            state <= next;
            count_dis_reg <= count_dis_next;
            distance_reg <= distance_next;
            echo_done_reg <= echo_done_next;
        end
    end

    always @(*) begin
        next = state;
        count_dis_next = count_dis_reg;
        distance_next = distance_reg;
        echo_done_next = 0;
        case (state)
            STOP: begin
                count_dis_next = 0;
                echo_done_next = 0;
                if(trigger) begin
                    next = IDLE;
                end
            end 
            IDLE: begin
                if(echo) begin
                    next = ECHO;
                end 
            end 
            ECHO: begin
                if (tick) begin
                    count_dis_next = count_dis_reg + 1;   
                end
                if(echo == 0) begin
                    echo_done_next = 1;
                    if(distance_reg > 400) begin
                        distance_next = 400;
                    end
                    else if(count_dis_reg > 23500) begin
                        next = STOP;
                    end 
                    else begin
                        distance_next = count_dis_reg / 58;
                        next = STOP;
                    end
                end
            end
        endcase 
    end
endmodule
