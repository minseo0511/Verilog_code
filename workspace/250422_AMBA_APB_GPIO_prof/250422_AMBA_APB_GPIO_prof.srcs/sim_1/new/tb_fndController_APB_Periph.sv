`timescale 1ns / 1ps

class transaction;
    // APB Interface Signals
    rand logic [ 3:0] PADDR;
    rand logic [31:0] PWDATA;
    rand logic        PWRITE;
    rand logic        PENABLE;
    rand logic        PSEL;
    logic      [31:0] PRDATA;
    logic             PREADY;
    // export signals
    logic      [ 3:0] fnd_Comm;  // dut out data
    logic      [ 7:0] fnd_Font;  // dut out data

    // 제약을 줄 수 있다.(비율도 가능)
    constraint c_paddr {PADDR inside {4'h0, 4'h4, 4'h8};}
    constraint c_wdata {PWDATA < 10;}

    task display(string name);
        $display(
            "[%s] PAAR = %h, PWATA = %h, PWRITE = %h, PENABLE = %h, PSEL = %h, PRDATA = %h, PREADY = %h, fndComm=%h, fmdFont=%h",
            name, PADDR, PWDATA, PWRITE, PENABLE, PSEL, PRDATA, PREADY,
            fnd_Comm, fnd_Font);
    endtask  //display
endclass  //transaction

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
    // export signals
    logic [ 3:0] fnd_Comm;  // dut out data
    logic [ 7:0] fnd_Font;  // dut out data

endinterface  //APB_Slave_Interface

class generator;
    mailbox #(transaction) Gen2Drv_mbox;
    event gen_next_event;

    function new(mailbox#(transaction) Gen2Drv_mbox, event gen_next_event);
        this.Gen2Drv_mbox   = Gen2Drv_mbox; // 멤버변수 = 매개변수(이름이 같으면 매개변수가 우선순위)
        this.gen_next_event = gen_next_event;
    endfunction  //new()

    task run(int repeat_counter);
        transaction fnd_tr;  // 1개의 handler
        repeat (repeat_counter) begin
            fnd_tr = new();  // make instance
            if (!fnd_tr.randomize()) // if내의 구문을 먼저 실행하고 이를 조건으로 판단
                $error(
                    "Randomization fail"
                );  // random 생성 실패 시 error 출력
            fnd_tr.display("GEN");
            Gen2Drv_mbox.put(fnd_tr);  //Queue의 push
            @(gen_next_event);  // wait event from driver (== wait(gen_next_event.triggered))
        end
    endtask  //
endclass  //generator

class driver;
    virtual APB_Slave_Interface fnd_intf;
    mailbox #(transaction) Gen2Drv_mbox;
    event gen_next_event;
    transaction fnd_tr;

    function new(virtual APB_Slave_Interface fnd_intf,
                 mailbox#(transaction) Gen2Drv_mbox, event gen_next_event);
        this.fnd_intf = fnd_intf;
        this.Gen2Drv_mbox = Gen2Drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction  //new()

    task run();
        forever begin
            Gen2Drv_mbox.get(fnd_tr);  // Queue의 pop
            // Pop reference 값 this.fnd_tr에 저장 

            fnd_tr.display("DRV");
            // write
            // SETUP
            @(posedge fnd_intf.PCLK);
            fnd_intf.PADDR   <= fnd_tr.PADDR;
            fnd_intf.PWDATA  <= fnd_tr.PWDATA;
            fnd_intf.PWRITE  <= 1'b1;
            fnd_intf.PENABLE <= 1'b0;
            fnd_intf.PSEL    <= 1'b1;
            // ACCESS
            @(posedge fnd_intf.PCLK);
            fnd_intf.PADDR   <= fnd_tr.PADDR;
            fnd_intf.PWDATA  <= fnd_tr.PWDATA;
            fnd_intf.PWRITE  <= 1'b1;
            fnd_intf.PENABLE <= 1'b1;
            fnd_intf.PSEL    <= 1'b1;
            wait (fnd_intf.PREADY == 1'b1);
            @(posedge fnd_intf.PCLK);
            @(posedge fnd_intf.PCLK);
            @(posedge fnd_intf.PCLK);
            ->gen_next_event;  // -> event trigger 신호
        end
    endtask  //run
endclass  //driver

class monitor;
    virtual APB_Slave_Interface fnd_intf;
    mailbox #(transaction) Mon2SCB_mbox;
    transaction fnd_tr;

    function new(virtual APB_Slave_Interface fnd_intf,
                 mailbox#(transaction) Mon2SCB_mbox);
        this.fnd_intf = fnd_intf;
        this.Mon2SCB_mbox = Mon2SCB_mbox;
    endfunction  //new()

    task run();
        forever begin
            @(posedge fnd_intf.PCLK);
            fnd_tr = new();
            fnd_tr.PAADR = fnd_intf.PADDR;
            fnd_tr.PWRITE  = fnd_intf.PWRITE;
            fnd_tr.PWDATA = fnd_intf.PWDATA;
            fnd_tr.PENABLE = fnd_intf.PENABLE;
            fnd_tr.PSEL    = fnd_intf.PSEL;
            wait (fnd_intf.PREADY == 1'b1);
            fnd_tr.PRDATA   = fnd_intf.PRDATA;
            fnd_tr.fnd_Comm = fnd_intf.fnd_Comm;
            fnd_tr.fnd_Font = fnd_intf.fnd_Font;
            fnd_tr.display("MON");
            Mon2SCB_mbox.put(fnd_tr);
        end
    endtask  //run
endclass  //monitor

class scoreboard;
    mailbox #(transaction) Mon2SCB_mbox;
    transaction fnd_tr;

    logic [3:0] ref_fndComm;
    logic [7:0] ref_fndFont;

    function new(mailbox#(transaction) Mon2SCB_mbox);
        this.Mon2SCB_mbox = Mon2SCB_mbox;
    endfunction  //new()

    task run();
        forever begin
            Mon2SCB_mbox.get(fnd_tr);
            fnd_tr.display("SCB");
            if (fnd_tr.PSEL && fnd_tr.PENABLE) begin
                if (fnd_tr.PWRITE) begin

                end else begin
                    if (fnd_tr.PADDR[3:2] == 2'b00) begin

                    end else
                    if (fnd_tr.PADDR[3:2] == 2'b01) begin

                    end else if (fnd_tr.PADDR[3:2] == 2'b10) begin

                    end
                end
            end
            // if(fnd_tr.PSEL && fnd_tr.PENABLE) begin
            //     if(fnd_tr.PWRITE) begin
            //         if(fnd_tr.PADDR == 2'b00) begin
            //             ref_fcr = fnd_tr.PWDATA;
            //         end
            //         else if(fnd_tr.PADDR == 2'b01) begin
            //             ref_fmr = fnd_tr.PWDATA;
            //         end
            //         else if(fnd_tr.PADDR == 2'b10) begin
            //             ref_fdr = fnd_tr.PWDATA;
            //         end
            //     end
            //     else begin
            //         if(fnd_tr.PADDR == 2'b00) begin
            //             if(ref_fcr == fnd_tr.PRDATA) begin 
            //                 $display("PASS!! Matched Data! ref_fcr: %h == PRDATA: %h", ref_fcr, fnd_tr.PRDATA);
            //             end
            //             else begin
            //                 $display("FAIL!! Dismatched Data! ref_fcr: %h == PRDATA: %h", ref_fcr, fnd_tr.PRDATA);
            //             end
            //         end
            //         if(fnd_tr.PADDR == 2'b01) begin
            //             if(ref_fmr == fnd_tr.PRDATA) begin 
            //                 $display("PASS!! Matched Data! ref_fmr: %h == PRDATA: %h", ref_fmr, fnd_tr.PRDATA);
            //             end
            //             else begin
            //                 $display("FAIL!! Dismatched Data! ref_fmr: %h == PRDATA: %h", ref_fmr, fnd_tr.PRDATA);
            //             end
            //         end
            //         if(fnd_tr.PADDR == 2'b10) begin
            //             if(ref_fdr == fnd_tr.PRDATA) begin 
            //                 $display("PASS!! Matched Data! ref_fdr: %h == PRDATA: %h", ref_fcr, fnd_tr.PRDATA);
            //             end
            //             else begin
            //                 $display("FAIL!! Dismatched Data! ref_fdr: %h == PRDATA: %h", ref_fcr, fnd_tr.PRDATA);
            //             end
            //         end
            //     end
            // end
        end
    endtask  //run
endclass  //scoreboard

class envirnment;
    mailbox #(transaction) Gen2Drv_mbox;
    mailbox #(transaction) Mon2SCB_mbox;
    generator              fnd_gen;
    driver                 fnd_drv;
    monitor                fnd_mon;
    scoreboard             fnd_scb;
    event                  gen_next_event;

    // 생성자
    function new(virtual APB_Slave_Interface fnd_intf);
        Gen2Drv_mbox = new();
        Mon2SCB_mbox = new();
        this.fnd_gen = new(Gen2Drv_mbox, gen_next_event);
        this.fnd_drv = new(fnd_intf, Gen2Drv_mbox, gen_next_event);
        this.fnd_mon = new(fnd_intf, Mon2SCB_mbox);

    endfunction  //new()

    // process
    task run(int count);
        fork
            fnd_gen.run(count);
            fnd_drv.run();
        join_any // 동시 동작
        // fnd_gen.run이 count만큼 동작하고 끝난다.
    endtask  //run
endclass  //envirnment

module tb_fndController_APB_Periph ();

    envirnment fnd_env;
    APB_Slave_Interface fnd_intf(); // interface는 new를 만들지 않고 ()로 instance 생성(sw가 아닌 hw)

    always #5 fnd_intf.PCLK = ~fnd_intf.PCLK;

    FND_Periph dut (
        .PCLK(fnd_intf.PCLK),
        .PRESET(fnd_intf.PRESET),
        .PADDR(fnd_intf.PADDR),
        .PWDATA(fnd_intf.PWDATA),
        .PWRITE(fnd_intf.PWRITE),
        .PENABLE(fnd_intf.PENABLE),
        .PSEL(fnd_intf.PSEL),
        .PRDATA(fnd_intf.PRDATA),
        .PREADY(fnd_intf.PREADY),
        .fnd_Comm(fnd_intf.fnd_Comm),
        .fnd_Font(fnd_intf.fnd_Font)
    );

    initial begin
        fnd_intf.PCLK   = 0;
        fnd_intf.PRESET = 1;
        #10 fnd_intf.PRESET = 0;
        fnd_env = new(fnd_intf);
        fnd_env.run(10);
        #30;
        $finish;
    end
endmodule
