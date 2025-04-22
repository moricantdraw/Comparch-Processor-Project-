module register_file (
    input logic     clk,
    input logic     [4:0] a1, a2, a3,
    input logic     we3,
    input logic     [31:0] wd3,
    output logic    [31:0] rd1, rd2,
    output logic    [31:0] registers_debug [31:0]
);
    logic [31:0] registers [31:0];

    // initialize registers to 0 for simulation output 
    initial begin
        for (int i = 0; i < 32; i++) begin
            registers[i] = 32'b0;
        end
    end

    // Write port
    always_ff @(posedge clk) begin
        if (we3 && a3 != 0) begin
            registers[a3] <= wd3;
        end
    end

    assign registers_debug = registers; // for testing output 
    assign rd1 = (a1 != 0) ? registers[a1] : 0;
    assign rd2 = (a2 != 0) ? registers[a2] : 0;

endmodule

