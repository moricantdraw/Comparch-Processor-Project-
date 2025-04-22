/*something stored in 12 bits - called ImmShort
must be sign extend into 32 bits 
sign extention is copying the sign bit into the most significant bits such that ImmExt_31:12 = Instr_31 and ImmExt_11:0 = Instr_31:20

The extend unit recieves 12 bit signed immediate in Instr_31:20
The extend unit produces 32 bit sign-extended immediate ImmExt*/
``timescale 1ns / 1ps

module Extend(
    input logic [31:7] Instr,
    input logic [2:0] ImmSrc,
    output logic [31:0] ImmExt
);
    always_comb begin 
        case (ImmSrc)
            // I-type 
            3'b000: ImmExt = {{20{Instr[31]}}, Instr[31:20]};
            // S-type
            3'b001: ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};
            // B-type
            3'b010: ImmExt = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};
            // U-type
            3'b100: ImmExt = {Instr[31:12], 12'b0}; 
            // J-type
            3'b011: ImmExt = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};
            default:
                imm = 32'b0;
        endcase
    end
    
endmodule
