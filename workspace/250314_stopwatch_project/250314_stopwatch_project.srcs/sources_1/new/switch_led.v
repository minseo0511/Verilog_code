`timescale 1ns / 1ps

module switch_led(
    input [2:0] sw,
    output reg [2:0] led
    );

    always @(*) begin
        case (sw)
            3'b000: led = 3'b000;
            3'b001: led = 3'b001;
            3'b010: led = 3'b010;
            3'b011: led = 3'b011;
            3'b100: led = 3'b100;
            3'b101: led = 3'b101;
            3'b110: led = 3'b110;
            3'b111: led = 3'b111;
            default: led = 3'b000;
        endcase
    end
endmodule
