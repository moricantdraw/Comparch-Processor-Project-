module pc (
    input logic     clk,
    input logic     [31:0] PCNext,
    output logic    [31:0] PC
);

    initial begin
        PC = 32'b0;
    end

    always_ff @(posedge clk) begin
        PC <= PCNext;
    end

endmodule
