`include "ctrl_nco.v"
`include "ctrl_debouncer.v"

module ctrl
(
    output reg       o_alarm_en,
    output reg [1:0] o_mode,
    output reg       o_alarm_min_clk,
    output reg       o_alarm_sec_clk,
    output reg       o_clock_min_clk,
    output reg       o_clock_sec_clk,
    output           o_1hz_clk,

    input            i_clock_min_max,
    input            i_clock_sec_max,
    input      [7:0] i_sw,
    input            i_clk,
    input            i_rstn
);

    wire       clk_1hz;
    wire [7:0] sw;

    assign o_1hz_clk = clk_1hz;

    ctrl_debouncer
    #(
        .FREQDIV (5000000)
    )
    u_ctrl_debouncer
    (
        .o_sw   (sw),
        .i_sw   (i_sw),
        .i_clk  (i_clk),
        .i_rstn (i_rstn)
    );

    ctrl_nco
    #(
        .FREQDIV (50000000)
    )
    u_ctrl_nco
    (
        .o_clk  (clk_1hz),
        .i_clk  (i_clk),
        .i_rstn (i_rstn)
    );

    reg [1:0] c_mode;
    reg [1:0] n_mode;

    reg       c_targ;
    reg       n_targ;

    localparam MODE_CLOCK_OPR = 2'b00;
    localparam MODE_CLOCK_SET = 2'b01;
    localparam MODE_ALARM_SET = 2'b10;
    localparam MODE_TIMER     = 2'b11;

    localparam TARG_SEC = 1'b0;
    localparam TARG_MIN = 1'b1;

    // State Register
    always @(posedge sw[0] or negedge i_rstn) begin
        if (!i_rstn) begin
            c_mode <= MODE_CLOCK_OPR;
        end
        else begin
            c_mode <= n_mode;
        end
    end

    always @(posedge sw[1] or negedge i_rstn) begin
        if (!i_rstn) begin
            c_targ <= TARG_SEC;
        end
        else begin
            c_targ <= n_targ;
        end
    end

    // Next Mode Logic
    always @(*) begin
        case (c_mode)
            MODE_CLOCK_OPR: n_mode = MODE_CLOCK_SET;
            MODE_CLOCK_SET: n_mode = MODE_ALARM_SET;
            MODE_ALARM_SET: n_mode = MODE_TIMER;
            MODE_TIMER:     n_mode = MODE_CLOCK_OPR;
            default:        n_mode = MODE_CLOCK_OPR;
        endcase
    end

    // Next Target Logic
    always @(*) begin
        case (c_targ)
            TARG_SEC: n_targ = TARG_MIN;
            TARG_MIN: n_targ = TARG_SEC;
            default:  n_targ = TARG_SEC;
        endcase
    end

    // Output Combinational Logic
    always @(*) begin

        o_mode          = c_mode;

        o_clock_sec_clk = 1'b0;
        o_clock_min_clk = 1'b0;

        o_alarm_sec_clk = 1'b0;
        o_alarm_min_clk = 1'b0;

        case (c_mode)

            MODE_CLOCK_OPR: begin
                o_clock_sec_clk = clk_1hz;
                o_clock_min_clk = i_clock_sec_max;
            end

            MODE_CLOCK_SET: begin
                case (c_targ)
                    TARG_SEC: begin
                        o_clock_sec_clk = ~sw[2];
                    end

                    TARG_MIN: begin
                        o_clock_min_clk = ~sw[2];
                    end
                endcase
            end

            MODE_ALARM_SET: begin
                o_clock_sec_clk = clk_1hz;
                o_clock_min_clk = i_clock_sec_max;

                case (c_targ)
                    TARG_SEC: begin
                        o_alarm_sec_clk = ~sw[2];
                    end

                    TARG_MIN: begin
                        o_alarm_min_clk = ~sw[2];
                    end
                endcase
            end

            MODE_TIMER: begin
                // Clock continues to operate in Timer Mode
                o_clock_sec_clk = clk_1hz;
                o_clock_min_clk = i_clock_sec_max;
            end

            default: begin
                o_clock_sec_clk = 1'b0;
                o_clock_min_clk = 1'b0;
                o_alarm_sec_clk = 1'b0;
                o_alarm_min_clk = 1'b0;
            end

        endcase
    end

    // Alarm Enable Switch
    always @(posedge sw[3] or negedge i_rstn) begin
        if (!i_rstn) begin
            o_alarm_en <= 1'b0;
        end
        else begin
            o_alarm_en <= ~o_alarm_en;
        end
    end

endmodule