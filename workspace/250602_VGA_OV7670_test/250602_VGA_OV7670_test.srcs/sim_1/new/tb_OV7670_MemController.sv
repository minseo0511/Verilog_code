`timescale 1ns / 1ps

module tb_OV7670_MemController();

    // Testbench signals
    logic clk = 0;
    logic reset = 0;
    logic href = 0;
    logic v_sync = 0;
    logic [7:0] ov7670_data = 0;
    logic we;
    logic [16:0] wAddr;
    logic [15:0] wData;

    // Instantiate the DUT
    OV7670_MemController dut (
        .pclk(clk),
        .reset(reset),
        .href(href),
        .v_sync(v_sync),
        .ov7670_data(ov7670_data),
        .we(we),
        .wAddr(wAddr),
        .wData(wData)
    );

    // Clock generation: 25MHz = 40ns period
    always #20 clk = ~clk;

    // Simulated RGB565 pattern: {R,G,B} values (just example)
    logic [15:0] pixel_array [0:5];  // simulate 6 pixels
    initial begin
        pixel_array[0] = 16'hF800;  // red
        pixel_array[1] = 16'h07E0;  // green
        pixel_array[2] = 16'h001F;  // blue
        pixel_array[3] = 16'hFFFF;  // white
        pixel_array[4] = 16'h0000;  // black
        pixel_array[5] = 16'h7BEF;  // gray
    end

    // Stimulus process
    initial begin
        $display("Starting OV7670_MemController Testbench...");
        $dumpfile("OV7670_MemController_tb.vcd");
        $dumpvars(0, tb_OV7670_MemController);

        // Reset
        reset = 1;
        #100;
        reset = 0;

        // Simulate one frame with a few pixels
        v_sync = 1;   // Start of frame
        #40;
        v_sync = 0;

        // Simulate HREF + 6 pixels
        href = 1;
        for (int i = 0; i < 6; i++) begin
            ov7670_data = pixel_array[i][15:8];  // MSB first
            #40;
            ov7670_data = pixel_array[i][7:0];   // LSB second
            #40;
        end
        href = 0;

        #200;

        $display("Simulation complete");
        $finish;
    end

    // Optional monitor
    always_ff @(posedge clk) begin
        if (we) begin
            $display("WE @ %0t ns: Addr = %0d, Data = 0x%h", $time, wAddr, wData);
        end
    end

endmodule
