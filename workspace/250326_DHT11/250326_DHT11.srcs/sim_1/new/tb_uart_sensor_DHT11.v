`timescale 1ns / 1ps

module tb_uart_sensor_DHT11();
    reg clk;
    reg reset;
    reg btn_start;
    reg sw_mode;
    reg rx;
    
    wire [3:0] led;
    wire dht_io;
    wire tx;
    
    reg dht_sensor_data;
    reg io_oe;

    assign dht_io = (io_oe) ? dht_sensor_data : 1'bz;

    uart_sensor_DHT11 DUT(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .btn_start(btn_start),
        .sw_mode(sw_mode),
        .tx(tx),
        .led(led),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm),
        .dht_io(dht_io)
    );

    always #5 clk = ~clk;

    integer i, j;

    initial begin
        clk = 0;
        reset = 1;
        btn_start = 0;
        io_oe = 0;
        i = 0;
        j = 0;
        sw_mode = 0;

        #100;
        reset = 0;
        for (j=0;j<2;j=j+1) begin

            rx = 0; #104160; send_bit("E"); rx = 1; 

            // 18msec 대기
            #18000000;
            //wait(dht_io);
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
             #500000;
        end
        #50000;
        $stop;
    end

    task send_bit(input [7:0] data);
        integer i;
        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i];
            #104160;
        end
    endtask

endmodule
