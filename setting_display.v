// Display source selector.
// digit order: num0=SS ones, num1=SS tens, num2=MM ones,
// num3=MM tens, num4=HH ones, num5=HH tens.
module setting_display(
    output reg [3:0] o_num0, o_num1, o_num2,
    output reg [3:0] o_num3, o_num4, o_num5,
    output reg [5:0] o_blink_mask,
    input wire [2:0] i_mode,
    input wire [1:0] i_target,
    input wire [5:0] i_clock_hour, i_clock_min, i_clock_sec,
    input wire [5:0] i_alarm_hour, i_alarm_min, i_alarm_sec,
    input wire [5:0] i_timer_hour, i_timer_min, i_timer_sec,
    input wire [5:0] i_timer_run_hour, i_timer_run_min, i_timer_run_sec
);
    localparam [2:0] MODE_CLOCK_RUN = 3'b000;
    localparam [2:0] MODE_CLOCK_SET = 3'b001;
    localparam [2:0] MODE_ALARM_SET = 3'b010;
    localparam [2:0] MODE_TIMER_SET = 3'b011;
    localparam [2:0] MODE_TIMER_RUN = 3'b100;
    localparam [1:0] TARGET_SEC = 2'b00;
    localparam [1:0] TARGET_MIN = 2'b01;
    localparam [1:0] TARGET_HOUR = 2'b10;

    reg [5:0] hour_v, min_v, sec_v;

    always @(*) begin
        case (i_mode)
            MODE_CLOCK_RUN, MODE_CLOCK_SET: begin
                hour_v = i_clock_hour;
                min_v = i_clock_min;
                sec_v = i_clock_sec;
            end
            MODE_ALARM_SET: begin
                hour_v = i_alarm_hour;
                min_v = i_alarm_min;
                sec_v = i_alarm_sec;
            end
            MODE_TIMER_SET: begin
                hour_v = i_timer_hour;
                min_v = i_timer_min;
                sec_v = i_timer_sec;
            end
            MODE_TIMER_RUN: begin
                hour_v = i_timer_run_hour;
                min_v = i_timer_run_min;
                sec_v = i_timer_run_sec;
            end
            default: begin
                hour_v = i_clock_hour;
                min_v = i_clock_min;
                sec_v = i_clock_sec;
            end
        endcase

        o_num0 = sec_v % 10;
        o_num1 = sec_v / 10;
        o_num2 = min_v % 10;
        o_num3 = min_v / 10;
        o_num4 = hour_v % 10;
        o_num5 = hour_v / 10;

        o_blink_mask = 6'b000000;
        if ((i_mode == MODE_CLOCK_SET) ||
            (i_mode == MODE_ALARM_SET) ||
            (i_mode == MODE_TIMER_SET)) begin
            case (i_target)
                TARGET_SEC:  o_blink_mask = 6'b000011;
                TARGET_MIN:  o_blink_mask = 6'b001100;
                TARGET_HOUR: o_blink_mask = 6'b110000;
                default:     o_blink_mask = 6'b000000;
            endcase
        end
    end
endmodule
