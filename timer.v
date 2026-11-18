`include "timer_cnt.v"

module timer
(
    output     [5:0] o_min,
    output     [5:0] o_sec,
    output reg       o_buzzer_enb,

    input      [1:0] i_mode,
    input            i_1hz_clk,
    input            i_clk,
    input            i_rstn
);

    localparam MODE_TIMER = 2'b11;

    reg [1:0] mode_d;
    reg       clk_1hz_d;

    wire      timer_load;
    wire      timer_tick;
    wire      timer_en;

    wire [6:0] remaining_sec;

    reg [27:0] buzzer_cnt;

    // Timer Mode Entry Detection
    assign timer_load =
        (i_mode == MODE_TIMER) && (mode_d != MODE_TIMER);

    // 1Hz Rising Edge Detection
    assign timer_tick = i_1hz_clk & ~clk_1hz_d;

    // Timer Enable
    assign timer_en = (i_mode == MODE_TIMER) && timer_tick;

    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            mode_d     <= 2'b00;
            clk_1hz_d  <= 1'b0;
        end
        else begin
            mode_d    <= i_mode;
            clk_1hz_d <= i_1hz_clk;
        end
    end

    // Countdown Counter
    timer_cnt
    u_timer_cnt
    (
        .o_cnt  (remaining_sec),
        .i_load (timer_load),
        .i_en   (timer_en),
        .i_clk  (i_clk),
        .i_rstn (i_rstn)
    );

    // Convert Remaining Seconds to MM:SS
    assign o_min = remaining_sec / 60;
    assign o_sec = remaining_sec % 60;

    // Timer Buzzer Control
    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            o_buzzer_enb <= 1'b1;
            buzzer_cnt   <= 0;
        end
        else begin
            // Entering Timer Mode
            if (timer_load) begin
                o_buzzer_enb <= 1'b1;
                buzzer_cnt   <= 0;
            end

            // Countdown Reaches Zero
            else if (timer_tick &&
                     (i_mode == MODE_TIMER) &&
                     (remaining_sec == 1)) begin

                o_buzzer_enb <= 1'b0;
                buzzer_cnt   <= 0;
            end

            // Buzzer Active for 5 Seconds
            else if (!o_buzzer_enb) begin
                if (buzzer_cnt == 250000000 - 1) begin
                    o_buzzer_enb <= 1'b1;
                    buzzer_cnt   <= 0;
                end
                else begin
                    buzzer_cnt <= buzzer_cnt + 1'b1;
                end
            end
        end
    end

endmodule