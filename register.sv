module register (
    input logic     clk,
    input logic     [5:0] a1, a2, a3,
    input logic     we3,
    input logic     [31:0] wd3,
    output logic    [31:0] rd1, rd2
);

    logic [31:0] registers [31:0];

    // Write port
    always_ff @(posedge clk) begin
        if (we3) begin
            registers[a3] <= wd3;
        end
    end

    assign rd1 = (a1 != 0) ? rf[a1] : 0;
    assign rd2 = (a2 != 0) ? rf[a2] : 0;

endmodule
