`include "clock_cnt.v"

// 24-hour clock. Timekeeping pauses while clock fields are being edited.
module clock(
    output wire [5:0] o_hour,
    output wire [5:0] o_min,
    output wire [5:0] o_sec,
    input wire [2:0] i_mode,
    input wire [1:0] i_target,
    input wire i_inc_pulse,
    input wire i_dec_pulse,
    input wire i_1hz_tick,
    input wire i_clk,
    input wire i_rstn
);
    localparam [2:0] MODE_CLOCK_SET = 3'b001;
    localparam [1:0] TARGET_SEC = 2'b00;
    localparam [1:0] TARGET_MIN = 2'b01;
    localparam [1:0] TARGET_HOUR = 2'b10;

    wire setting = (i_mode == MODE_CLOCK_SET);
    wire sec_tick = i_1hz_tick && !setting;
    wire min_tick = i_1hz_tick && !setting && (o_sec == 6'd59);
    wire hour_tick = i_1hz_tick && !setting &&
                     (o_sec == 6'd59) && (o_min == 6'd59);

    clock_cnt #(.MAX(59)) u_sec(
        .o_cnt(o_sec), .i_tick(sec_tick),
        .i_inc(setting && (i_target == TARGET_SEC) && i_inc_pulse),
        .i_dec(setting && (i_target == TARGET_SEC) && i_dec_pulse),
        .i_rstn(i_rstn), .i_clk(i_clk)
    );
    clock_cnt #(.MAX(59)) u_min(
        .o_cnt(o_min), .i_tick(min_tick),
        .i_inc(setting && (i_target == TARGET_MIN) && i_inc_pulse),
        .i_dec(setting && (i_target == TARGET_MIN) && i_dec_pulse),
        .i_rstn(i_rstn), .i_clk(i_clk)
    );
    clock_cnt #(.MAX(23)) u_hour(
        .o_cnt(o_hour), .i_tick(hour_tick),
        .i_inc(setting && (i_target == TARGET_HOUR) && i_inc_pulse),
        .i_dec(setting && (i_target == TARGET_HOUR) && i_dec_pulse),
        .i_rstn(i_rstn), .i_clk(i_clk)
    );
endmodule
