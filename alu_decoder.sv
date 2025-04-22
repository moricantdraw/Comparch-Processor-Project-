module alu_decoder (
    input logic [1:0] ALUOp,
    input logic op5, funct7b5,
    input logic [2:0] funct3,
    output logic [3:0] ALUControl
);

    always_comb begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0000;
            2'b01: ALUControl = 4'b0001;
            2'b10: 
                case (funct3)
                    3'b000: 
                        if ({op5, funct7b5} == 2'b11)
                            ALUControl = 4'b0001;
                        else
                            ALUControl = 4'b0000;
                    3'b001: // sll
                        ALUControl = 4'b0111;
                    3'b010: 
                        ALUControl = 4'b0101;
                    3'b011: // sltu
                        ALUControl = 4'b1000;
                    3'b100: // xor
                        ALUControl = 4'b1001;
                    3'b101: 
                        if (funct7b5) // sra
                            ALUControl = 4'b0100;
                        else // srl
                            ALUControl = 4'b0110;
                    3'b110: 
                        ALUControl = 4'b0011;
                    3'b111: 
                        ALUControl = 4'b0010;
                    default: 
                        ALUControl = 4'bx;
                endcase
            default: 
                ALUControl = 4'bx;
        endcase
    end

endmodule
