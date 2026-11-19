// ============================================================================
// lcd_formatter.v
//  - 디지털 시계의 상태(모드, 현재 시각, 알람, 타이머, PSD)를 받아서
//    LCD 두 줄(각 16글자)의 ASCII 문자열로 만들어 주는 조합회로
//
//  화면 구성 (16칸)
//   mode 0 (일반)     : "NORMAL  12:34:56" / "ALARM 07:30 ON  "
//   mode 1 (시계설정) : "CLK SET 12:34:56" / "ALARM 07:30 ON  "
//   mode 2 (알람설정) : "ALM SET 07:30   " / "ALARM 07:30 ON  "
//   mode 3 (타이머)   : "TIMER      02:59" / "STATUS: RUN     "
//   2번째 줄 마지막 칸 : PSD 근접 시 '*'
//
//  Blink: set_pos 로 지정한 칸이 blink=0 일 때 공백으로 바뀜 (mode 1~3에서만)
//   set_pos = 0: 없음, 1: 시(hour), 2: 분(min), 3: 초(sec)
//   타이머 모드에서는 2: 분, 3: 초
// ============================================================================
module lcd_formatter (
    input  wire [1:0]   mode,       // 0 일반, 1 시계설정, 2 알람설정, 3 타이머
    input  wire [4:0]   cur_h,      // 현재 시 (0~23, 2진수)
    input  wire [5:0]   cur_m,      // 현재 분 (0~59)
    input  wire [5:0]   cur_s,      // 현재 초 (0~59)
    input  wire [4:0]   alm_h,      // 알람 시
    input  wire [5:0]   alm_m,      // 알람 분
    input  wire         alm_on,     // 알람 On/Off
    input  wire [5:0]   tmr_m,      // 타이머 남은 분
    input  wire [5:0]   tmr_s,      // 타이머 남은 초
    input  wire         tmr_run,    // 타이머 동작 중
    input  wire [1:0]   set_pos,    // 깜빡일 위치
    input  wire         blink,      // 1Hz 깜빡임 신호 (1: 보임, 0: 숨김)
    input  wire         psd_near,   // PSD 센서 근접 감지
    output reg  [127:0] line1,
    output reg  [127:0] line2
);
    // 0~99 숫자를 ASCII 두 글자로 변환 ("07" 등)
    function [15:0] d2;
        input [6:0] v;
        begin
            d2 = {8'h30 + (v / 10), 8'h30 + (v % 10)};
        end
    endfunction

    // 설정 모드에서 해당 칸 숨기기
    wire blink_off = (mode != 2'd0) && !blink;
    wire hide_h = blink_off && (set_pos == 2'd1);
    wire hide_m = blink_off && (set_pos == 2'd2);
    wire hide_s = blink_off && (set_pos == 2'd3);

    wire [15:0] H  = hide_h ? "  " : d2({2'b00, cur_h});
    wire [15:0] M  = hide_m ? "  " : d2({1'b0,  cur_m});
    wire [15:0] S  = hide_s ? "  " : d2({1'b0,  cur_s});
    wire [15:0] AH = hide_h ? "  " : d2({2'b00, alm_h});
    wire [15:0] AM = hide_m ? "  " : d2({1'b0,  alm_m});
    wire [15:0] TM = hide_m ? "  " : d2({1'b0,  tmr_m});
    wire [15:0] TS = hide_s ? "  " : d2({1'b0,  tmr_s});

    // 2번째 줄용 (깜빡이지 않는 알람 시각)
    wire [15:0] AH2 = d2({2'b00, alm_h});
    wire [15:0] AM2 = d2({1'b0,  alm_m});

    wire [7:0]  psd_ch = psd_near ? "*" : " ";

    always @(*) begin
        case (mode)
            2'd0:    line1 = {"NORMAL  ", H, ":", M, ":", S};      // 8+8 = 16
            2'd1:    line1 = {"CLK SET ", H, ":", M, ":", S};
            2'd2:    line1 = {"ALM SET ", AH, ":", AM, "   "};     // 8+5+3
            default: line1 = {"TIMER   ", "   ", TM, ":", TS};     // 8+3+5
        endcase

        if (mode == 2'd3)
            line2 = {"STATUS: ", (tmr_run ? "RUN " : "STOP"), "   ", psd_ch};      // 8+4+3+1
        else
            line2 = {"ALARM ", AH2, ":", AM2, " ", (alm_on ? "ON " : "OFF"), psd_ch}; // 6+5+1+3+1
    end
endmodule
