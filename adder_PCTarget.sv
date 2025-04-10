module PCTarget_adder(
    input logic [31:0] PC,
    input logic [31:0] ImmExt
    output logic [31:0] PCTarget
);

assign PCTarget = PC + ImmExt;

endmodule
