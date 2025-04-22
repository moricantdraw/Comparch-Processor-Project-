module nareg_ALUOut(
    input logic     clk,
    input logic     rst,
    input logic     [31:0] ALUResult,
    output logic    [31:0] ALUOut
);
    always_ff@(posedge clk, posedge rst) begin 
        if (rst) begin
            ALUOut <= 32'h00000000; // Reset ALUOut to 0
        end else begin
            // when ALUOut is updated, store the ALUResult
            ALUOut <= ALUResult;
        end
        
    end

endmodule
