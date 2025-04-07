module ALU (
    input logic clk,
    input logic [31:0] SrcA,
    input logic [31:0] SrcB,
    input logic [2:0] ALUControl,
    output logic Zero,
    output logic [31:0] ALUResult
);

// depending on 
always_ff @(psedge clk) begin
    case (ALUControl)
        3'b000: ALUResult = SrcA + SrcB;
        3'b001: ALUResult = SrcA - SrcBl
        3'b011: ALUResult = SrcA | SrcB; // or
        3'b010: ALUResult = SrcA & SrcB; // and
        3'b101: ALUResult = (SrcA + SrcB)[31]; // slt (set less than) -- are we using two's complement?
        default: ALUResult = 32'bx;
    endcase
end
endmodule


// textbook exercise 5.13 solution (ALU expanded to support SLT)
// module alu(input  logic [31:0] a,
//            input  logic [31:0] b,
//            input  logic [2:0]  alucontrol,
//            output logic [31:0] result);

// logic [31:0] condinvb, sum;
// logic        cout;           // carry out of adder
// assign condinvb = alucontrol[0] ? ~b : b;
// assign {cout, sum} = a + condinvb + alucontrol[0];
//   always_comb
//     case (alucontrol)
//       3'b000:   result = sum;
//       3'b001:   result = sum;
//       3'b010:   result = a & b;
//       3'b011:   result = a | b;
//       3'b101:   result = sum[31];
//       default:  result = 32'bx;
//     endcase
// endmodule
