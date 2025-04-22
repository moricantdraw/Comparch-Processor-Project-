module mux_Result(
    input logic     [31:0] ALUOut,
    input logic     [31:0] Data,
    input logic     [31:0] ALUResult,
    input logic     [1:0] ResultSrc,
    output logic    [31:0] Result
);

always_comb begin
    case (ResultSrc)
        2'b00: Result = ALUOut;
        2'b01: Result = Data;
        2'b10: Result = ALUResult;
        2'b11: Result = ImmExt;
        default: Result = 32'bx;
    endcase
end

endmodule
