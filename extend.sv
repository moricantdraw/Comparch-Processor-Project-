/*something stored in 12 bits - called ImmShort
must be sign extend into 32 bits 
    sign extention is copying the sign bit into the most significant bits such that ImmExt_31:12 = Instr_31 and ImmExt_11:0 = Instr_31:20

The extend unit recieves 12 bit signed immediate in Instr_31:20
The extend unit produces 32 bit sign-extended immediate ImmExt*/
``timescale 1ns / 1ps

module Extend(
    input logic [31:7] Instr,
    input logic [1:0] ImmSrc,
    output logic [31:0] ImmExt
);

    always_comb begin 
        case (ImmSrc)
            // fill in extend unit implementation
        endcase
    end


always_ff @(posedge CLK) begin
    ImmExt <= { {20{ImmShort[11]}}, ImmShort }; 
end

endmodule

// //I
// 3'b000: immext = {{20{instr[31]}}, instr[31:20]};
// //S
// 3'b001: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
// //B
// 3'b010: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
// //J
// 3'b011: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
// //U
// 3'b100: immext = {instr[31:12], 12'b0};
// default: immext = 32'bx; // undefined ? ?
