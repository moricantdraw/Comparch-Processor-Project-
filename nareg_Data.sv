module nareg_Data(
    input logic     clk,
    input logic     [31:0] ReadData,
    output logic    [31:0] Data
);
    always_ff@(posedge clk) begin
        Data <= ReadData;
    end
endmodule
