module PC_adder(
    input logic [31:0] PC,
    output logic [31:0] PCPlus4
);

assign PCPlus4 = PC + 4;

endmodule
