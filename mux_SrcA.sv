module mux_SrcA(
    input logic     [31:0] PC,
    input logic     [31:0] OldPC,
    input logic     [31:0] A,
    input logic     [1:0] ALUSrcA,
    output logic    [31:0] SrcA
);

always_comb begin
    case (ALUSrcA)
        2'b00: SrcA = PC;
        2'b01: SrcA = OldPC;
        2'b10: SrcA = A;
        default: SrcA = 32'bx;
    endcase
end

endmodule
