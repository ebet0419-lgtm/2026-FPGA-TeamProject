# Text LCD 파트 (디지털 시계 팀 프로젝트)

디지털 시계의 **모드(일반/시계설정/알람설정/타이머)**와 **알람 정보(알람 시각, On/Off)**를 16x2 Text LCD에 표시하는 모듈입니다.

## 파일 구성

```
text_lcd/
├── src/
│   ├── text_lcd_top.v     ← 팀원들은 이것만 가져다 쓰면 됨
│   ├── lcd_formatter.v    ← 시계 상태 → LCD 문자열(ASCII) 변환
│   ├── text_lcd_ctrl.v    ← LCD 드라이버 (초기화 + 글자 쓰기)
│   └── blink_gen.v        ← 설정 모드 깜빡임용 1Hz 신호
├── tb/
│   └── tb_text_lcd.v      ← 가상 LCD로 화면 내용 확인하는 테스트벤치
└── README.md
```

## 화면 구성

| mode | 1번째 줄 | 2번째 줄 |
|---|---|---|
| 0 일반 | `NORMAL  12:34:56` | `ALARM 07:30 ON  ` |
| 1 시계 설정 | `CLK SET 12:34:56` | `ALARM 07:30 ON  ` |
| 2 알람 설정 | `ALM SET 07:30   ` | `ALARM 07:30 ON  ` |
| 3 타이머 | `TIMER      02:59` | `STATUS: RUN     ` |

- 설정 중인 칸(`set_pos`)은 `blink`가 0일 때 공백이 되어 깜빡입니다.
- PSD 센서가 근접을 감지하면 2번째 줄 마지막 칸에 `*`가 표시됩니다.

## 입력 신호 (다른 파트에서 연결해 줄 것)

| 신호 | 폭 | 주는 사람 | 의미 |
|---|---|---|---|
| `mode` | 2 | 설정 | 0 일반, 1 시계설정, 2 알람설정, 3 타이머 |
| `cur_h / cur_m / cur_s` | 5/6/6 | 설정(시계) | 현재 시각 (2진수) |
| `alm_h / alm_m` | 5/6 | 알람 | 알람 시각 |
| `alm_on` | 1 | 알람 | 알람 On/Off |
| `tmr_m / tmr_s` | 6/6 | 타이머 | 남은 시간 |
| `tmr_run` | 1 | 타이머 | 카운트다운 중이면 1 |
| `set_pos` | 2 | 설정 | 깜빡일 칸: 0 없음, 1 시, 2 분, 3 초 |
| `blink` | 1 | `blink_gen` | 1Hz 깜빡임 신호 |
| `psd_near` | 1 | (PSD) | 근접 감지 |

> 시각을 BCD로 저장하는 팀원이 있다면 `lcd_formatter.v`의 `d2` 함수를
> `{8'h30 + v[7:4], 8'h30 + v[3:0]}` 식으로 바꾸면 됩니다.

## 사용 예시 (최상위 모듈에서 연결)

```verilog
wire blink;
blink_gen #(.CLK_FREQ(50_000_000)) u_blink (.clk(clk), .rst_n(rst_n), .blink(blink));

text_lcd_top #(.CLK_FREQ(50_000_000)) u_lcd (
    .clk(clk), .rst_n(rst_n),
    .mode(mode),
    .cur_h(hour), .cur_m(min), .cur_s(sec),
    .alm_h(alarm_hour), .alm_m(alarm_min), .alm_on(alarm_en),
    .tmr_m(timer_min), .tmr_s(timer_sec), .tmr_run(timer_running),
    .set_pos(set_pos), .blink(blink), .psd_near(psd_near),
    .lcd_e(LCD_E), .lcd_rs(LCD_RS), .lcd_rw(LCD_RW), .lcd_data(LCD_DATA)
);
```

## 시뮬레이션

```bash
iverilog -o sim tb/tb_text_lcd.v src/text_lcd_top.v src/lcd_formatter.v src/text_lcd_ctrl.v
vvp sim
gtkwave tb_text_lcd.vcd
```

터미널에 가상 LCD 화면이 이렇게 그려집니다.

```
+----------------+
|NORMAL  12:34:56|
|ALARM 07:30 ON  |
+----------------+
```

## 보드 적용 시 확인할 것

1. `CLK_FREQ`를 보드 클럭에 맞게 수정
2. 핀 이름·핀 번호는 11주차 Text LCD 실습 프로젝트의 Pin Planner 설정을 그대로 사용
3. 리셋이 active-low(`rst_n`)이므로, 보드 버튼이 active-high면 `~` 붙여서 연결
