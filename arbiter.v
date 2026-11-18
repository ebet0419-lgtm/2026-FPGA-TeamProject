`include "arbiter_split.v"

module arbiter
(
    output            o_buzzer_enb,

    output     [3:0]  o_num0,
    output     [3:0]  o_num1,
    output     [3:0]  o_num2,
    output     [3:0]  o_num3,
    output     [3:0]  o_num4,
    output     [3:0]  o_num5,

    input      [1:0]  i_mode,
    input             i_alarm_en,

    input      [5:0]  i_clock_sec,
    input      [5:0]  i_clock_min,

    input      [5:0]  i_alarm_sec,
    input      [5:0]  i_alarm_min,

    input      [5:0]  i_timer_sec,
    input      [5:0]  i_timer_min,

    input             i_timer_buzzer_enb,

    input      [5:0]  i_undef_sec,
    input      [5:0]  i_undef_min,

    input             i_clk,
    input             i_rstn
);

    localparam MODE_CLOCK_OPR = 2'b00;
    localparam MODE_CLOCK_SET = 2'b01;
    localparam MODE_ALARM_SET = 2'b10;
    localparam MODE_TIMER     = 2'b11;

    // Display MUX
    reg [5:0] sec;
    reg [5:0] min;

    always @(*) begin
        case (i_mode)

            MODE_CLOCK_OPR,
            MODE_CLOCK_SET: begin
                sec = i_clock_sec;
                min = i_clock_min;
            end

            MODE_ALARM_SET: begin
                sec = i_alarm_sec;
                min = i_alarm_min;
            end

            MODE_TIMER: begin
                sec = i_timer_sec;
                min = i_timer_min;
            end

            default: begin
                sec = i_undef_sec;
                min = i_undef_min;
            end

        endcase
    end

    // Alarm Buzzer Control
    reg        alarm_buzzer_enb;
    reg [27:0] alarm_cnt;
    reg        alarm_done;

    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            alarm_buzzer_enb <= 1'b1;
            alarm_cnt        <= 0;
            alarm_done       <= 0;
        end
        else begin

            if (i_mode != MODE_CLOCK_OPR || !i_alarm_en) begin
                alarm_buzzer_enb <= 1'b1;
                alarm_cnt        <= 0;
                alarm_done       <= 0;
            end

            else begin

                if ((i_clock_sec == i_alarm_sec) &&
                    (i_clock_min == i_alarm_min) &&
                    !alarm_done) begin

                    alarm_buzzer_enb <= 1'b0;
                    alarm_cnt        <= 0;
                    alarm_done       <= 1'b1;
                end

                else if (!alarm_buzzer_enb) begin

                    if (alarm_cnt == 250000000 - 1) begin
                        alarm_buzzer_enb <= 1'b1;
                        alarm_cnt        <= 0;
                    end
                    else begin
                        alarm_cnt <= alarm_cnt + 1'b1;
                    end

                end

                else begin
                    alarm_buzzer_enb <= 1'b1;
                    alarm_cnt        <= 0;

                    if ((i_clock_sec != i_alarm_sec) ||
                        (i_clock_min != i_alarm_min)) begin

                        alarm_done <= 0;
                    end
                end

            end
        end
    end

    // Combine Alarm and Timer Buzzer Signals
    assign o_buzzer_enb = alarm_buzzer_enb & i_timer_buzzer_enb;

    // Number Split: Seconds
    arbiter_split
    #(
        .MAX (59)
    )
    u_arbiter_split_sec
    (
        .o_num_l (o_num1),
        .o_num_r (o_num0),
        .i_num   (sec)
    );

    // Number Split: Minutes
    arbiter_split
    #(
        .MAX (59)
    )
    u_arbiter_split_min
    (
        .o_num_l (o_num3),
        .o_num_r (o_num2),
        .i_num   (min)
    );

    // Unused Upper Two Digits
    assign o_num4 = 4'd15;
    assign o_num5 = 4'd15;

endmodule