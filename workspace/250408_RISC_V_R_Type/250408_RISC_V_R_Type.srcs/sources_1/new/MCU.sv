`timescale 1ns / 1ps

module MCU(
    input logic clk,
    input logic reset
    );

    logic [31:0] instrCode, instrMemAddr; 

    RV32I_Core U_RV32I_Core(.*);

    rom U_ROM(
        .addr(instrMemAddr),
        .data(instrCode)
    );
endmodule
