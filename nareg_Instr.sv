module nareg_Instr(
    input logic     clk,
    input logic     [31:0] RD,
    input logic     [31:0] PC,
    input logic     IRWrite,
    output logic    [31:0] Instr,
    output logic    [31:0] OldPC
);

    always_ff@(posedge clk) begin
        // when IRWrite asserted from Control Unit during fetch, Instr stored
        if (IRWrite) begin
            Instr <= RD;

            // OldPC syncs with being captured at the same time too
            OldPC <= PC;
        end
    end

endmodule
