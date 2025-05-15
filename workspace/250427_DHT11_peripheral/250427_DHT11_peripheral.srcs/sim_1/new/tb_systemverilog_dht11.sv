// 수정된 Scoreboard 클래스 포함 전체 테스트벤치

`timescale 1ns / 1ps

// ----------------------- Transaction -----------------------
class transaction;
    rand logic [ 3:0] PADDR;
    rand logic [31:0] PWDATA;
    rand logic        PWRITE;
    rand logic        PENABLE;
    rand logic        PSEL;
    logic      [31:0] PRDATA;
    logic             PREADY;
    logic             dht_io;

    constraint c_paddr {
        PADDR dist {
            4'h0 := 10,
            4'h4 := 10,
            4'h8 := 80
        };
    }

    constraint c_pdata_by_addr {
    if (PADDR == 4'h0 && PWRITE == 1)
        PWDATA dist { 32'd0 := 2, 32'd1 := 1, 32'd3 := 4 };
    }

    constraint c_pwrite {
        PWRITE dist {
            1 := 1, // write 트랜잭션
            0 := 1  // read 트랜잭션
        };
    }

    task display(string name);
        $display(
            "%0t : [%s] PADDR=%h, PWDATA=%h, PWRITE=%h, PENABLE=%h, PSEL=%h, PRDATA=%h, PREADY=%h",
            $time, name, PADDR, PWDATA, PWRITE, PENABLE, PSEL, PRDATA, PREADY
        );
    endtask

    task rand_delay();
        int delay = $urandom_range(40000, 60000); // 40~60us (<50 -> 0), (>50 -> 1)
        #(delay);
    endtask
endclass

// ----------------------- Interface -----------------------
interface APB_Slave_Interface;
    logic        PCLK;
    logic        PRESET;
    logic [ 3:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;
    logic        PREADY;
    tri          dht_io;
    logic        io_oe;
    logic        dht_sensor_data;

    assign dht_io = (io_oe) ? dht_sensor_data : 1'bz;
endinterface

// ----------------------- Generator -----------------------
class generator;
    mailbox #(transaction) Gen2Drv_mbox;
    event gen_next_event;

    function new(mailbox#(transaction) Gen2Drv_mbox, event gen_next_event);
        this.Gen2Drv_mbox   = Gen2Drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run(int repeat_counter);
        transaction dht_tr;
        repeat (repeat_counter) begin
            dht_tr = new();
            if (!dht_tr.randomize()) $error("Randomization fail!");
            dht_tr.display("GEN");
            Gen2Drv_mbox.put(dht_tr);
            @(gen_next_event);
            $display("Generator received event: %0t", $time);
        end
    endtask
endclass

// ----------------------- Driver -----------------------
class driver;
    virtual APB_Slave_Interface dht_interf;
    mailbox #(transaction) Gen2Drv_mbox;
    transaction dht_tr;
    event gen_next_event;

    function new(virtual APB_Slave_Interface dht_interf, mailbox#(transaction) Gen2Drv_mbox, event gen_next_event);
        this.dht_interf   = dht_interf;
        this.Gen2Drv_mbox = Gen2Drv_mbox;
    endfunction

    task run();
        forever begin
            Gen2Drv_mbox.get(dht_tr);
            dht_tr.display("DRV");

            // SETUP state
            dht_interf.PADDR   <= dht_tr.PADDR;
            dht_interf.PWRITE  <= dht_tr.PWRITE;
            dht_interf.PWDATA  <= dht_tr.PWDATA;
            dht_interf.PENABLE <= 1'b0;
            dht_interf.PSEL    <= 1'b1;
            @(posedge dht_interf.PCLK);

            // ACCESS state
            dht_interf.PENABLE <= 1'b1;
            wait (dht_interf.PREADY == 1'b1);

            if (dht_tr.PWRITE) begin
                @(posedge dht_interf.PCLK); // 그냥 write만 처리
            end else begin
                dht11_protocol(); 
            end
            // ->gen_next_event; // 다음 이벤트로 진행
            $display("Event Gen PASS!!");
        end
    endtask

    task dht11_protocol();
        $display("Start of DHT11 protocol: %0t", $time);
        
        #18000000; // 18ms LOW (MCU request start)
        dht_interf.io_oe           <= 1;
        dht_interf.dht_sensor_data <= 0;
        $display("Send start signal (18ms low): %0t", $time);
        
        #80000; // Host LOW 80us
        dht_interf.dht_sensor_data <= 1;
        $display("Send low 80us: %0t", $time);
        
        #80000; // Host HIGH 80us
        dht_interf.dht_sensor_data <= 0;
        $display("Send high 80us: %0t", $time);
        
        #50000; // Start bit
        $display("Send start bit: %0t", $time);
        
        dht11_send_bits(40); // send 40 bits
        dht_interf.dht_sensor_data <= 0;
        #50000; //50us 
        dht_interf.io_oe <= 0;
    endtask

    task dht11_send_bits(int bit_count);
        repeat(bit_count) begin
            dht_interf.dht_sensor_data <= 1;
            dht_tr.rand_delay();
            dht_interf.dht_sensor_data <= 0;
            #50000;
            $display("Send bit: %0t", $time); // 디버깅 메시지 추가
        end
    endtask
endclass

// ----------------------- Monitor -----------------------
class monitor;
    mailbox #(transaction) Mon2SCB_mbox;
    virtual APB_Slave_Interface dht_interf;
    transaction dht_tr;
    event gen_next_event;

    function new(virtual APB_Slave_Interface dht_interf, mailbox#(transaction) Mon2SCB_mbox, event gen_next_event);
        this.dht_interf   = dht_interf;
        this.Mon2SCB_mbox = Mon2SCB_mbox;
    endfunction

    task run();
        forever begin
            dht_tr = new();
            @(posedge dht_interf.PREADY);
            // @(gen_next_event);
            dht_tr.PADDR   = dht_interf.PADDR;
            dht_tr.PWDATA  = dht_interf.PWDATA;
            dht_tr.PWRITE  = dht_interf.PWRITE;
            dht_tr.PENABLE = dht_interf.PENABLE;
            dht_tr.PSEL    = dht_interf.PSEL;
            dht_tr.PRDATA  = dht_interf.PRDATA;
            dht_tr.PREADY  = dht_interf.PREADY;
            dht_tr.dht_io  = dht_interf.dht_io;
            dht_tr.display("MON");
            Mon2SCB_mbox.put(dht_tr);
        end
    endtask
endclass

// ----------------------- Scoreboard  -----------------------
class scoreboard;
    mailbox #(transaction) Mon2SCB_mbox;
    event gen_next_event;
    transaction dht_tr;
    int total_cnt, pass_cnt, fail_cnt;

    logic [31:0] ref_out;

    function new(mailbox#(transaction) Mon2SCB_mbox, event gen_next_event);
        this.Mon2SCB_mbox   = Mon2SCB_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    // Reference Model
    function [31:0] reference_model(input transaction dht_tr);
        if (dht_tr.PADDR == 4'h0 && dht_tr.PWRITE == 1) begin
            return 32'h00000001; 
        end else if (dht_tr.PADDR == 4'h4 && dht_tr.PWRITE == 0) begin
            return dht_tr.PWDATA; 
        end else if (dht_tr.PADDR == 4'h8 && dht_tr.PWRITE == 0) begin
            return dht_tr.PWDATA; 
        end else begin
            return 32'h00000000;
        end
    endfunction

    task run();
        forever begin
            // @(gen_next_event);
            Mon2SCB_mbox.get(dht_tr); 
            dht_tr.display("SCB"); 
            total_cnt++;

          
            ref_out = reference_model(dht_tr); 

            // DUT 출력과 Driver 입력 비교
            if (!dht_tr.PWRITE && dht_tr.PRDATA === ref_out) begin
                pass_cnt++;
                $display("[PASS] Expected: %h, Got: %h", ref_out, dht_tr.PRDATA); // 성공한 경우
            end else if (!dht_tr.PWRITE) begin
                fail_cnt++; 
                $display("[FAIL] Expected: %h, Got: %h", ref_out, dht_tr.PRDATA); // 실패한 경우
            end
            ->gen_next_event;
        end
    endtask

    // 보고서 출력
    task report();
        $display("=======================================");
        $display("==            Final Report           ==");
        $display("=======================================");
        $display("Total Tests : %0d", total_cnt); // 총 테스트 수
        $display("PASS : %0d", pass_cnt); // pass된 테스트 수
        $display("FAIL : %0d", fail_cnt); // 실패한 테스트 수
        $display("=======================================");
    endtask
endclass



// ----------------------- Environment -----------------------
class enviroment;
    mailbox #(transaction) Gen2Drv_mbox;
    mailbox #(transaction) Mon2SCB_mbox;
    generator  dht_gen;
    driver     dht_drv;
    monitor    dht_mon;
    scoreboard dht_scb;
    event gen_next_event;

    function new(virtual APB_Slave_Interface dht_interf);
        Gen2Drv_mbox = new();
        Mon2SCB_mbox = new();
        dht_gen = new(Gen2Drv_mbox, gen_next_event);
        dht_drv = new(dht_interf, Gen2Drv_mbox, gen_next_event);
        dht_mon = new(dht_interf, Mon2SCB_mbox, gen_next_event);
        dht_scb = new(Mon2SCB_mbox, gen_next_event);
    endfunction

    task run(int count);
        fork
            dht_gen.run(count);
            dht_drv.run();
            dht_mon.run();
            dht_scb.run();
        join_any
        dht_scb.report();
    endtask
endclass

// ----------------------- Top Module -----------------------
module tb_systemverilog_dht11();

    enviroment dht_env;
    APB_Slave_Interface dht_interf();

    dht11_peri dut (
        .PCLK(dht_interf.PCLK),
        .PRESET(dht_interf.PRESET),
        .PADDR(dht_interf.PADDR),
        .PWDATA(dht_interf.PWDATA),
        .PWRITE(dht_interf.PWRITE),
        .PENABLE(dht_interf.PENABLE),
        .PSEL(dht_interf.PSEL),
        .PRDATA(dht_interf.PRDATA),
        .PREADY(dht_interf.PREADY),
        .dht_io(dht_interf.dht_io)
    );

    always #5 dht_interf.PCLK = ~dht_interf.PCLK;

    initial begin
        dht_interf.PCLK = 0;
        dht_interf.PRESET = 1;
        #10 dht_interf.PRESET = 0;
        dht_interf.io_oe = 0;
        dht_interf.dht_sensor_data = 0;
        dht_env = new(dht_interf);
        dht_env.run(10);
        #100;
        $display("Finished!");
        $finish;
    end
endmodule
