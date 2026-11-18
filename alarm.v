`include "alarm_cnt.v"

module alarm
(
    output [5:0] o_min,
    output [5:0] o_sec,
    input        i_min_clk,
    input        i_sec_clk,
    input        i_rstn
);

    alarm_cnt
    #(
        .MAX        (59       )
    )
    u_alarm_cnt_sec(
        .o_cnt      (o_sec    ),
        .i_clk      (i_sec_clk),
        .i_rstn     (i_rstn   )
    );

    alarm_cnt
    #(
        .MAX        (59       )
    )
    u_alarm_cnt_min(
        .o_cnt      (o_min    ),
        .i_clk      (i_min_clk),
        .i_rstn     (i_rstn   )
    );

endmodule