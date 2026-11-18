// ===================================================
// [ VLSISYS Lab. ]
// * Author     : Woong Choi (woongchoi@sm.ac.kr)
// * Filename   : ssegdisp.v
// * Description :
// ===================================================

`include "ssegdisp_dec.v"
`include "ssegdisp_enabler.v"
`include "ssegdisp_mux6.v"
`include "ssegdisp_nco.v"
`include "ssegdisp_upcnt.v"

module ssegdisp
#(
    parameter FREQDIV = 10
)
(
    output   [5:0] o_seg_enb,
    output   [7:0] o_seg,
    input    [3:0] i_num0,
    input    [3:0] i_num1,
    input    [3:0] i_num2,
    input    [3:0] i_num3,
    input    [3:0] i_num4,
    input    [3:0] i_num5,
    input          i_dp0,
    input          i_dp1,
    input          i_dp2,
    input          i_dp3,
    input          i_dp4,
    input          i_dp5,
    input          i_clk,
    input          i_rstn
);

    wire           divclk;
    wire     [2:0] cnt;
    wire     [7:0] seg[0:5];

    ssegdisp_nco
    #(
        .FREQDIV       (FREQDIV        )
    )
    u_ssegdisp_nco(
        .o_clk         (divclk         ),
        .i_clk         (i_clk          ),
        .i_rstn        (i_rstn         )
    );

    ssegdisp_upcnt
    #(
        .UPBND         (5              )
    )
    u_ssegdisp_upcnt(
        .o_cnt         (cnt            ),
        .i_clk         (divclk         ),
        .i_rstn        (i_rstn         )
    );

    ssegdisp_enabler
    u_ssegdisp_enabler(
        .o_seg_enb     (o_seg_enb      ),
        .i_cnt         (cnt            )
    );

    ssegdisp_dec
    u_ssegdisp_dec0(
        .o_seg         (seg[0]         ),
        .i_num         (i_num0         ),
        .i_dp          (i_dp0          )
    );

    ssegdisp_dec
    u_ssegdisp_dtrl_dec1(
        .o_seg         (seg[1]         ),
        .i_num         (i_num1         ),
        .i_dp          (i_dp1          )
    );

    ssegdisp_dec
    u_ssegdisp_dec2(
        .o_seg         (seg[2]         ),
        .i_num         (i_num2         ),
        .i_dp          (i_dp2          )
    );

    ssegdisp_dec
    u_ssegdisp_dec3(
        .o_seg         (seg[3]         ),
        .i_num         (i_num3         ),
        .i_dp          (i_dp3          )
    );

    ssegdisp_dec
    u_ssegdisp_dec4(
        .o_seg         (seg[4]         ),
        .i_num         (i_num4         ),
        .i_dp          (i_dp4          )
    );

    ssegdisp_dec
    u_ssegdisp_dec5(
        .o_seg         (seg[5]         ),
        .i_num         (i_num5         ),
        .i_dp          (i_dp5          )
    );

    ssegdisp_mux6
    u_ssegdisp_mux6(
        .o_out         (o_seg          ),
        .i_in0         (seg[0]         ),
        .i_in1         (seg[1]         ),
        .i_in2         (seg[2]         ),
        .i_in3         (seg[3]         ),
        .i_in4         (seg[4]         ),
        .i_in5         (seg[5]         ),
        .i_sel         (cnt            )
    );

endmodule