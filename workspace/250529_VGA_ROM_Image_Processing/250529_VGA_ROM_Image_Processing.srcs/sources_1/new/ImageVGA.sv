`timescale 1ns / 1ps

module ImageVGA(
    input logic clk,
    input logic reset,
    output logic h_sync,
    output logic v_sync,
    output logic [3:0] red_port,
    output logic [3:0] green_port,
    output logic [3:0] blue_port
    );

    logic [9:0] x_pixel;
    logic [9:0] y_pixel;
    logic DE;

    VGA_Controller U_VGA_Controller(
        .clk(clk),
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .DE(DE)
    );

    Image_Rom U_Image_Rom(
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .DE(DE),
        .red_port(red_port),
        .green_port(green_port),
        .blue_port(blue_port)
    );


endmodule
