`timescale 1ns / 1ps

module QVGA_MemController (
    // VGA Controller side
    input  logic        clk,
    input  logic [ 9:0] x_pixel,
    input  logic [ 9:0] y_pixel,
    input  logic        DE,
    // frame buffer side
    output logic        rclk,
    output logic        d_en,
    output logic [16:0] rAddr,
    input  logic [15:0] rData,
    // export side
    input  logic        sw,
    output logic [ 3:0] red_port,
    output logic [ 3:0] green_port,
    output logic [ 3:0] blue_port
);
    logic display_en;
    logic [16:0] rAddr_nom;
    logic [16:0] rAddr_up;

    assign rclk = clk;

    assign display_en = (x_pixel < 640 && y_pixel < 480);
    assign display_en_nom = (x_pixel < 320 && y_pixel < 240);
    
    assign d_en = sw ? display_en : display_en_nom;

    assign rAddr_nom = display_en ? (y_pixel * 320 + x_pixel) : 0;
    assign rAddr_up = display_en ? ((y_pixel/2) * 320) + (x_pixel / 2) : 0;

    assign rAddr = sw ? rAddr_up : rAddr_nom;

    assign {red_port, green_port, blue_port} = d_en ? {rData[15:12], rData[10:7], rData[4:1]} : 12'b0;
endmodule
