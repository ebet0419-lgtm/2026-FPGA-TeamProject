`include "ctrl.v"
`include "clock.v"
`include "alarm.v"
`include "timer_setting.v"
`include "setting_display.v"
`include "timer.v"       // Must implement the interface documented in TIMER_INTERFACE_KO.txt.
`include "buzzer.v"
`include "ssegdisp.v"

// NEW top-level for the user's settings implementation.
// This is NOT the teammate's temporary top.v.
// Display format: HH:MM:SS on six 7-segment digits.
module top(
    output wire       o_buzzer,
    output wire [5:0] o_seg_enb,
    output wire [7:0] o_seg,
    input  wire [7:0] i_sw,
    input  wire       i_clk,
    input  wire       i_rstn
);
    wire [2:0] mode;
    wire [1:0] target;
    wire alarm_en;
    wire inc_pulse, dec_pulse;
    wire timer_start;
    wire blink_en;
    wire tick_1hz;

    wire [5:0] clock_hour, clock_min, clock_sec;
    wire [5:0] alarm_hour, alarm_min, alarm_sec;
    wire [5:0] timer_set_hour, timer_set_min, timer_set_sec;
    wire [5:0] timer_run_hour, timer_run_min, timer_run_sec;
    wire timer_buzzer_enb;

    wire [3:0] disp_num0, disp_num1, disp_num2;
    wire [3:0] disp_num3, disp_num4, disp_num5;
    wire [5:0] blink_mask;

    wire alarm_buzzer_enb;
    wire buzzer_enb;

    ctrl #(
        .CLK_FREQ(50000000),
        .DEBOUNCE_COUNT(250000)
    ) u_ctrl(
        .o_alarm_en(alarm_en),
        .o_mode(mode),
        .o_target(target),
        .o_inc_pulse(inc_pulse),
        .o_dec_pulse(dec_pulse),
        .o_timer_start(timer_start),
        .o_blink_en(blink_en),
        .o_1hz_tick(tick_1hz),
        .i_sw(i_sw),
        .i_clk(i_clk),
        .i_rstn(i_rstn)
    );

    clock u_clock(
        .o_hour(clock_hour),
        .o_min(clock_min),
        .o_sec(clock_sec),
        .i_mode(mode),
        .i_target(target),
        .i_inc_pulse(inc_pulse),
        .i_dec_pulse(dec_pulse),
        .i_1hz_tick(tick_1hz),
        .i_clk(i_clk),
        .i_rstn(i_rstn)
    );

    alarm u_alarm(
        .o_hour(alarm_hour),
        .o_min(alarm_min),
        .o_sec(alarm_sec),
        .i_mode(mode),
        .i_target(target),
        .i_inc_pulse(inc_pulse),
        .i_dec_pulse(dec_pulse),
        .i_clk(i_clk),
        .i_rstn(i_rstn)
    );

    timer_setting u_timer_setting(
        .o_hour(timer_set_hour),
        .o_min(timer_set_min),
        .o_sec(timer_set_sec),
        .i_mode(mode),
        .i_target(target),
        .i_inc_pulse(inc_pulse),
        .i_dec_pulse(dec_pulse),
        .i_clk(i_clk),
        .i_rstn(i_rstn)
    );

    // Countdown engine is owned by the timer teammate.
    // Its required port contract is documented in TIMER_INTERFACE_KO.txt.
    timer u_timer(
        .o_hour(timer_run_hour),
        .o_min(timer_run_min),
        .o_sec(timer_run_sec),
        .o_buzzer_enb(timer_buzzer_enb),
        .i_mode(mode),
        .i_start(timer_start),
        .i_set_hour(timer_set_hour),
        .i_set_min(timer_set_min),
        .i_set_sec(timer_set_sec),
        .i_1hz_tick(tick_1hz),
        .i_clk(i_clk),
        .i_rstn(i_rstn)
    );

    setting_display u_setting_display(
        .o_num0(disp_num0), .o_num1(disp_num1),
        .o_num2(disp_num2), .o_num3(disp_num3),
        .o_num4(disp_num4), .o_num5(disp_num5),
        .o_blink_mask(blink_mask),
        .i_mode(mode),
        .i_target(target),
        .i_clock_hour(clock_hour), .i_clock_min(clock_min), .i_clock_sec(clock_sec),
        .i_alarm_hour(alarm_hour), .i_alarm_min(alarm_min), .i_alarm_sec(alarm_sec),
        .i_timer_hour(timer_set_hour), .i_timer_min(timer_set_min), .i_timer_sec(timer_set_sec),
        .i_timer_run_hour(timer_run_hour), .i_timer_run_min(timer_run_min),
        .i_timer_run_sec(timer_run_sec)
    );

    // Alarm triggers once when HH:MM:SS matches, then re-arms after time changes.
    reg alarm_done;
    reg alarm_active;
    reg [27:0] alarm_duration_count;

    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            alarm_done <= 1'b0;
            alarm_active <= 1'b0;
            alarm_duration_count <= 28'd0;
        end else if ((mode != 3'b000) || !alarm_en) begin
            alarm_done <= 1'b0;
            alarm_active <= 1'b0;
            alarm_duration_count <= 28'd0;
        end else begin
            if ((clock_hour == alarm_hour) &&
                (clock_min == alarm_min) &&
                (clock_sec == alarm_sec) && !alarm_done) begin
                alarm_done <= 1'b1;
                alarm_active <= 1'b1;
                alarm_duration_count <= 28'd0;
            end else if (alarm_active) begin
                if (alarm_duration_count >= 250000000-1) begin
                    alarm_active <= 1'b0;
                    alarm_duration_count <= 28'd0;
                end else begin
                    alarm_duration_count <= alarm_duration_count + 1'b1;
                end
            end

            if ((clock_hour != alarm_hour) ||
                (clock_min != alarm_min) ||
                (clock_sec != alarm_sec))
                alarm_done <= 1'b0;
        end
    end

    assign alarm_buzzer_enb = ~alarm_active;
    assign buzzer_enb = alarm_buzzer_enb & timer_buzzer_enb;

    buzzer u_buzzer(
        .o_out(o_buzzer),
        .i_enb(buzzer_enb),
        .i_clk(i_clk),
        .i_rstn(i_rstn)
    );

    ssegdisp #(
        .FREQDIV(5000),
        .BLINK_DIV(25000000)
    ) u_ssegdisp(
        .o_seg_enb(o_seg_enb),
        .o_seg(o_seg),
        .i_num0(disp_num0), .i_num1(disp_num1),
        .i_num2(disp_num2), .i_num3(disp_num3),
        .i_num4(disp_num4), .i_num5(disp_num5),
        .i_dp0(1'b0), .i_dp1(1'b0), .i_dp2(1'b1),
        .i_dp3(1'b0), .i_dp4(1'b0), .i_dp5(1'b0),
        .i_blink_mask(blink_mask),
        .i_blink_enable(blink_en),
        .i_clk(i_clk),
        .i_rstn(i_rstn)
    );
endmodule
