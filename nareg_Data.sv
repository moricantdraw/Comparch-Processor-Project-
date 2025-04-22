module nareg_Data(
    input logic     clk,
    input logic     rst,
    input logic     [31:0] ReadData,
    output logic    [31:0] Data
);
    always_ff@(posedge clk, posedge rst) begin
        if (rst) begin
            Data <= 32'h00000000; // Reset Data to 0
        end else begin
            // when Data is updated, store the ReadData
            Data <= ReadData;
        end
    end
endmodule
