`include "ssegdisp_dec.v"
`include "ssegdisp_enabler.v"
`include "ssegdisp_mux6.v"
`include "ssegdisp_nco.v"
`include "ssegdisp_upcnt.v"

// Six-digit multiplexed display with selected-pair blinking.
module ssegdisp #(
    parameter integer FREQDIV = 5000,
    parameter integer BLINK_DIV = 25000000
)(
    output wire [5:0] o_seg_enb,
    output wire [7:0] o_seg,
    input wire [3:0] i_num0, i_num1, i_num2, i_num3, i_num4, i_num5,
    input wire i_dp0, i_dp1, i_dp2, i_dp3, i_dp4, i_dp5,
    input wire [5:0] i_blink_mask,
    input wire i_blink_enable,
    input wire i_clk,
    input wire i_rstn
);
    wire scan_clk;
    wire [2:0] scan_cnt;
    wire [7:0] seg [0:5];
    wire [7:0] mux_seg;
    reg [31:0] blink_count;
    reg blink_phase;

    ssegdisp_nco #(.FREQDIV(FREQDIV)) u_nco(
        .o_clk(scan_clk), .i_clk(i_clk), .i_rstn(i_rstn)
    );
    ssegdisp_upcnt #(.UPBND(5)) u_scan(
        .o_cnt(scan_cnt), .i_clk(scan_clk), .i_rstn(i_rstn)
    );
    ssegdisp_enabler u_enabler(
        .o_seg_enb(o_seg_enb), .i_cnt(scan_cnt)
    );

    ssegdisp_dec u_dec0(.o_seg(seg[0]), .i_num(i_num0), .i_dp(i_dp0));
    ssegdisp_dec u_dec1(.o_seg(seg[1]), .i_num(i_num1), .i_dp(i_dp1));
    ssegdisp_dec u_dec2(.o_seg(seg[2]), .i_num(i_num2), .i_dp(i_dp2));
    ssegdisp_dec u_dec3(.o_seg(seg[3]), .i_num(i_num3), .i_dp(i_dp3));
    ssegdisp_dec u_dec4(.o_seg(seg[4]), .i_num(i_num4), .i_dp(i_dp4));
    ssegdisp_dec u_dec5(.o_seg(seg[5]), .i_num(i_num5), .i_dp(i_dp5));

    ssegdisp_mux6 u_mux(
        .o_out(mux_seg),
        .i_in0(seg[0]), .i_in1(seg[1]), .i_in2(seg[2]),
        .i_in3(seg[3]), .i_in4(seg[4]), .i_in5(seg[5]),
        .i_sel(scan_cnt)
    );

    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            blink_count <= 32'd0;
            blink_phase <= 1'b0;
        end else if (blink_count >= BLINK_DIV-1) begin
            blink_count <= 32'd0;
            blink_phase <= ~blink_phase;
        end else begin
            blink_count <= blink_count + 1'b1;
        end
    end

    // Decoder segment data is active-high. Zero turns all segments off.
    assign o_seg = (i_blink_enable && blink_phase && i_blink_mask[scan_cnt])
                 ? 8'b00000000 : mux_seg;
endmodule
