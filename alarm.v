`include "clock_cnt.v"

`ifndef ALARM_CNT_V
`define ALARM_CNT_V

module alarm_cnt #(
    parameter integer MAX = 59
)(
    output wire [5:0] o_cnt,
    input  wire       i_inc,
    input  wire       i_dec,
    input  wire       i_clk,
    input  wire       i_rstn
);
    clock_cnt #(.MAX(MAX)) u_bridge (
        .o_cnt(o_cnt),
        .i_tick(1'b0),
        .i_inc(i_inc),
        .i_dec(i_dec),
        .i_rstn(i_rstn),
        .i_clk(i_clk)
    );
endmodule

`endif

module alarm(
    output wire [5:0] o_hour,
    output wire [5:0] o_min,
    output wire [5:0] o_sec,
    input  wire [2:0] i_mode,
    input  wire [1:0] i_target,
    input  wire       i_inc_pulse,
    input  wire       i_dec_pulse,
    input  wire       i_clk,
    input  wire       i_rstn
);
    localparam [2:0] MODE_ALARM_SET = 3'b010;
    localparam [1:0] TARGET_SEC     = 2'b00;
    localparam [1:0] TARGET_MIN     = 2'b01;
    localparam [1:0] TARGET_HOUR    = 2'b10;

    wire active = (i_mode == MODE_ALARM_SET);

    clock_cnt #(.MAX(59)) u_sec(
        .o_cnt(o_sec),
        .i_tick(1'b0),
        .i_inc(active && (i_target == TARGET_SEC) && i_inc_pulse),
        .i_dec(active && (i_target == TARGET_SEC) && i_dec_pulse),
        .i_rstn(i_rstn),
        .i_clk(i_clk)
    );
    clock_cnt #(.MAX(59)) u_min(
        .o_cnt(o_min),
        .i_tick(1'b0),
        .i_inc(active && (i_target == TARGET_MIN) && i_inc_pulse),
        .i_dec(active && (i_target == TARGET_MIN) && i_dec_pulse),
        .i_rstn(i_rstn),
        .i_clk(i_clk)
    );
    clock_cnt #(.MAX(23)) u_hour(
        .o_cnt(o_hour),
        .i_tick(1'b0),
        .i_inc(active && (i_target == TARGET_HOUR) && i_inc_pulse),
        .i_dec(active && (i_target == TARGET_HOUR) && i_dec_pulse),
        .i_rstn(i_rstn),
        .i_clk(i_clk)
    );
endmodule
