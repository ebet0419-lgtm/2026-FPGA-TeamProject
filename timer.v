// Independent 24-hour-format countdown timer for this settings project.
module timer(
    output reg [5:0] o_hour,
    output reg [5:0] o_min,
    output reg [5:0] o_sec,
    output reg       o_buzzer_enb, // active-low buzzer enable
    input wire [2:0] i_mode,
    input wire       i_start,
    input wire [5:0] i_set_hour,
    input wire [5:0] i_set_min,
    input wire [5:0] i_set_sec,
    input wire       i_1hz_tick,
    input wire       i_clk,
    input wire       i_rstn
);
    localparam [2:0] MODE_TIMER_RUN = 3'b100;
    reg [28:0] buzzer_count;
    reg buzzer_active;

    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            o_hour <= 0; o_min <= 0; o_sec <= 0;
            buzzer_count <= 0;
            buzzer_active <= 0;
            o_buzzer_enb <= 1'b1;
        end else begin
            if (i_start) begin
                o_hour <= (i_set_hour > 23) ? 0 : i_set_hour;
                o_min  <= (i_set_min > 59) ? 0 : i_set_min;
                o_sec  <= (i_set_sec > 59) ? 0 : i_set_sec;
                buzzer_active <= 1'b0;
                buzzer_count <= 0;
                o_buzzer_enb <= 1'b1;
            end else if ((i_mode == MODE_TIMER_RUN) && i_1hz_tick &&
                         !buzzer_active) begin
                if ((o_hour == 0) && (o_min == 0) && (o_sec == 0)) begin
                    buzzer_active <= 1'b1;
                    buzzer_count <= 0;
                    o_buzzer_enb <= 1'b0;
                end else if (o_sec != 0) begin
                    o_sec <= o_sec - 1'b1;
                end else if (o_min != 0) begin
                    o_sec <= 59;
                    o_min <= o_min - 1'b1;
                end else begin
                    o_sec <= 59;
                    o_min <= 59;
                    o_hour <= o_hour - 1'b1;
                end
            end

            if (buzzer_active) begin
                if (buzzer_count >= 250000000-1) begin
                    buzzer_active <= 1'b0;
                    buzzer_count <= 0;
                    o_buzzer_enb <= 1'b1;
                end else begin
                    buzzer_count <= buzzer_count + 1'b1;
                    o_buzzer_enb <= 1'b0;
                end
            end
        end
    end
endmodule
