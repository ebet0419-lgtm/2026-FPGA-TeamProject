
`timescale 1ns/1ps

`include "top.v"

module settings_tb;

    reg i_clk;
    reg i_rstn;
    reg [7:0] i_sw;

    wire o_buzzer;
    wire [5:0] o_seg_enb;
    wire [7:0] o_seg;

    integer errors;
    reg old_blink_phase;

    // Test clock: 100 MHz
    initial i_clk = 0;
    always #5 i_clk = ~i_clk;

    top dut (
        .o_buzzer(o_buzzer),
        .o_seg_enb(o_seg_enb),
        .o_seg(o_seg),
        .i_sw(i_sw),
        .i_clk(i_clk),
        .i_rstn(i_rstn)
    );

    // Speed up simulation only.
    defparam dut.u_ctrl.DEBOUNCE_COUNT = 3;
    defparam dut.u_ctrl.CLK_FREQ = 10000;
    defparam dut.u_ssegdisp.BLINK_DIV = 20;
    defparam dut.u_ssegdisp.FREQDIV = 20;

    // Toggle a switch and wait for debounce.
    task flip_sw;
        input integer idx;
        begin
            @(negedge i_clk);
            i_sw[idx] = ~i_sw[idx];
            repeat (12) @(negedge i_clk);
        end
    endtask

    task check_value;
        input [5:0] actual;
        input [5:0] expected;
        input [255:0] name;
        begin
            if (actual !== expected) begin
                $display("FAIL: %0s expected=%0d actual=%0d",
                         name, expected, actual);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s = %0d", name, actual);
            end
        end
    endtask

    task check_mode;
        input [2:0] expected;
        begin
            if (dut.mode !== expected) begin
                $display("FAIL: Mode expected=%0d actual=%0d",
                         expected, dut.mode);
                errors = errors + 1;
            end else begin
                $display("PASS: Mode = %0d", dut.mode);
            end
        end
    endtask

    task check_blink;
        input [5:0] expected_mask;
        begin
            if (dut.blink_mask !== expected_mask ||
                dut.blink_en !== 1'b1) begin
                $display("FAIL: Blink mask expected=%b actual=%b",
                         expected_mask, dut.blink_mask);
                errors = errors + 1;
            end else begin
                $display("PASS: Blink mask = %b",
                         dut.blink_mask);
            end
        end
    endtask

    initial begin
        $dumpfile("settings_tb.vcd");
        $dumpvars(0, settings_tb);

        errors = 0;
        i_sw = 8'b0;
        i_rstn = 0;

        repeat (5) @(negedge i_clk);
        i_rstn = 1;
        repeat (5) @(negedge i_clk);

        // ==================================
        // TEST 1: CLOCK SETTINGS
        // ==================================
        $display("\n=== CLOCK SETTING TEST ===");

        flip_sw(0); // CLOCK SET
        check_mode(3'b001);
        check_blink(6'b000011); // Seconds

        flip_sw(2); // Increase seconds
        check_value(dut.clock_sec, 1, "Clock SEC INC");

        flip_sw(4); // Decrease seconds
        check_value(dut.clock_sec, 0, "Clock SEC DEC");

        flip_sw(4); // 00 -> 59
        check_value(dut.clock_sec, 59, "Clock SEC WRAP");

        flip_sw(1); // Select minutes
        check_blink(6'b001100);

        flip_sw(2);
        check_value(dut.clock_min, 1, "Clock MIN INC");

        flip_sw(4);
        check_value(dut.clock_min, 0, "Clock MIN DEC");

        flip_sw(1); // Select hours
        check_blink(6'b110000);

        flip_sw(4); // 00 -> 23
        check_value(dut.clock_hour, 23, "Clock HOUR WRAP");

        flip_sw(2); // 23 -> 00
        check_value(dut.clock_hour, 0, "Clock HOUR INC WRAP");

        
    // Check blink timer toggles exactly once.
    old_blink_phase = dut.u_ssegdisp.blink_phase;
    repeat (20) @(negedge i_clk);


        if (dut.u_ssegdisp.blink_phase !== old_blink_phase) begin
            $display("PASS: Blink phase toggles");
        end else begin
            $display("FAIL: Blink phase did not toggle");
            errors = errors + 1;
        end

        // ==================================
        // TEST 2: ALARM SETTINGS
        // ==================================
        $display("\n=== ALARM SETTING TEST ===");

        flip_sw(0); // ALARM SET
        check_mode(3'b010);
        check_blink(6'b000011);

        flip_sw(2);
        check_value(dut.alarm_sec, 1, "Alarm SEC INC");

        flip_sw(4);
        check_value(dut.alarm_sec, 0, "Alarm SEC DEC");

        flip_sw(1); // Minutes
        check_blink(6'b001100);

        flip_sw(2);
        check_value(dut.alarm_min, 1, "Alarm MIN INC");

        flip_sw(1); // Hours
        check_blink(6'b110000);

        flip_sw(4);
        check_value(dut.alarm_hour, 23, "Alarm HOUR WRAP");

        flip_sw(3); // Alarm enable
        if (dut.alarm_en === 1'b1)
            $display("PASS: Alarm ON");
        else begin
            $display("FAIL: Alarm ON");
            errors = errors + 1;
        end

        // ==================================
        // TEST 3: TIMER SETTINGS
        // ==================================
        $display("\n=== TIMER SETTING TEST ===");

        flip_sw(0); // TIMER SET
        check_mode(3'b011);
        check_blink(6'b000011);

        flip_sw(2);
        check_value(dut.timer_set_sec, 1, "Timer SEC INC");

        flip_sw(4);
        check_value(dut.timer_set_sec, 0, "Timer SEC DEC");

        flip_sw(1); // Minutes
        check_blink(6'b001100);

        flip_sw(2);
        check_value(dut.timer_set_min, 1, "Timer MIN INC");

        flip_sw(1); // Hours
        check_blink(6'b110000);

        flip_sw(2);
        check_value(dut.timer_set_hour, 1, "Timer HOUR INC");

        // ==================================
        // FINAL RESULT
        // ==================================
        $display("\n==========================");

        if (errors == 0)
            $display("ALL SETTINGS TESTS PASS");
        else
            $display("SETTINGS TEST FAIL: %0d errors", errors);

        $display("==========================");

        $finish;
    end

endmodule
