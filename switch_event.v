// Toggle-switch synchronizer/debouncer.
// Generates one clock-wide event whenever the stable switch state changes.
module switch_event #(
    parameter integer DEBOUNCE_COUNT = 250000
)(
    input  wire i_clk,
    input  wire i_rstn,
    input  wire i_sw,
    output reg  o_event
);
    reg sync1, sync2, stable_sw;
    reg [31:0] count;

    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            sync1 <= 1'b0;
            sync2 <= 1'b0;
            stable_sw <= 1'b0;
            count <= 32'd0;
            o_event <= 1'b0;
        end else begin
            sync1 <= i_sw;
            sync2 <= sync1;
            o_event <= 1'b0;

            if (sync2 == stable_sw) begin
                count <= 32'd0;
            end else if (count >= DEBOUNCE_COUNT-1) begin
                stable_sw <= sync2;
                count <= 32'd0;
                o_event <= 1'b1;
            end else begin
                count <= count + 1'b1;
            end
        end
    end
endmodule
