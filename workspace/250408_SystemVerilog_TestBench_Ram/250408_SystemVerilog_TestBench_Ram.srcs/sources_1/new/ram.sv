`timescale 1ns / 1ps

module ram(
    // interface를 이용한 port 선언
    ram_intf intf
    );
    logic [7:0] mem [0:2**5-1];

    initial begin
        foreach (mem[i]) mem[i] = 0;
    end

    always_ff @( posedge intf.clk ) begin
        if(intf.we) mem[intf.addr] <= intf.wData;
    end

    assign intf.rData = mem[intf.addr];
endmodule