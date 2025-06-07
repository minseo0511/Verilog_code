`timescale 1ns / 1ps

module Motion_Detector (
    input  logic        clk,
    input  logic        reset,
    input  logic        DE,
    input  logic [7:0]  threshold,
    input  logic [11:0] curr_pixel,
    input  logic [11:0] prev_pixel,  
    output logic        motion_detected,
    output logic [11:0] motion_pixel_out,
    input  logic        v_sync
);

    localparam int MOTION_LIMIT = 640 * 480 * 3 / 100; // 153600
    localparam int TIMER_MAX    = 75_000_000;           // 3초 @ 25MHz

    logic [11:0] diff;
    logic [17:0] motion_pixel_count;
    logic [26:0] motion_timer;  // Enough for 75 million

    assign diff = (curr_pixel > prev_pixel) ? (curr_pixel - prev_pixel) : (prev_pixel - curr_pixel);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            motion_pixel_count <= 0;
            motion_detected    <= 0;
            motion_timer       <= 0;
        end else begin
            if (DE) begin
                if (diff > threshold) begin
                    motion_pixel_out <= 12'hF00;
                    motion_pixel_count <= motion_pixel_count + 1;

                    if (!motion_detected && motion_pixel_count + 1 >= MOTION_LIMIT) begin
                        motion_detected <= 1;
                        motion_timer    <= 0; // 타이머 리셋
                    end
                end else begin
                    motion_pixel_out <= curr_pixel;
                end
            end else begin
                motion_pixel_out <= curr_pixel;
            end

            // motion_detected 유지 타이머
            if (motion_detected) begin
                if (motion_timer < TIMER_MAX)
                    motion_timer <= motion_timer + 1;
                else
                    motion_detected <= 0;  // 3초 지나면 reset
            end

            // 프레임 경계에서 motion 카운트 초기화
            if (v_sync == 0)
                motion_pixel_count <= 0;
        end
    end

endmodule


// module Motion_Detector (
//     input  logic        clk,
//     input  logic        reset,               // 추가: 리셋 신호
//     input  logic        DE,
//     input logic [7:0] threshold,
//     input  logic [11:0] curr_pixel,
//     input  logic [11:0] prev_pixel,  
//     output logic        motion_detected,
//     output logic [11:0] motion_pixel_out,
//     output logic        v_sync
// );

//     // localparam THRESHOLD = 32;
//     localparam MOTION_LIMIT = 640 * 480 * 50 / 100; // QQVGA 해상도의 절반 = 38400 픽셀

//     logic [11:0] diff;
//     logic [17:0] motion_pixel_count;

//     assign diff = (curr_pixel > prev_pixel) ? (curr_pixel - prev_pixel) : (prev_pixel - curr_pixel);

//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) begin
//             motion_pixel_count <= 0;
//             motion_detected <= 0;
//         end else begin
//             if (DE) begin
//                 if (diff > threshold) begin
//                     motion_pixel_out <= 12'hF00;  // 빨간색 출력
//                     motion_pixel_count <= motion_pixel_count + 1;

//                     if (motion_pixel_count + 1 >= MOTION_LIMIT)
//                         motion_detected <= 1;
//                 end else begin
//                     motion_pixel_out <= curr_pixel;
//                 end
//             end 
//             else if(v_sync == 0) begin
//                 motion_pixel_count <= 0;
//             end 
//             else begin
//                 motion_pixel_out <= curr_pixel;
//             end
//         end
//     end

// endmodule
