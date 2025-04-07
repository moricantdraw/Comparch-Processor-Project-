module PC_adder(
    input logic [31:0] PC,
    output logic [31:0] PCPlus4
);

always_ff @(posedge clk) begin
    PCPlus4 = PC + 4;
end

endmodule
