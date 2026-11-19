module buzzer_sheet
(
    output reg [31:0] o_note,
    input      [5:0]  i_cnt
);

    localparam C5   = 95556;
    localparam D5   = 85132;
    localparam E5   = 75844;
    localparam F5   = 71586;
    localparam G5   = 63776;
    localparam A5   = 56818;
    localparam B5   = 50620;
    localparam C4   = C5*2;
    localparam D4   = D5*2;
    localparam E4   = E5*2;
    localparam F4   = F5*2;
    localparam G4   = G5*2;
    localparam A4   = A5*2;
    localparam B4   = B5*2;
    localparam REST = 1000;

    always@(*)begin
        case(i_cnt)
            8'd00: o_note = E5;
            8'd01: o_note = E5;
            8'd02: o_note = REST;
            8'd03: o_note = E5;
            8'd04: o_note = REST;
            8'd05: o_note = C5;
            8'd06: o_note = E5;
            8'd07: o_note = REST;

            8'd08: o_note = G5;
            8'd09: o_note = G5;
            8'd10: o_note = REST;
            8'd11: o_note = REST;
            8'd12: o_note = G4;
            8'd13: o_note = G4;
            8'd14: o_note = REST;
            8'd15: o_note = REST;

            8'd16: o_note = C5;
            8'd17: o_note = C5;
            8'd18: o_note = REST;
            8'd19: o_note = G4;
            8'd20: o_note = G4;
            8'd21: o_note = REST;
            8'd22: o_note = E4;
            8'd23: o_note = E4;

            8'd24: o_note = REST;
            8'd25: o_note = A4;
            8'd26: o_note = REST;
            8'd27: o_note = B4;
            8'd28: o_note = REST;
            8'd29: o_note = B4;
            8'd30: o_note = A4;
            8'd31: o_note = A4;

            8'd32: o_note = G4;
            8'd33: o_note = E5;
            8'd34: o_note = G5;
            8'd35: o_note = A5;
            8'd36: o_note = REST;
            8'd37: o_note = REST;
            8'd38: o_note = F5;
            8'd39: o_note = G5;

            8'd40: o_note = REST;
            8'd41: o_note = REST;
            8'd42: o_note = E5;
            8'd43: o_note = C5;
            8'd44: o_note = D5;
            8'd45: o_note = B4;
            8'd46: o_note = REST;
            8'd47: o_note = REST;

            8'd48: o_note = C5;
            8'd49: o_note = C5;
            8'd50: o_note = REST;
            8'd51: o_note = G4;
            8'd52: o_note = G4;
            8'd53: o_note = REST;
            8'd54: o_note = E4;
            8'd55: o_note = E4;

            8'd56: o_note = REST;
            8'd57: o_note = A4;
            8'd58: o_note = REST;
            8'd59: o_note = B4;
            8'd60: o_note = REST;
            8'd61: o_note = B4;
            8'd62: o_note = A4;
            8'd63: o_note = A4;
        endcase
    end

endmodule