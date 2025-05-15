`timescale 1ns / 1ps

module led_on_off (
    input [4:0] sw_mode,
    output reg [4:0] led
);

    always @(*) begin
        if (sw_mode == 5'b00000) begin
            led = 5'b00000;
        end else if (sw_mode[0]) begin
            led[0] = 1;
        end else if (sw_mode[1]) begin
            led[1] = 1;
        end else if (sw_mode[2]) begin
            led[2] = 1;
        end else if (sw_mode[3]) begin
            led[3] = 1;
        end else if (sw_mode[4]) begin
            led[4] = 1;
        end 
    end
endmodule