// ============================================================================
// tb_text_lcd.v
//  - 가상의 LCD 모델을 붙여서, LCD에 실제로 써진 글자를 터미널에 그려 준다.
//  - 시뮬레이션 속도를 위해 CLK_FREQ = 1MHz 로 낮춰서 사용 (1클럭 = 1us)
//
//  실행:
//   iverilog -o sim tb/tb_text_lcd.v src/text_lcd_top.v src/lcd_formatter.v src/text_lcd_ctrl.v
//   vvp sim
//   gtkwave tb_text_lcd.vcd
// ============================================================================
`timescale 1ns/1ns
module tb_text_lcd;
    reg clk = 0;
    always #500 clk = ~clk;        // 1MHz

    reg        rst_n = 0;
    reg  [1:0] mode = 0;
    reg  [4:0] cur_h = 12;  reg [5:0] cur_m = 34, cur_s = 56;
    reg  [4:0] alm_h = 7;   reg [5:0] alm_m = 30; reg alm_on = 1;
    reg  [5:0] tmr_m = 3,   tmr_s = 0;            reg tmr_run = 0;
    reg  [1:0] set_pos = 0; reg blink = 1;        reg psd_near = 0;

    wire lcd_e, lcd_rs, lcd_rw;
    wire [7:0] lcd_data;

    text_lcd_top #(.CLK_FREQ(1_000_000)) dut (
        .clk(clk), .rst_n(rst_n),
        .mode(mode), .cur_h(cur_h), .cur_m(cur_m), .cur_s(cur_s),
        .alm_h(alm_h), .alm_m(alm_m), .alm_on(alm_on),
        .tmr_m(tmr_m), .tmr_s(tmr_s), .tmr_run(tmr_run),
        .set_pos(set_pos), .blink(blink), .psd_near(psd_near),
        .lcd_e(lcd_e), .lcd_rs(lcd_rs), .lcd_rw(lcd_rw), .lcd_data(lcd_data)
    );

    // ---------------- 가상 LCD (HD44780 동작 흉내) ----------------
    reg [7:0] ddram [0:127];
    reg [6:0] addr = 0;
    integer i;
    initial for (i = 0; i < 128; i = i + 1) ddram[i] = 8'h20;

    always @(negedge lcd_e) begin            // E 하강 에지에서 값을 받아들임
        if (!lcd_rs) begin
            if (lcd_data[7]) addr = lcd_data[6:0];            // Set DDRAM address
            else if (lcd_data == 8'h01) begin                 // Clear
                for (i = 0; i < 128; i = i + 1) ddram[i] = 8'h20;
                addr = 0;
            end
        end else begin
            ddram[addr] = lcd_data;                           // 글자 쓰기
            addr = addr + 1;
        end
    end

    task show(input [8*24-1:0] title);
        reg [127:0] l1, l2;
        integer k;
        begin
            for (k = 0; k < 16; k = k + 1) begin
                l1[127 - 8*k -: 8] = ddram[k];
                l2[127 - 8*k -: 8] = ddram[64 + k];
            end
            $display("\n[%0t ms] %0s", $time / 1_000_000, title);
            $display("+----------------+");
            $display("|%s|", l1);
            $display("|%s|", l2);
            $display("+----------------+");
        end
    endtask

    localparam WAIT = 30_000_000;   // 30ms (화면 한 바퀴 갱신 = 약 6.8ms)

    initial begin
        $dumpfile("tb_text_lcd.vcd");
        $dumpvars(0, tb_text_lcd);

        #2000 rst_n = 1;
        #100_000_000;                                 // 초기화(약 70ms) 대기
        show("1) NORMAL");

        mode = 1; set_pos = 2; blink = 1;  #WAIT;  show("2) CLK SET, blink=1");
        blink = 0;                         #WAIT;  show("3) CLK SET, blink=0 (min)");

        mode = 2; set_pos = 1; blink = 0;  #WAIT;  show("4) ALM SET, blink=0 (hour)");
        alm_on = 0; blink = 1;             #WAIT;  show("5) ALM SET, alarm OFF");

        mode = 3; set_pos = 0; tmr_m = 2; tmr_s = 59; tmr_run = 1;
                                           #WAIT;  show("6) TIMER 02:59 RUN");
        tmr_m = 0; tmr_s = 0; tmr_run = 0; psd_near = 1;
                                           #WAIT;  show("7) TIMER 00:00, PSD near");

        $finish;
    end
endmodule
