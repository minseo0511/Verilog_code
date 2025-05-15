`timescale 1ns / 1ps

module slave(
    input logic clk,
    input logic reset,
    // master to slave
    input logic [31:0]PADDR,
    input logic PWRITE,
    input logic PSEL,
    input logic PENABLE,
    input logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic PREADY
    );

    logic [31:0] RegFile[0:2**32-1];

     initial begin
        for (int i = 0; i < 2**32-1; i++) begin
            RegFile[i] = 10 + i;
        end
    end
    
    always_ff @(posedge clk) begin
        if (PWRITE) RegFile[PADDR] <= PWDATA;
    end

    assign RData1 = (PADDR != 0) ? RegFile[PADDR] : 32'b0;

endmodule
