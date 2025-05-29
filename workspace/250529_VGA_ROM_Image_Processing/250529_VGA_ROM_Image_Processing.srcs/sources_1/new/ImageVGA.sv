`timescale 1ns / 1ps

module ImageVGA(
    input logic clk,
    input logic reset,
    input logic [3:0] sw,
    output logic h_sync,
    output logic v_sync,
    output logic [3:0] red_port,
    output logic [3:0] green_port,
    output logic [3:0] blue_port
    );

    logic [9:0] x_pixel;
    logic [9:0] y_pixel;
    logic DE;
    logic [3:0] red_pre_filt, green_pre_filt, blue_pre_filt;
    logic [3:0] red_gray, green_gray, blue_gray;
    logic [3:0] red_binary, green_binary, blue_binary;

    assign red_port = sw[3] ? red_gray : red_binary; 
    assign green_port = sw[3] ? green_gray : green_binary; 
    assign blue_port = sw[3] ? blue_gray : blue_binary; 

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
        .red_port(red_pre_filt),
        .green_port(green_pre_filt),
        .blue_port(blue_pre_filt)
    );

    RGB_filtering U_RGB_filtering(
        .sw(sw[2:0]),
        .red(red_pre_filt),
        .green(green_pre_filt),
        .blue(blue_pre_filt),
        .red_filter(red_binary),
        .green_filter(green_binary),
        .blue_filter(blue_binary)
    );

    Gray_filtering U_Gray_filtering(
        .red(red_pre_filt),
        .green(green_pre_filt),
        .blue(blue_pre_filt),
        .red_Gray(red_gray),
        .green_Gray(green_gray),
        .blue_Gray(blue_gray)
    );

endmodule
