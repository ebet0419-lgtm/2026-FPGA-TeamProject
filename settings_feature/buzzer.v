`include "buzzer_nco.v"
`include "buzzer_upcnt.v"
`include "buzzer_sheet.v"

module buzzer
(
    output       o_out,
    input        i_enb,
    input        i_clk,
    input        i_rstn
);

    localparam   FREQDIV = 50000000/8;
    localparam   UPBND   = 63;

    wire         beat_clk;
    wire [$clog2(UPBND)-1:0] cnt;
    wire         buzz;
    wire [31:0]  note;

    buzzer_nco
    u_buzzer_nco_beat(
        .o_clk      (beat_clk ),
        .i_freq_div (FREQDIV  ),
        .i_clk      (i_clk    ),
        .i_rstn     (i_rstn   )
    );

    buzzer_upcnt
    #(
        .UPBND      (UPBND    )
    )
    u_buzzer_upcnt(
        .o_cnt      (cnt      ),
        .i_clk      (beat_clk ),
        .i_rstn     (i_rstn   )
    );

    buzzer_sheet
    u_buzzer_sheet(
        .o_note     (note     ),
        .i_cnt      (cnt      )
    );

    buzzer_nco
    u_buzzer_buzz(
        .o_clk      (buzz     ),
        .i_freq_div (note     ),
        .i_clk      (i_clk    ),
        .i_rstn     (i_rstn   )
    );

    assign o_out = ~i_enb & buzz;

endmodule