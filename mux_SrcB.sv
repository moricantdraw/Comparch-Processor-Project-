module mux_SrcB(
    input logic [31:0] WriteData, ImmExt,
    input logic [1:0] ALUSrcB,
    output logic SrcB,
);

always_comb begin
    case (ALUSrcB)
        2'b00: SrcB = WriteData;
        2'b01: SrcB = ImmExt;
        2'b10: SrcB = 4;
        default: SrcB = 32'bx;
    endcase
end

endmodule
