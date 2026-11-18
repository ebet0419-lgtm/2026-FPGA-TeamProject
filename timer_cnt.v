module timer_cnt
(
    output reg [6:0] o_cnt,
    input            i_load,
    input            i_en,
    input            i_clk,
    input            i_rstn
);

    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            o_cnt <= 7'd60;
        end
        else begin
            if (i_load) begin
                o_cnt <= 7'd60;
            end
            else if (i_en && o_cnt > 0) begin
                o_cnt <= o_cnt - 1'b1;
            end
        end
    end

endmodule