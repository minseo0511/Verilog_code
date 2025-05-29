`timescale 1ns / 1ps

module Image_Rom (
    input  logic [9:0] x_pixel,
    input  logic [9:0] y_pixel,
    input  logic       DE,
    output logic [3:0] red_port,
    output logic [3:0] green_port,
    output logic [3:0] blue_port
);

    logic [16:0] image_addr;
    logic [15:0] image_data; // RGB565 => 16'b rrrrr gggggg bbbbb 상위 4bit 씩 사용

    assign image_addr = (320 * y_pixel) + x_pixel;
    assign {red_port, green_port, blue_port} = DE ? {image_data[15:12], image_data[10:7], image_data[4:1]} : 12'b0;

    rom U_rom(
        .addr(image_addr),
        .data(image_data)
    );    

endmodule

module rom (
    input  logic [16:0] addr,
    output logic [15:0] data
);

    logic [15:0] rom[0:320*240-1];

    assign data = rom[addr];
endmodule
