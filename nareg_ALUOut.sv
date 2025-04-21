module na_reg_ALUOut(
    input logic     ALUResult,
    output logic     ALUOut
);
    always_ff@(posedge clk) begin 
        ALUOut <= ALUResult;
    end

endmodule
