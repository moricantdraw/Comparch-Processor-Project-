module nareg_ALUOut(
    input logic     clk,
    input logic     [31:0] ALUResult,
    output logic    [31:0] ALUOut
);
    always_ff@(posedge clk) begin 
        ALUOut <= ALUResult;
    end

endmodule
