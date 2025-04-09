module ALU (
    input logic clk,
    input logic [31:0] SrcA,
    input logic [31:0] SrcB,
    input logic [2:0] ALUControl,
    output logic Zero,
    output logic [31:0] ALUResult
);

always_comb begin
    Zero = 0;

    case (ALUControl)
        3'b000: begin
            ALUResult = SrcA + SrcB;
        end 
        3'b001: begin
            ALUResult = SrcA - SrcB;
            if (ALUResult == 0) begin
                Zero = 1;
            end
        end
        3'b011: begin 
            ALUResult = SrcA | SrcB; // or
        end
        3'b010: begin 
            ALUResult = SrcA & SrcB; // and
        end
        3'b101: begin
            ALUResult = (SrcA + SrcB)[31]; // slt (set less than) -- check two's complement?
        end
        default: begin
            ALUResult = 32'bx;
        end
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
