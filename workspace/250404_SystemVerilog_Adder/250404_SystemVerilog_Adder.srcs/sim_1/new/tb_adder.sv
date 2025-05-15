`timescale 1ns / 1ps

interface adder_intf;
    // logic type은 wire, reg type 둘 다 가능
    // in, out도 정하지 않아도 된다.
    logic [7:0] a;
    logic [7:0] b;
    logic [7:0] sum;
    logic carry;
endinterface //adder_intf

// OOP
// object를 수정해서 다른 객체에 전달(상호작용한다!) 
// sw에서의 객체: 실존하는 물체가 아닌 만들어낸 객체(각각의 전문가라고 생각)
// 객체를 실체화: instance

// driver
// value를 수정해서 전달해준다

// class
// 변수와 함수를 모두 넣을 수 있다.

// object
class transaction;
    // bit는 2state로 zz, x가 없고 0, 1만 존재하는 data type
    // 앞에 rand를 붙이면 randomization 가능
    // new가 없기 때문에 heap 영역에 transaction이라는 공간을 만들어서
    // instance하고 stack 영역에 tr 이라는 handler를 만들고 reference 넣는다.

    // *100개를 만들어도 mailbox에서 get 된 것은 garbage data라고 판단하여 
    // heap 메모리에서 삭제*

    // randomize 후 이를 mailbox에 put
    // handler값(reference)가 mailbox에 put되고 driver에 get 되면서
    // driver의 tr(handler)에 reference를 넣는다.
    // driver에서 interface에 연결
    rand bit [7:0] a;
    rand bit [7:0] b;
endclass //transaction

// value generate
class generator;
    // tr이라는 변수 transaction class를 instance하여 실체화
    transaction tr;

    // generator to driver mailbox(class 이름)
    // transaction의 data type 형태의 mailbox
    mailbox #(transaction) gen2drv_mbox;
    
    // function은 return 값이 존재
    function new(mailbox#(transaction) gen2drv_mbox);
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction // new()

    // 멤버 함수(method)
    // task는 return 값이 존재X
    task run (int run_count);
        repeat (run_count) begin
            tr = new();
            tr.randomize();
            gen2drv_mbox.put(tr);
            #10;
        end
    endtask //run
endclass //generator

class driver;
    transaction tr;
    // interface와의 instance화
    // adder_if는 해당 class의 멤버변수
    virtual adder_intf adder_if;
    mailbox #(transaction) gen2drv_mbox;

    // adder_if는 매개 변수
    function new(mailbox#(transaction) gen2drv_mbox, virtual adder_intf adder_if);
        this.gen2drv_mbox = gen2drv_mbox;

        // 매개 변수를 멤버 변수에 넣는다.
        this.adder_if = adder_if;
    endfunction //new()

    task reset();
        adder_if.a = 0;
        adder_if.b = 0;
    endtask //reset

    task run();
        forever begin
            gen2drv_mbox.get(tr);
            // interface가 실제 hw로 연결되어 있어서 이를 연결
            adder_if.a = tr.a;
            adder_if.b = tr.b;
            #10;
        end
    endtask //run
endclass //driver

class environment;
    generator gen;
    driver drv;
    mailbox #(transaction) gen2drv_mbox;

    // new(생성자)
    // interface에 대한 정보를 받을 수 있도록 선언
    // virtual(가상) 
    // <-> tb의 adder_intf adder_if(); 가 실제
    // interface에서는 hw를 계속 만들 수 없다. -> virtul로 선언하여 사용
    function new(virtual adder_intf adder_if);
        gen2drv_mbox = new();
        gen = new(gen2drv_mbox);
        drv = new(gen2drv_mbox, adder_if);
    endfunction //new()

    task run();
        
        // fork ~ join 사이에 있는 값은 thread 동작
        // gen.run이 먼저 실행 후 drv.run이 실행되는 것이 아니라 동시에 실행(독립 시행)
        // join: thread가 모두 끝나면 다음 실행
        // join_any: thread 중 1개라도 끝나면 다음 실행
        // join_none: thread가 실행하고 바로 다음 라인 코드 실행
        fork
            gen.run(10);
            drv.run();
        join_any
        #10 $finish;
    endtask //run
endclass //environment

//testbench
module tb_adder();
    // class명 변수명 
    // handler 선언
    // 실체화는 되지 않고 address를 담을 수 있는 변수(env)
    environment env;

    // virtual이 아닌 실제 Hardware
    // interface의 instance
    adder_intf adder_if(); 

    adder dut(
        // 케이블 묶음에서 하나씩 연결
        .a(adder_if.a),
        .b(adder_if.b),
        .sum(adder_if.sum),
        .carry(adder_if.carry)
    );

    initial begin
        
        // new() env(handler), new(instance) new는 heap 영역에 생성
        // environment가 가지는 pointer(address){reference}를 env(handler)에 대입
        // instance(실체화)가 되었다는 것은 heap 메모리 공간에 loading 되는 것 
        env = new(adder_if);
        
        // heap memory에 저장된 enviorment 내부의 run이 동작
        env.run();
    end
endmodule