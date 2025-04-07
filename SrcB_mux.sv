module SrcB_mux(
    input logic [31:0] RD2, ImmExt,
    input logic ALUSrc,
    output logic [31:0] SrcB,
);

always_ff @(posedge clk) begin
    SrcB = ALUSrc ? RD2 : ImmExt;
end

endmodule
