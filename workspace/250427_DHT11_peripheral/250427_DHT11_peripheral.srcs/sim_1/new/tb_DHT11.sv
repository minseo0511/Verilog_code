`timescale 1ns / 1ps

module tb_dht11_peri();

    // Input signals
    reg PCLK;
    reg PRESET;
    reg [3:0] PADDR;
    reg [31:0] PWDATA;
    reg PWRITE;
    reg PENABLE;
    reg PSEL;
    
    // Output signals
    wire [31:0] PRDATA;
    wire PREADY;
    
    // dht_io inout signal
    reg dht_sensor_data;
    reg io_oe;
    wire dht_io;

    // Instantiate the DUT
    dht11_peri DUT (
        .PCLK(PCLK),
        .PRESET(PRESET),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PSEL(PSEL),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .dht_io(dht_io)
    );

    // Tri-state control for dht_io
    assign dht_io = (io_oe) ? dht_sensor_data : 1'bz;

    // Clock generation
    always #5 PCLK = ~PCLK;

    integer i,j;

    // Test procedure
    initial begin
        // Initial values
        PCLK = 0;
        PRESET = 1;
        PADDR = 4'b0;
        PWDATA = 32'b0;
        PWRITE = 0;
        PENABLE = 0;
        PSEL = 0;
        i = 0;
        j = 0;
        io_oe = 0;
        dht_sensor_data = 0;

        // Reset the system
        #10 PRESET = 0;

        for(j=0;j<2;j=j+1) begin
            
            @(posedge PCLK);
            // write
            PADDR      = 0;
            PWDATA     = {31'b0,1'b1};
            PWRITE     = 1;
            PSEL       = 1;
            PENABLE    = 0;
            @(posedge PCLK);
            PSEL       = 1;
            PENABLE    = 1;
            wait(PREADY);
            @(posedge PCLK);
            PSEL       = 0;
            PENABLE    = 0;

            // read
            @(posedge PCLK);
            PADDR      = 8;
            PWDATA     = 0;
            PWRITE     = 0;
            PSEL       = 1;
            PENABLE    = 0;
            @(posedge PCLK);
            PSEL       = 1;
            PENABLE    = 1;
            @(posedge PCLK);
            // 18msec 대기
            // #18000000;
            wait(dht_io);
            #50000;
            // 입력 모드로 변환
            io_oe = 1;

            // SYNC_LOW
            dht_sensor_data = 0;
            #80000; //80us

            // SYNC_HIGH
            dht_sensor_data = 1;
            #80000; //80us

            // DATA_START
            dht_sensor_data = 0;
            #50000; //50us        

            for(i=0;i<10;i=i+1) begin
                
                dht_sensor_data = 1;
                #20000; //20us '0'
                dht_sensor_data = 0;
                #50000; 
                
                // DATA(40bit) 입력 시작
                dht_sensor_data = 1;
                #60000; //60us '1'

                // DATA_START
                dht_sensor_data = 0;
                #50000; 

                // DATA(40bit) 입력 시작
                dht_sensor_data = 1;
                #20000; //20us '0'
                dht_sensor_data = 0;
                #50000; 

                // DATA(40bit) 입력 시작
                dht_sensor_data = 1;
                #60000; //60us '1'

                // DATA_START
                dht_sensor_data = 0;
                #50000; 
            end
            dht_sensor_data = 0;
            #50000; //50us 
            io_oe = 0;
                #50000;

            // wait(PREADY);
            @(posedge PCLK);
            PSEL       = 0;
            PENABLE    = 0;
            
            @(posedge PCLK);
        end

        $stop;
    end

endmodule
