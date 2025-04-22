module nareg_PC(
    input logic     clk,
    input logic     rst,
    input logic     [31:0] PCNext,
    input logic     PCWrite,
    output logic    [31:0] PC
);

    always_ff@(posedge clk, posedge rst) begin
        if (rst) begin
            PC <= 32'h00000000; // Reset PC to 0
        end else begin
            // when PCWrite asserted from Control Unit, PC stored
            if (PCWrite) begin
                PC <= PCNext;
            end
        end
        
    end
endmodule
