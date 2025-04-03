/*something stored in 12 bits - called ImmShort
must be sign extend into 32 bits 
    sign extention is copying the sign bit into the most significant bits such that ImmExt_31:12 = Instr_31 and ImmExt_11:0 = Instr_31:20

The extend unit recieves 12 bit signed immediate in Instr_31:20
The extend unit produces 32 bit sign-extended immediate ImmExt*/
``timescale 1ns / 1ps

module Extend(
    input logic CLK,
    input logic [11:0] ImmShort,
    output logic [31:0] ImmExt
);

always_ff @(posedge CLK) begin
    ImmExt <= { {20{ImmShort[11]}}, ImmShort }; 
end

endmodule
