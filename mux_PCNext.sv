module PCNext_mux(
    input logic [31:0] PCPlus4,
    input logic [31:0] PCTarget,
    input logic PCSrc,
    output logic [31:0] PCNext
);

assign PCNext = PCSrc ? PCPlus4 : PCTarget;

endmodule
