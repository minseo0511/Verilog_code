`timescale 1ns / 1ps

module OV7670_VGA_Display (
    // global signals
    input logic clk,
    input logic reset,
    // ov7670 signals
    output logic ov7670_xclk,
    input logic ov7670_pclk,
    input logic ov7670_href,
    input logic ov7670_v_sync,
    input logic [7:0] ov7670_data,
    // export signals
    input logic [4:0] sw,
    output logic h_sync,
    output logic v_sync,
    output logic [3:0] red_port,
    output logic [3:0] green_port,
    output logic [3:0] blue_port
);

    logic [9:0] x_pixel, y_pixel;
    logic we, DE;
    logic [16:0] wAddr, rAddr;
    logic [15:0] wData, rData;
    logic w_rclk, d_en, rclk;
    logic [3:0] red, green, blue;
    logic [3:0] red_filter, green_filter, blue_filter;
    logic [3:0] red_gray, green_gray, blue_gray;

    assign red_port = sw[3] ? red_gray : red_filter; 
    assign green_port = sw[3] ? green_gray : green_filter; 
    assign blue_port = sw[3] ? blue_gray : blue_filter; 

    pixel_clk_gen U_OV7670_CLK_Gen (
        .clk  (clk),
        .reset(reset),
        .pclk (ov7670_xclk)
    );

    OV7670_MemController U_OV7670_MemController (
        .pclk       (ov7670_pclk),
        .reset      (reset),
        .href       (ov7670_href),
        .v_sync     (ov7670_v_sync),
        .ov7670_data(ov7670_data),
        .we         (we),
        .wAddr      (wAddr),
        .wData      (wData)
    );

    Frame_Buffer U_Frame_Buffer (
        .wclk (ov7670_pclk),
        .we   (we),
        .wAddr(wAddr),
        .wData(wData),
        .rclk (rclk),
        .oe   (d_en),
        .rAddr(rAddr),
        .rData(rData)
    );

    VGA_Controller U_VGA_Controller (
        .clk    (clk),
        .reset  (reset),
        .rclk   (w_rclk),
        .h_sync (h_sync),
        .v_sync (v_sync),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .DE     (DE)
    );

    QVGA_MemController U_QVGA_MemController (
        .sw        (sw[4]),
        .clk       (w_rclk),
        .x_pixel   (x_pixel),
        .y_pixel   (y_pixel),
        .DE        (DE),
        .rclk      (rclk),
        .d_en      (d_en),
        .rAddr     (rAddr),
        .rData     (rData),
        .red_port  (red),
        .green_port(green),
        .blue_port (blue)
    );

    RGB_filtering U_RGB_filtering(
        .sw(sw[2:0]),
        .red(red),
        .green(green),
        .blue(blue),
        .red_filter(red_filter),
        .green_filter(green_filter),
        .blue_filter(blue_filter)
    );

    Gray_filtering U_Gray_filtering(
        .red(red),
        .green(green),
        .blue(blue),
        .red_Gray(red_gray),
        .green_Gray(green_gray),
        .blue_Gray(blue_gray)
    );

endmodule