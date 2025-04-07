module PCTarget_adder(
    input logic [31:0] PC,
    input logic [31:0] ImmExt
    output logic [31:0] PCTarget
);

always_ff @(posedge clk) begin
    PCTarget = PC + ImmExt;
end
endmodule
