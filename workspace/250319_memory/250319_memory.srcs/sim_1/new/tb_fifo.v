`timescale 1ns / 1ps

module tb_fifo();

    reg clk, reset, wr, rd;
    reg [7:0] wdata;
    wire full, empty;
    wire [7:0] rdata;

    fifo DUT(
        .clk(clk),
        .reset(reset),
        .wdata(wdata),
        .wr(wr),
        .rd(rd),
        .full(full),
        .empty(empty),
        .rdata(rdata)
    );

    always #5 clk = ~clk;   // 10ns 주기 클럭

    // 테스트 변수들
    integer i;
    reg rand_rd;
    reg rand_wr;
    reg [7:0] compare_data[2**4:0];
    integer write_count;
    integer read_count;
    reg [7:0] rand_data;
    

    initial begin
        clk = 0;
        reset = 1;
        wr = 0;
        rd = 0;
        write_count = 0;
        read_count = 0;

        #20;
        reset = 0;
        @(posedge clk);
        wr = 1;
        // 초기화 끝난 후 클럭 동기 맞추기
        // 쓰기 먼저 진행
        for(i=0; i<17; i=i+1) begin
            rand_data = $random % 8'hFF;
            wdata = rand_data;
            @(posedge clk);
        end
        wr = 0; 
        rd = 1;
        @(posedge clk);
        for(i=0; i<17; i=i+1) begin
            @(posedge clk);
        end

        wr = 0;
        rd = 0;
        @(posedge clk);
        wr = 1;
        rd = 1;
        @(posedge clk);
        for(i=0; i<17; i=i+1) begin
            wdata = i*2+1;
            @(posedge clk);
        end
        
        wr = 0;
        @(posedge clk);
        rd = 0;
        @(posedge clk);
        @(posedge clk);

        for(i=0; i<50; i=i+1) begin
            @(negedge clk); // 쓰기 wdata를 negedge에서 시작
            rand_wr = $random%2;
            if (~full & rand_wr) begin // full이 아니면서 wr이 1일때만 새로운 wdata 생성
                wdata = $random % 8'hFF; // random값 생성
                compare_data[write_count%16] = wdata; // read data와 비교
                write_count = write_count + 1;
                wr = 1;
            end
            else begin
                wr = 0;
            end

            rand_rd = $random%2;
            if (~empty & rand_rd) begin
                #2;
                rd = 1;
                if (rdata == compare_data[read_count%16]) begin
                    $display("pass");
                end
                else begin
                    $display("fail: rdata = %h, compare_data = %h", rdata, compare_data[read_count%16]);
                end
                read_count = read_count + 1;
            end
            else begin
                rd = 0;
            end
        end
        #10;
        $stop;
    end

endmodule
