`timescale 1ns / 1ps

// in, out 선언 없이 선만 연결
interface ram_intf(
    input bit clk
    ); // bit: x,z가 없는 2state(0,1) 
    logic [4:0] addr;
    logic [7:0] wData;
    logic we;
    logic [7:0] rData;

    clocking cb @(posedge clk); // testbench 기준으로 input, output(DUT와 반대)
        default input #1 output #1;
        output addr, wData, we;
        input rData;
    endclocking

endinterface //ram_intf

class transaction;
    rand logic [4:0] addr;
    rand logic [7:0] wData;
    rand logic we;
    logic [7:0] rData; // ram 입장에서 출력이기 때문에 randx
    
    task display (string name);
        $display("[%S] addr=%h, wData=%h, we=%d, rData=%h",name,addr,wData,we,rData);
    endtask
endclass //transaction

class generator;
    mailbox #(transaction) GenToDrv_mbox;

    function new(mailbox #(transaction) GenToDrv_mbox);
        this.GenToDrv_mbox = GenToDrv_mbox; // 매개변수로 들어온 값을 reference 값을 넣는다.
    endfunction //new()

    task run(int repeat_counter);
        transaction ram_tr; // handler
        repeat (repeat_counter) begin
            ram_tr = new(); 
            //ram_tr.randomize();
            if (!ram_tr.randomize()) $error("Randomization failed!!!"); // random 생성되지 않으면
            ram_tr.display("GEN");
            GenToDrv_mbox.put(ram_tr);
            #20; // 계속 값을 생성하여 delay 추가    
        end
    endtask //run
endclass //generator

class driver;
    mailbox #(transaction) GenToDrv_mbox;
    virtual ram_intf ram_if;
    function new(mailbox #(transaction) GenToDrv_mbox, virtual ram_intf ram_if);
        this.GenToDrv_mbox = GenToDrv_mbox;
        this.ram_if = ram_if;
    endfunction //new()

    task run ();
        transaction ram_tr;
        forever begin
            @(ram_if.cb);
            GenToDrv_mbox.get(ram_tr);
            ram_if.cb.addr <= ram_tr.addr; //sw값을 hw로 전달
            ram_if.cb.wData <= ram_tr.wData;
            ram_if.cb.we <= ram_tr.we;
            ram_tr.display("DRV");
            @(ram_if.cb);
            ram_if.cb.we <= 1'b0;
        end
    endtask //run
endclass //driver

class monitor;
    mailbox #(transaction) MonToSCB_mbox;
    virtual ram_intf ram_if;

    function new(mailbox #(transaction) MonToSCB_mbox, virtual ram_intf ram_if);
        this.MonToSCB_mbox = MonToSCB_mbox;
        this.ram_if = ram_if;
    endfunction //new()

    task run ();
        transaction ram_tr;
        forever begin
            //@(posedge ram_if.clk);
            @(ram_if.cb);
            ram_tr = new();
            ram_tr.addr = ram_if.addr; // Hw값을 sw로 전달
            ram_tr.wData = ram_if.wData;
            ram_tr.we = ram_if.we;
            ram_tr.rData = ram_if.rData;
            ram_tr.display("MON");
            MonToSCB_mbox.put(ram_tr);
        end
    endtask //run
endclass //monitor

class scoreboard;
    mailbox #(transaction) MonToSCB_mbox;

    logic [7:0] ref_model[0:2**5-1];


    function new(mailbox #(transaction) MonToSCB_mbox);
        this.MonToSCB_mbox = MonToSCB_mbox;
        foreach (ref_model[i]) ref_model[i] = 0;    // foreach는 값을 알아서 count
    endfunction //new()

    task run ();
        transaction ram_tr;
        forever begin
            MonToSCB_mbox.get(ram_tr);
            ram_tr.display("SCB");
            if(ram_tr.we) begin
                ref_model[ram_tr.addr] = ram_tr.wData; // interface에서 DUT로 가지 않고 입력되는 wdata
            end
            else begin //DUT에서 출력되는 rData와 interface에서 입력한 wData를 비교
                if(ref_model[ram_tr.addr] === ram_tr.rData) begin // === -> 4state까지 전부 확인한다.
                    $display("PASS!! Matched Data! ref_model: %h == rData: %h",
                    ref_model[ram_tr.addr], ram_tr.rData);
                end
                else begin
                    $display("FAIL!! Dismatched Data! ref_model: %h == rData: %h",
                    ref_model[ram_tr.addr], ram_tr.rData);
                end
            end
        end
    endtask //run    
endclass //scoreboard

class envirnment;
    mailbox #(transaction) GenToDrv_mbox;
    mailbox #(transaction) MonToSCB_mbox;
    generator ram_gen;
    driver ram_drv;
    monitor ram_mon;
    scoreboard ram_scb;

    function new(virtual ram_intf ram_if);
        GenToDrv_mbox = new();
        MonToSCB_mbox = new();
        ram_gen = new(GenToDrv_mbox);
        ram_drv = new(GenToDrv_mbox, ram_if);
        ram_mon = new(MonToSCB_mbox, ram_if);
        ram_scb = new(MonToSCB_mbox);
    endfunction //new()

    task run (int count);
        fork
            ram_gen.run(count);
            ram_drv.run();
            ram_mon.run();
            ram_scb.run();  
        join_any
    endtask //run
endclass //envirnment

module tb_ram();
    bit clk;
    
    envirnment env;

    ram_intf ram_if(clk); // ()가 있어야 HW적으로 생성

    ram dut(.intf(ram_if));

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        env = new(ram_if);
        env.run(10);
        #50;
        $finish;
    end
endmodule