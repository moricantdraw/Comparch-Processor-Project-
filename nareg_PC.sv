module nareg_PC(
    input logic     clk,
    input logic     [31:0] PCNext,
    input logic     PCWrite,
    output logic    [31:0] PC
);

    initial begin
        PC = 32'b0;
    end

    always_ff@(posedge clk) begin
        if (PCWrite) begin
            PC <= PCNext;
        end
    end

endmodule
