module send_tx_btn(
    input clk,
    input rst,
    input btn_start,          // 버튼 입력
    output tx
);

    wire w_start;
    wire w_tx_done;

    parameter BIT = 16;
    parameter IDLE = 0, START = 1, SEND = 2;

    reg [7:0] send_tx_data_reg, send_tx_data_next;
    reg send_reg, send_next; //start trigger 출력
    reg [1:0] state, next; //FSM state
    reg [3:0] send_count_reg, send_count_next;

    // debounce 처리한 버튼 입력
    btn_debounce U_Start_btn(
        .clk(clk),
        .reset(rst),
        .i_btn(btn_start),
        .o_btn(w_start)
    );

    // uart 모듈 인스턴스
    uart_rx_16bit U_uart_rx_16bit(
        .clk(clk),
        .rst(rst),
        .btn_start(send_reg),          // 전송 트리거
        .tx_data_in(send_tx_data_reg),  // 전송할 데이터
        .tx(tx),                         // 직렬 송신
        .tx_done(w_tx_done)             // 송신 완료
    );
    
    // 상태 레지스터 동기화
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            send_tx_data_reg <= 8'h30; // '0'
            state <= IDLE;
            send_reg <= 0;
            send_count_reg <= 0;
        end else begin
            send_tx_data_reg <= send_tx_data_next;
            state <= next;
            send_reg <= send_next;
            send_count_reg <= send_count_next;
        end
    end

    // FSM & 조합 논리
    always @(*) begin
        // 기본 유지값
        send_tx_data_next = send_tx_data_reg;
        next = state;
        send_next = 0; // 1tick
        send_count_next = send_count_reg;
        case (state)
            IDLE: begin
                send_next = 0;
                send_count_next = 0;
                if (w_start) begin
                    next = START;
                    send_next = 1;
                end
            end

            START: begin
                send_next = 0;
                if (w_tx_done) begin
                    next = SEND;
                end
            end

            SEND: begin
                if (w_tx_done == 0) begin
                    send_count_next = send_count_reg + 1;
                    if (send_count_reg == 15) begin
                        next = IDLE;   
                    end
                    else if (send_tx_data_reg == "z") begin
                        send_tx_data_next = "0";
                    end
                    else begin
                        send_next = 1; //send 1tick
                        send_tx_data_next = send_tx_data_reg + 1;
                        next = START;
                    end
                end
            end
        endcase
    end
endmodule
