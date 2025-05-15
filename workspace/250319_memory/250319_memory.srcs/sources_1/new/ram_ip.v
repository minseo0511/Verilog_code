`timescale 1ns / 1ps

// single port RAM
module ram_ip #(parameter ADDR_WIDTH = 4, DATA_WIDTH = 8)(
    input clk,
    input [ADDR_WIDTH-1:0] waddr,
    input [DATA_WIDTH-1:0] wdata,
    input wr,
    output [DATA_WIDTH-1:0] rdata
    );
    reg [DATA_WIDTH-1:0] rdata_reg; 
    reg [DATA_WIDTH-1:0] ram[0:2**ADDR_WIDTH-1]; // 2**4 = 2의 4승
    

    always @(posedge clk) begin
        if(wr) begin
            ram[waddr] <= wdata;
        end
    end

    assign rdata = ram[waddr];

/*
    assign rdata = rdata_reg;
    always @(posedge clk) begin
        if(!wr) begin
            rdata_reg <= ram[waddr];
        end
    end
*/

endmodule
