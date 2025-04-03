module register (
    input logic     clk,
    input logic     [4:0] A1,
    input logic     [4:0] A2,
    input logic     [4:0] A3,
    input logic     WE3,
    input logic     [31:0] WD3,
    output logic    [31:0] RD1,
    output logic    [31:0] RD2
);

    logic [31:0] registers [31:0];

    // Write port
    always_ff @(posedge clk) begin
        RD1 <= registers[A1];
        RD2 <= registers[A2];

        if (WE3) begin
            registers[A3] <= WD3;
        end
    end

endmodule
