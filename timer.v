module timer(
    output reg [5:0] o_hour,
    output reg [5:0] o_min,
    output reg [5:0] o_sec,
    output reg       o_buzzer_enb,

    input wire [2:0] i_mode,
    input wire       i_start,
    input wire       i_psd_clear,   

    input wire [5:0] i_set_hour,
    input wire [5:0] i_set_min,
    input wire [5:0] i_set_sec,

    input wire       i_1hz_tick,
    input wire       i_clk,
    input wire       i_rstn
);

    localparam [2:0] MODE_TIMER_RUN = 3'b100;

    reg buzzer_active;
    reg timer_done;

    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            o_hour        <= 6'd0;
            o_min         <= 6'd0;
            o_sec         <= 6'd0;
            buzzer_active <= 1'b0;
            timer_done    <= 1'b0;
            o_buzzer_enb  <= 1'b1;
        end
        else if (i_start) begin
            o_hour        <= (i_set_hour > 23) ? 6'd0 : i_set_hour;
            o_min         <= (i_set_min > 59)  ? 6'd0 : i_set_min;
            o_sec         <= (i_set_sec > 59)  ? 6'd0 : i_set_sec;
            buzzer_active <= 1'b0;
            timer_done    <= 1'b0;
            o_buzzer_enb  <= 1'b1;

            if ((i_set_hour == 0) && (i_set_min == 0) && (i_set_sec == 0)) begin
                buzzer_active <= 1'b1;
                o_buzzer_enb  <= 1'b0;
            end
        end
        
        else if (buzzer_active) begin
            if (i_psd_clear || (i_mode != MODE_TIMER_RUN)) begin
                buzzer_active <= 1'b0;
                timer_done    <= 1'b1;
                o_buzzer_enb  <= 1'b1;
            end else begin
                o_buzzer_enb  <= 1'b0;
            end
        end
        else if ((i_mode == MODE_TIMER_RUN) && i_1hz_tick && !timer_done) begin
            if ((o_hour == 0) && (o_min == 0) && (o_sec == 0)) begin
                buzzer_active <= 1'b1;
                o_buzzer_enb  <= 1'b0;
            end
            else if ((o_hour == 0) && (o_min == 0) && (o_sec == 1)) begin
                o_sec         <= 6'd0;
                buzzer_active <= 1'b1;
                o_buzzer_enb  <= 1'b0;
            end
            else if (o_sec != 0) begin
                o_sec <= o_sec - 1'b1;
            end
            else if (o_min != 0) begin
                o_sec <= 6'd59;
                o_min <= o_min - 1'b1;
            end
            else begin
                o_sec  <= 6'd59;
                o_min  <= 6'd59;
                o_hour <= o_hour - 1'b1;
            end
        end
    end
endmodule
