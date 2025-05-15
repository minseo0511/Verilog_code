`timescale 1ns / 1ps

module tb_mem_ip();

    parameter ADDR_WIDTH = 4, DATA_WIDTH = 8;

    reg clk;
    reg [ADDR_WIDTH-1:0] waddr;
    reg [DATA_WIDTH-1:0] wdata;
    reg wr;
    wire [DATA_WIDTH-1:0] rdata;

    ram_ip DUT(
        .clk(clk),
        .waddr(waddr),
        .wdata(wdata),
        .wr(wr),
        .rdata(rdata)
    );

    always #5 clk = ~clk;
    integer  i;
    reg [DATA_WIDTH-1:0] rand_data;
    reg [ADDR_WIDTH-1:0] rand_addr;

    initial begin
        clk = 0;
        waddr = 0;
        wdata = 0;
        wr = 0;

        #10;
        for(i=0; i<50; i=i+1) begin
            @(posedge clk);
            // 난수 발생기
            rand_addr = $random%8; // 난수의 모수 16중 1개
            rand_data = $random%256;
            // 쓰기
            wr = 1;
            waddr = rand_addr;
            wdata = rand_data;
            @(posedge clk);
            // 읽기
            waddr = rand_addr;
            #10;
            // == 값비교, === case 비교(0,1,x,z까지 다 비교 값비교시 x는 같다고 출력)
            if(rdata === wdata) begin // 입출력 비교
                $display("pass");
            end
            else begin
                $display("fail addr = %d, data = %h", waddr, rdata);
            end
        end
        $stop;
    end

endmodule
