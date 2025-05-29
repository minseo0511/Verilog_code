`timescale 1ns / 1ps

module VGA_Controller (
    input  logic       clk,
    input  logic       reset,
    input logic [3:0] sw_red,
    input logic [3:0] sw_green,
    input logic [3:0] sw_blue,
    input logic         mode_sw,
    output logic       h_sync,
    output logic       v_sync,
    output logic [3:0] red_port,
    output logic [3:0] green_port,
    output logic [3:0] blue_port
);

    logic DE;
    logic [9:0] x_pixel, y_pixel;
    logic [3:0] red_port_tv, green_port_tv, blue_port_tv;
    logic [3:0] red_port_sw, green_port_sw, blue_port_sw;

    assign red_port = mode_sw ? red_port_tv : red_port_sw;
    assign green_port = mode_sw ? green_port_tv : green_port_sw;
    assign blue_port = mode_sw ? blue_port_tv : blue_port_sw;

    VGA_Decoder U_VGA_Decoder (
        .clk    (clk),
        .reset  (reset),
        .h_sync (h_sync),
        .v_sync (v_sync),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .DE     (DE)
    );

    vga_rgb_tv U_vga_rgb_tv (
        .x_pixel   (x_pixel),
        .y_pixel   (y_pixel),
        .DE        (DE),
        .red_port2  (red_port_tv),
        .green_port2(green_port_tv),
        .blue_port2 (blue_port_tv)
    );

    vga_rgb_switch U_vga_rgb_switch (
        .sw_red    (sw_red),
        .sw_green  (sw_green),
        .sw_blue   (sw_blue),
        .DE        (DE),
        .red_port  (red_port_sw),
        .green_port(green_port_sw),
        .blue_port (blue_port_sw)
    );

endmodule


module VGA_Decoder (
    input  logic       clk,
    input  logic       reset,
    output logic       h_sync,
    output logic       v_sync,
    output logic [9:0] x_pixel,
    output logic [9:0] y_pixel,
    output logic       DE
);

    logic pclk;
    logic [9:0] h_counter, v_counter;

    pixel_clk_gen U_Pix_CLK_Gen (
        .clk  (clk),
        .reset(reset),
        .pclk (pclk)
    );

    pixel_counter U_Pixel_Counter (
        .pclk(pclk),
        .reset(reset),
        .h_counter(h_counter),
        .v_counter(v_counter)
    );

    vga_decoder1 U_vga_decoder1 (
        .h_counter(h_counter),
        .v_counter(v_counter),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .DE(DE)
    );

endmodule

module pixel_clk_gen (
    input  logic clk,
    input  logic reset,
    output logic pclk
);
    logic [1:0] p_counter;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            p_counter <= 0;
            pclk <= 0;
        end else begin
            if (p_counter == 3) begin
                p_counter <= 0;
                pclk <= 1'b1;
            end else begin
                p_counter <= p_counter + 1;
                pclk <= 1'b0;
            end
        end
    end
endmodule

module pixel_counter (
    input  logic       pclk,
    input  logic       reset,
    output logic [9:0] h_counter,
    output logic [9:0] v_counter
);

    localparam H_MAX = 800, V_MAX = 525;

    always_ff @(posedge pclk, posedge reset) begin : Horizontal_counter
        if (reset) begin
            h_counter <= 0;
        end else begin
            if (h_counter == H_MAX - 1) begin
                h_counter <= 0;
            end else begin
                h_counter <= h_counter + 1;
            end
        end
    end

    always_ff @(posedge pclk, posedge reset) begin : Vertical_counter
        if (reset) begin
            v_counter <= 0;
        end else begin
            if (h_counter == H_MAX - 1) begin
                if (v_counter == V_MAX - 1) begin
                    v_counter <= 0;
                end else begin
                    v_counter <= v_counter + 1;
                end
            end
        end
    end

endmodule

module vga_decoder1 (
    input  [9:0] h_counter,
    input  [9:0] v_counter,
    output       h_sync,
    output       v_sync,
    output [9:0] x_pixel,
    output [9:0] y_pixel,
    output       DE
);

    localparam H_Visible_area = 640;
    localparam H_Front_porch = 16;
    localparam H_Sync_pulse = 96;
    localparam H_Back_porch = 48;
    localparam H_Whole_line = 800;

    localparam V_Visible_area = 480;
    localparam V_Front_porch = 10;
    localparam V_Sync_pulse = 2;
    localparam V_Back_porch = 33;
    localparam V_Whole_line = 525;

    assign h_sync = !((h_counter >= (H_Visible_area + H_Front_porch)) && (h_counter < (H_Visible_area + H_Front_porch + H_Sync_pulse)));
    assign v_sync = !((v_counter >= (V_Visible_area + V_Front_porch)) && (v_counter < (V_Visible_area + V_Front_porch + V_Sync_pulse)));
    assign DE = (h_counter < H_Visible_area) && (v_counter < V_Visible_area);
    assign x_pixel = DE ? h_counter : 10'bz;
    assign y_pixel = DE ? v_counter : 10'bz;

endmodule
