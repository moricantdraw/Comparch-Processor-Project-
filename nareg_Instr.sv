module nareg_Instr(
    input logic     clk,
    input logic     rst,
    input logic     [31:0] RD,
    input logic     [31:0] PC,
    input logic     IRWrite,
    output logic    [31:0] Instr,
    output logic    [31:0] OldPC
);

    always_ff@(posedge clk, posedge rst) begin
        if (rst) begin
            Instr <= 32'h00000000; // Reset Instr to 0
            OldPC <= 32'h00000000; // Reset OldPC to 0
        end else begin
            // when IRWrite asserted from Control Unit during fetch, Instr stored
            if (IRWrite) begin
                Instr <= RD;

                // OldPC syncs with being captured at the same time too
                OldPC <= PC;
            end
        end
    end

endmodule
