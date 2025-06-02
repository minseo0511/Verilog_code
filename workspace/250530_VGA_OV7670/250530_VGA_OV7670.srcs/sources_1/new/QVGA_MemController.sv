`timescale 1ns / 1ps

module QVGA_MemController (
    input logic [1:0]   sw,
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
    output logic [ 3:0] red_port,
    output logic [ 3:0] green_port,
    output logic [ 3:0] blue_port
);
    logic display_en;
    logic [16:0] raddr_rom, raddr_ram;
    logic [15:0] data_rom;

    rom U_bg_rom(
        .addr(raddr_rom),
        .data(data_rom)
    );

    assign rclk = clk;

    //assign display_en = (x_pixel < 320 && y_pixel < 240);
    assign d_en = display_en;

    //assign rAddr = display_en ? (y_pixel * 320 + x_pixel) : 0;
    assign raddr_rom = display_en ? (y_pixel * 320 + x_pixel) : 0;
    assign rAddr = sw[1] ? raddr_rom : raddr_ram;

     always_comb begin
        if(sw[0]) begin
            display_en = (x_pixel < 640 && y_pixel < 480);
            raddr_ram = display_en ? (320 * (y_pixel/2) + (x_pixel/2)) : 0;
            {red_port, green_port, blue_port} = {rData[15:12], rData[10:7], rData[4:1]};
        end
        else if(sw[1]) begin
            if((rData[15:12] < 4'b0110) && (rData[4:1] < 4'b0110) && (rData[10:7] >= 4'b1100)) begin
                display_en = (x_pixel < 320 && y_pixel < 240);
                {red_port, green_port, blue_port} = {data_rom[15:12], data_rom[10:7], data_rom[4:1]};
            end
        end
        else begin
            display_en = (x_pixel < 320 && y_pixel < 240);
            raddr_ram = display_en ? (y_pixel * 320 + x_pixel) : 0;
            {red_port, green_port, blue_port} = {rData[15:12], rData[10:7], rData[4:1]};
        end
    end
endmodule

module rom (
    input  logic [16:0] addr,
    output logic [15:0] data
);

    logic [15:0] rom[0:320*240-1];

    initial begin
        $readmemh("Lenna.mem", rom); // h면 hex
    end

    assign data = rom[addr];
endmodule