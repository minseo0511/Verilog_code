`timescale 1ns / 1ps

module tb_MCU_Sensor();
    logic clk;
    logic reset;
    // logic [7:0] GPOA;
    // logic [7:0] GPIB;
    wire  [7:0] GPIOC;

    // logic [7:0] GPIOD;
    logic [3:0] fnd_Comm;
    logic [7:0] fnd_Font;
    logic echo;
    logic trigger;
    logic btn_trig;

    logic [7:0] GPIOC_out;  
    logic GPIOC_oe;         
    wire  [7:0] GPIOC_in; 

    assign GPIOC = GPIOC_oe ? GPIOC_out : 8'bz;
    assign GPIOC_in = GPIOC;

    MCU dut (
        .clk(clk),
        .reset(reset),
        .btn_trig(btn_trig),
        // .GPOA(GPOA),
        // .GPIB(GPIB),
        .GPIOC(GPIOC),
        // .GPIOD(GPIOD),
        .fnd_Comm(fnd_Comm),
        .fnd_Font(fnd_Font),
        .echo(echo),
        .trigger(trigger)
);

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1;  echo = 0; GPIOC_oe = 1; GPIOC_out = 8'h00; btn_trig = 0;
        #10 reset = 0;

        #100;
        btn_trig = 1;
        #10;
        btn_trig = 0;

        #100; GPIOC_out = 8'h01;
        #5000 echo = 1;
        #1000000 echo = 0;  // 1

        #2000 btn_trig = 1;
        #2000 btn_trig = 0;
        #100; GPIOC_out = 8'h01;
        #10000 echo = 1;
        #200000 echo = 0;
        #300 $finish;
    end
endmodule
