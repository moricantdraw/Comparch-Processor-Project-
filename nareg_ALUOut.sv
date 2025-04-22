module nareg_ALUOut(
    input logic     clk,
    input logic     ALUResult,
    output logic     ALUOut
);
    always_ff@(posedge clk) begin 
        ALUOut <= ALUResult;
    end

endmodule
