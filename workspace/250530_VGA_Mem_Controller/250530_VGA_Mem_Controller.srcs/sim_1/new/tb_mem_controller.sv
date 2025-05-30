`timescale 1ns / 1ps

module tb_mem_controller();

    logic PCLK;
    logic reset;
    logic HREF;
    logic Vsync;
    logic [7:0] Data;
    logic FCLK;
    logic [15:0] wAddr;
    logic [15:0] wData;
    logic We;

    MemController dut(
        .PCLK(PCLK),
        .reset(reset),
        .HREF(HREF),
        .Vsync(Vsync),
        .Data(Data),
        .FCLK(FCLK),
        .wAddr(wAddr),
        .wData(wData),
        .We(We)
    );

    always #20 PCLK = ~PCLK;
    initial begin
        PCLK = 0; reset = 1;
        #40;
        reset = 0;


        @(posedge PCLK);
        HREF = 1; Data = 8'hf0;
        @(posedge PCLK);
        HREF = 0;
        @(posedge PCLK);
        @(posedge PCLK);
        Data = 8'h0f;
        @(posedge PCLK);
        HREF = 1;

        #400;
        $finish;

    end

endmodule
