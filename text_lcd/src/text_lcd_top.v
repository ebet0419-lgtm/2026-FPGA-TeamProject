// ============================================================================
// text_lcd_top.v
//  - 팀원들이 가져다 쓰는 Text LCD 파트의 최상위 모듈
//  - 시계/알람/타이머/설정 모듈의 출력 신호를 그대로 연결하면
//    LCD 핀(lcd_e, lcd_rs, lcd_rw, lcd_data)으로 화면이 나간다.
// ============================================================================
module text_lcd_top #(
    parameter integer CLK_FREQ = 50_000_000
)(
    input  wire       clk,
    input  wire       rst_n,
    // ---- 디지털 시계 상태 ----
    input  wire [1:0] mode,
    input  wire [4:0] cur_h,
    input  wire [5:0] cur_m,
    input  wire [5:0] cur_s,
    input  wire [4:0] alm_h,
    input  wire [5:0] alm_m,
    input  wire       alm_on,
    input  wire [5:0] tmr_m,
    input  wire [5:0] tmr_s,
    input  wire       tmr_run,
    input  wire [1:0] set_pos,
    input  wire       blink,
    input  wire       psd_near,
    // ---- LCD 핀 ----
    output wire       lcd_e,
    output wire       lcd_rs,
    output wire       lcd_rw,
    output wire [7:0] lcd_data
);
    wire [127:0] line1, line2;

    lcd_formatter u_fmt (
        .mode(mode), .cur_h(cur_h), .cur_m(cur_m), .cur_s(cur_s),
        .alm_h(alm_h), .alm_m(alm_m), .alm_on(alm_on),
        .tmr_m(tmr_m), .tmr_s(tmr_s), .tmr_run(tmr_run),
        .set_pos(set_pos), .blink(blink), .psd_near(psd_near),
        .line1(line1), .line2(line2)
    );

    text_lcd_ctrl #(.CLK_FREQ(CLK_FREQ)) u_ctrl (
        .clk(clk), .rst_n(rst_n),
        .line1(line1), .line2(line2),
        .lcd_e(lcd_e), .lcd_rs(lcd_rs), .lcd_rw(lcd_rw), .lcd_data(lcd_data)
    );
endmodule
