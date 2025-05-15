`timescale 1ns / 1ps

module MCU (
    input logic clk,
    input logic reset,
    inout logic [15:0] GPIO
);

    // global signal
    logic        PCLK;
    logic        PRESET;
    // APB Interface Signals
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL_RAM;
    logic        PSEL_GPIO;
    logic        PSEL2;
    logic        PSEL3;
    logic [31:0] PRDATA_RAM;
    logic [31:0] PRDATA_GPIO;
    logic [31:0] PRDATA2;
    logic [31:0] PRDATA3;
    logic        PREADY_RAM;
    logic        PREADY_GPIO;
    logic        PREADY2;
    logic        PREADY3;

    // CPU - APB Master Signals
    // Internal Interface Signals
    logic        transfer;  // trigger signal
    logic        ready;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic        write;
    logic        dataWe;
    logic [31:0] dataAddr;
    logic [31:0] dataWData;
    logic [31:0] dataRData;

    // ROM signals
    logic [31:0] instrCode;
    logic [31:0] instrMemAddr;

    assign PCLK   = clk;
    assign PRESET = reset;
    assign addr   = dataAddr;
    assign wdata  = dataWData;
    assign rdata  = dataRData;
    assign write  = dataWe;

    rom U_ROM (
        .addr(instrMemAddr),
        .data(instrCode)
    );

    RV32I_Core U_Core (.*);

    APB_Master U_APB_Master (
        .*,
        .PSEL0  (PSEL_RAM),
        .PSEL1  (PSEL_GPIO),
        .PSEL2  (),
        .PSEL3  (),
        .PRDATA0(PRDATA_RAM),
        .PRDATA1(PRDATA_GPIO),
        .PRDATA2(),
        .PRDATA3(),
        .PREADY0(PREADY_RAM),
        .PREADY1(PREADY_GPIO),
        .PREADY2(),
        .PREADY3()
    );

    ram U_RAM (
        .*,
        .PSEL  (PSEL_RAM),
        .PRDATA(PRDATA_RAM),
        .PREADY(PREADY_RAM)
    );

    GPIO_Periph U_GPIO(
        .*,
        .PSEL  (PSEL_GPIO),
        .PRDATA(PRDATA_GPIO),
        .PREADY(PREADY_GPIO),
        .ioPort(GPIO)
    );
endmodule
