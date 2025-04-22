module nareg_WriteData(
    input logic     clk,
    input logic     [31:0] RD1,
    input logic     [31:0] RD2,
    output logic    [31:0] A,
    output logic    [31:0] WriteData
);
    always_ff@(posedge clk) begin
        A <= RD1;
        WriteData <= RD2;
    end  
endmodule
