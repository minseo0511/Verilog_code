module ControlUnit (
    input logic clk,
    input logic reset,
    output logic ASrcMuxSel,
    output logic AEn,
    input logic Alt10,
    output logic OutBuf,
    output logic SumEn
);
    
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;

    reg [2:0] state, state_next;

    always @(posedge clk, posedge reset) begin
        if(reset) state <= S0;
        else state <= state_next;
    end

    always_comb begin 
        state_next = state;
        ASrcMuxSel = 0;
        AEn = 0;
        OutBuf = 0;
        SumEn = 0;
        case (state)
            S0: begin
                AEn = 1;
                state_next = S1;
            end  
            S1: begin
                if(Alt10) state_next = S2;    
                else state_next = S4;   
            end  
            S2: begin
                SumEn = 1; 
                state_next = S3;
            end  
            S3: begin
                ASrcMuxSel = 1;
                AEn = 1;
                state_next = S1;
            end  
            S4: begin
                OutBuf = 1;
                state_next = S4;
            end 
        endcase
    end
endmodule
