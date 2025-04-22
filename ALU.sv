module ALU (
    input logic     [31:0] SrcA,
    input logic     [31:0] SrcB,
    input logic     [3:0] ALUControl,
    output logic    [31:0] ALUResult,
    output logic    Zero,
    output logic    CarryOut,
    output logic    Overflow,
    output logic    Sign
);

always_comb begin
    // defaults to be updated if met in below cases
    Zero = 0;
    CarryOut = 0;
    Overflow = 0;

    case (ALUControl)
        4'b0000: begin // addition
            {CarryOut, ALUResult} = {1'b0, SrcA} + {1'b0, SrcB};
            // checking for signed overflow (adding 2 same-signed values gives different sign)
            Overflow = (SrcA[31] == SrcB[31]) && (ALUResult[31] != SrcA[31]);
        end 
        4'b0001: begin // subtraction
            {CarryOut, ALUResult} = {1'b0, SrcA} + (~{1'b0, SrcB} + 1);
            // checking for signed overflow (subtracting too far in a direction flips the sign)
            Overflow = (SrcA[31] != SrcB[31]) && (ALUResult[31] != SrcA[31]);
        end
        4'b0010: begin // and
            ALUResult = SrcA & SrcB; 
        end
        4'b0011: begin  // or
            ALUResult = SrcA | SrcB; 
        end
        4'b0100: begin // sra (shift right arithmetic)
			ALUResult = $signed(SrcA) >>> SrcB[4:0];
        end 
        4'b0101: begin // slt (set less than)
            ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 32'd1 : 32'd0;
        end
        4'b0110: begin // srl (shift right logical)
            ALUResult = SrcA >> SrcB[4:0];
        end
        4'b0111: begin // sll (shift left logical)
            ALUResult = SrcA << SrcB[4:0];
        end
        4'b1000: begin // sltu (set less than unsigned)
            ALUResult = (SrcA < SrcB) ? 32'd1 : 32'd0;			
		end
        4'b1001: begin // xor
			ALUResult = SrcA ^ SrcB;
		end
        default: begin
            ALUResult = 32'bx;
        end
    endcase

    // set Sign flag (MSB cuz two's complement)
    Sign = ALUResult[31];

    // check for Zero flag case
    if (ALUResult == 0) begin
        Zero = 1;
    end
end
endmodule
