module register_file (
    input logic     clk,
    input logic     [4:0] a1, a2, a3,
    input logic     we3,
    input logic     [31:0] wd3,
    output logic    [31:0] rd1, rd2,
    output logic    [31:0] registers_debug [31:0]
);
    logic [31:0] registers [31:0];

    // Write port
    always_ff @(posedge clk) begin
        if (we3) begin
            registers[a3] <= wd3;
        end
    end

    assign registers_debug = registers; // for testing output 
    assign rd1 = (a1 != 0) ? registers[a1] : 0;
    assign rd2 = (a2 != 0) ? registers[a2] : 0;

endmodule

