`timescale 1ns / 1ps

module TOP_UltrasonicSensor(
    input clk,
    input reset,
    input btn_trig,
    input echo,
    // input [7:0] data_in,
    output trigger,
    output [8:0] distance
    // output echo_done
    );

    wire w_tick_1us, w_tick_10us;
    wire w_left;
    
    HCSR04_dp U_Sensor_CU (
        .clk(clk),
        .reset(reset),
        .btn_trig(w_left),
        // .data_in(data_in),
        .o_tick(trigger)
    );

    time_counter #(.TICK_COUNT(100), .BIT_WIDTH(7)) U_TICK_1us(
        .clk(clk),
        .reset(reset),
        .o_tick(w_tick_1us)
    );

    btn_debounce bd_left (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_trig),
        .o_btn(w_left)
    );
    
    ultrasonic_sensor U_Ultrasonic_Sensor(
        .clk(clk),
        .reset(reset),
        .trigger(trigger),
        .tick(w_tick_1us),
        .echo(echo),
        .distance(distance) // 4m
        // .echo_done(echo_done)
    );
endmodule

module time_counter #(parameter TICK_COUNT = 100, BIT_WIDTH = 7) (
    input clk,
    input reset,
    output o_tick
);

    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;  // 출력용

    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next = 1'b0;  
        if (count_reg == TICK_COUNT - 1) begin
            count_next = 0;
            tick_next  = 1'b1;
        end else begin
            count_next = count_reg + 1;
            tick_next  = 1'b0;
        end
    end

endmodule