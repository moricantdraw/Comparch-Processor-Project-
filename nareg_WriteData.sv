module nareg_WriteData(
    input logic     clk,
    input logic     rst,
    input logic     [31:0] RD1,
    input logic     [31:0] RD2,
    output logic    [31:0] A,
    output logic    [31:0] WriteData
);
    always_ff@(posedge clk, posedge rst) begin
        if (rst) begin
            A <= 32'h00000000; // Reset A to 0
            WriteData <= 32'h00000000; // Reset WriteData to 0
        end else begin
            // when A and WriteData are updated, store the RD1 and RD2
            A <= RD1;
            WriteData <= RD2;
        end
    end  
endmodule
