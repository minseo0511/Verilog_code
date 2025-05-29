`timescale 1ns / 1ps

module Gray_filtering(
    input logic [3:0] red,
    input logic [3:0] green,
    input logic [3:0] blue,
    input logic [3:0] red_Gray,
    input logic [3:0] green_Gray,
    input logic [3:0] blue_Gray
    );
    logic [11:0] gray;

    assign gray = (77*red) + (150*green) + (29*blue);

    assign red_Gray = {gray[11:8]};
    assign green_Gray = {gray[11:8]};
    assign blue_Gray = {gray[11:8]};

endmodule