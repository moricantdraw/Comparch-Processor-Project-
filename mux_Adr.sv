module mux_Adr(
    input logic     [31:0] PC,
    input logic     [31:0] Result,
    output logic    [31:0] Adr,
);

assign Adr = AdrSrc ? Result : PC;

endmodule
