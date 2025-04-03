module ALU (
    input logic clk,
    input logic SrcA,
    input logic SrcB,
    input logic [2:0] ALUControl,
    output logic Zero,
    output logic [31:0] ALUResult
);

// depending on 
always_ff @(psedge clk) begin
    case (ALUControl)
        3'b000:
            ALUResult = SrcA + SrcB;
        3'b001:
            ALUResult = SrcA - SrcBl
        3'b101: // set less than
        3'b011: // or
        3'010: //  
    endcase
end


endmodule
