module instr_decoder (
    input logic [6:0] op,
	output logic [2:0] ImmSrc
);

	always_comb begin
	
		case(op)
		7'b0110011: ImmSrc = 3'b000;
		7'b0010011: ImmSrc = 3'b000;
		7'b0000011: ImmSrc = 3'b000;
		7'b0100011: ImmSrc = 3'b001;
		7'b1100011:	ImmSrc = 3'b010;
		7'b1101111: ImmSrc = 3'b011;
		7'b0010111: ImmSrc = 3'b100;
		7'b0110111: ImmSrc = 3'b100;
		7'b1100111: ImmSrc = 3'b000;
		default: ImmSrc = 3'bx;
		endcase
	
	end
						
						
endmodule 
