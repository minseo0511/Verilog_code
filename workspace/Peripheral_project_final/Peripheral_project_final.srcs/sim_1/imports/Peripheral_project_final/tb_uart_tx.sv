`timescale 1ns / 1ps

//----------------------------------------------------------------------
// Transaction class
//----------------------------------------------------------------------
class transaction;
    rand logic [4:0]  PADDR;
    rand logic [31:0] PWDATA;
    rand logic        PWRITE, PENABLE, PSEL;
    logic [31:0]      PRDATA;
    logic             PREADY;
    logic             tx;

    constraint tx_constraint {
        PADDR[4:2] == 3'd1;
        PWRITE     == 1;
        PSEL       == 1;
        PENABLE    == 1;
    }

    task display(string name);
        $display("%0t : [%s] PADDR=%h, PWDATA=%h, PWRITE=%b, PENABLE=%b, PSEL=%b, PRDATA=%h, PREADY=%b, tx=%b",
                $time, name, PADDR, PWDATA, PWRITE, PENABLE, PSEL, PRDATA, PREADY, tx);
    endtask
endclass

//----------------------------------------------------------------------
// UART Interface
//----------------------------------------------------------------------
interface uart_tx_interface;
    logic        PCLK;
    logic        PRESET;
    logic [4:0]  PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;
    logic        PREADY;
    logic        tx;
endinterface

//----------------------------------------------------------------------
// Generator
//----------------------------------------------------------------------
class generator;
    mailbox #(transaction) Gen2Drv_mbox;
    event                  gen_next_event;
    transaction            tx_tr;

    function new(mailbox #(transaction) Gen2Drv_mbox, event gen_next_event);
        this.Gen2Drv_mbox    = Gen2Drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run(int repeat_count);
        tx_tr = new();
        tx_tr.PADDR   = 5'h10;
        tx_tr.PWDATA  = 32'b11;
        tx_tr.PWRITE  = 1;
        tx_tr.PENABLE = 1;
        tx_tr.PSEL    = 1;
        tx_tr.display("GEN-INIT");
        Gen2Drv_mbox.put(tx_tr);

        repeat (repeat_count) begin
            tx_tr = new();
            if (!tx_tr.randomize()) $error("Randomization fail!");
            tx_tr.display("GEN");
            Gen2Drv_mbox.put(tx_tr);
            @(gen_next_event);
        end
    endtask
endclass

//----------------------------------------------------------------------
// Driver
//----------------------------------------------------------------------
class driver;
    mailbox #(transaction)    Gen2Drv_mbox;
    virtual uart_tx_interface tx_intf;
    transaction               tx_tr;

    function new(mailbox #(transaction) Gen2Drv_mbox,
                 virtual uart_tx_interface tx_intf);
        this.Gen2Drv_mbox = Gen2Drv_mbox;
        this.tx_intf      = tx_intf;
    endfunction

    task run();
        forever begin
            Gen2Drv_mbox.get(tx_tr);
            tx_tr.display("DRV");

            tx_intf.PADDR   <= tx_tr.PADDR;
            tx_intf.PWDATA  <= tx_tr.PWDATA;
            tx_intf.PWRITE  <= tx_tr.PWRITE;
            tx_intf.PSEL    <= 1;
            tx_intf.PENABLE <= 0;
            @(posedge tx_intf.PCLK);

            tx_intf.PENABLE <= 1;
            @(posedge tx_intf.PCLK);
            @(posedge tx_intf.PCLK);

            tx_intf.PSEL    <= 0;
            tx_intf.PWRITE  <= 0;
            tx_intf.PENABLE <= 0;
        end
    endtask
endclass

//----------------------------------------------------------------------
// Monitor
//----------------------------------------------------------------------
class monitor;
    mailbox #(transaction)    Mon2SCB_mbox;
    virtual uart_tx_interface tx_intf;
    transaction               tx_tr;

    function new(mailbox #(transaction) Mon2SCB_mbox,
                 virtual uart_tx_interface tx_intf);
        this.Mon2SCB_mbox = Mon2SCB_mbox;
        this.tx_intf      = tx_intf;
    endfunction

    task run();
        fork
            apb_monitor();
            uart_bit_monitor();
        join_none
    endtask

    task apb_monitor();
        forever begin
            @(posedge tx_intf.PREADY);
            tx_tr = new();
            tx_tr.PADDR   = tx_intf.PADDR;
            tx_tr.PWDATA  = tx_intf.PWDATA;
            tx_tr.PWRITE  = tx_intf.PWRITE;
            tx_tr.PENABLE = tx_intf.PENABLE;
            tx_tr.PSEL    = tx_intf.PSEL;
            tx_tr.PRDATA  = tx_intf.PRDATA;
            tx_tr.PREADY  = tx_intf.PREADY;
            tx_tr.tx      = 1'bx; // APB 트랜잭션에는 tx 의미 없음
            Mon2SCB_mbox.put(tx_tr);
            @(negedge tx_intf.PREADY);
        end
    endtask

    task uart_bit_monitor();
        localparam real CLK_FREQ   = 100_000_000.0;
        localparam real BAUD_RATE  = 115200.0;
        localparam int  BIT_CYCLES = int'(CLK_FREQ / BAUD_RATE);

        forever begin
            // Idle 상태 대기 (tx high)
            wait (tx_intf.tx === 1'b1);
            @(negedge tx_intf.tx);  // Start bit 감지
            repeat (BIT_CYCLES/2) @(posedge tx_intf.PCLK);

            // Start bit 트랜잭션 전송
            tx_tr = new();
            tx_tr.tx      = 1'b0;
            tx_tr.PADDR   = '0;
            tx_tr.PWDATA  = '0;
            tx_tr.PWRITE  = 0;
            tx_tr.PENABLE = 0;
            tx_tr.PSEL    = 0;
            tx_tr.PRDATA  = '0;
            tx_tr.PREADY  = 0;
            Mon2SCB_mbox.put(tx_tr);

            // 8개 데이터 비트 수신
            for (int i = 0; i < 8; i++) begin
                repeat (BIT_CYCLES) @(posedge tx_intf.PCLK);
                tx_tr = new();
                tx_tr.tx = tx_intf.tx;
                $display("[MON][UART] received bit %0d = %b", i, tx_intf.tx);
                Mon2SCB_mbox.put(tx_tr);
            end

            // Stop bit 기다리는 시간 (필요시 생략 가능)
            repeat (BIT_CYCLES) @(posedge tx_intf.PCLK);
        end
    endtask
endclass

//----------------------------------------------------------------------
// Scoreboard
//----------------------------------------------------------------------
class scoreboard;
    mailbox #(transaction) Mon2SCB_mbox;
    event                 gen_next_event;
    byte                  ref_queue[$];
    byte                  expected_data[$];
    byte                  actual_data[$];
    transaction           tx_tr;

    typedef enum logic [1:0] {IDLE, COLLECTING} state_t;
    state_t state = IDLE;

    logic [7:0] rx_shift;
    int         bit_count;
    int         match_count    = 0;
    int         mismatch_count = 0;

    function new(mailbox #(transaction) Mon2SCB_mbox, event gen_next_event);
        this.Mon2SCB_mbox   = Mon2SCB_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run();
        forever begin
            Mon2SCB_mbox.get(tx_tr);

            case (state)
                IDLE: begin
                    // APB write 감지
                    if (tx_tr.PWRITE && tx_tr.PSEL && tx_tr.PENABLE && tx_tr.PADDR[4:2] == 3'd1) begin
                        ref_queue.push_back(tx_tr.PWDATA[7:0]);
                        $display("[SCB][BUS] queued expected = %02h", tx_tr.PWDATA[7:0]);
                    end
                    // Start bit 감지
                    else if (tx_tr.tx === 1'b0) begin
                        if (ref_queue.size() == 0) begin
                            $error("[SCB] no expected byte for start!");
                            -> gen_next_event;
                        end else begin
                            state     = COLLECTING;
                            bit_count = 0;
                            rx_shift  = 0;
                            $display("[SCB] start bit detected");
                        end
                    end
                end

                COLLECTING: begin
                    if (tx_tr.tx !== 1'b0 && tx_tr.tx !== 1'b1) begin
                        $display("[SCB][WARN] Invalid tx value: %b at bit_count=%0d", tx_tr.tx, bit_count);
                        continue;
                    end
                    rx_shift[bit_count] = tx_tr.tx;
                    $display("[SCB] received bit %0d = %b", bit_count, tx_tr.tx);
                    bit_count++;

                    if (bit_count == 8) begin
                        byte expected = ref_queue.pop_front();
                        byte actual   = rx_shift;
                        expected_data.push_back(expected);
                        actual_data.push_back(actual);

                        if (actual !== expected) begin
                            $error("[SCB][UART] MISMATCH! exp=%02h got=%02h", expected, actual);
                            mismatch_count++;
                        end else begin
                            match_count++;
                            $display("[SCB][UART] MATCH! %02h (count = %0d)", actual, match_count);
                        end

                        state = IDLE;
                        -> gen_next_event;
                    end
                end
            endcase
        end
    endtask

    // 최종 리포트 함수
    function void report();
        $display("\n======== UART Transmission Report ========");
        for (int i = 0; i < expected_data.size(); i++) begin
            if (expected_data[i] === actual_data[i])
                $display("Index %0d : OK    Expected = %02h, Actual = %02h", i, expected_data[i], actual_data[i]);
            else
                $display("Index %0d : FAIL  Expected = %02h, Actual = %02h", i, expected_data[i], actual_data[i]);
        end
        $display("------------------------------------------");
        $display("MATCH count    : %0d", match_count);
        $display("MISMATCH count : %0d", mismatch_count);
        $display("==========================================\n");
    endfunction
endclass

//----------------------------------------------------------------------
// Environment
//----------------------------------------------------------------------
class environment;
    mailbox #(transaction) Gen2Drv_mbox;
    mailbox #(transaction) Mon2SCB_mbox;
    event                  gen_next_event;
    generator              tx_gen;
    driver                 tx_drv;
    monitor                tx_mon;
    scoreboard             tx_scb;

    function new(virtual uart_tx_interface tx_intf);
        Gen2Drv_mbox = new();
        Mon2SCB_mbox = new();
        tx_gen = new(Gen2Drv_mbox, gen_next_event);
        tx_drv = new(Gen2Drv_mbox, tx_intf);
        tx_mon = new(Mon2SCB_mbox, tx_intf);
        tx_scb = new(Mon2SCB_mbox, gen_next_event);
    endfunction

    task run(int count);
        fork
            tx_gen.run(count);
            tx_drv.run();
            tx_mon.run();
            tx_scb.run();
        join_any
    endtask
endclass

//----------------------------------------------------------------------
// Top-level Testbench
//----------------------------------------------------------------------
module tb_uart;
    environment        tx_env;
    uart_tx_interface  tx_intf();

    // logic start_trigger, tx_busy, tx_done, wr_en, full, empty;

    UART_TX_Periph dut(
        .PCLK          (tx_intf.PCLK),
        .PRESET        (tx_intf.PRESET),
        .PADDR         (tx_intf.PADDR),
        .PWDATA        (tx_intf.PWDATA),
        .PWRITE        (tx_intf.PWRITE),
        .PENABLE       (tx_intf.PENABLE),
        .PSEL          (tx_intf.PSEL),
        .PRDATA        (tx_intf.PRDATA),
        .PREADY        (tx_intf.PREADY),
        .tx            (tx_intf.tx)
    );

        // .start_trigger (start_trigger),
        // .tx_busy       (tx_busy),
        // .tx_done       (tx_done),
        // .wr_en         (wr_en),
        // .full          (full),
        // .empty         (empty)
    always #5 tx_intf.PCLK = ~tx_intf.PCLK;

    initial begin
        tx_intf.PSEL    = 0; 
        tx_intf.PWRITE  = 0;
        tx_intf.PENABLE = 0;
        tx_intf.PADDR   = 0;
        tx_intf.PWDATA  = 0;
        tx_intf.PCLK    = 0;
        tx_intf.PRESET  = 1;
        tx_intf.tx      = 1;
        #10 tx_intf.PRESET = 0;

        tx_env = new(tx_intf);
        tx_env.run(20);
        #5_000_000;
        tx_env.tx_scb.report();  // 결과 출력
        $display("finished!!");
        $stop;
    end
endmodule