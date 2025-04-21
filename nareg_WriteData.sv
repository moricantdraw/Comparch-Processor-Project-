module na_reg_WriteData(
    input logic     RD1,
    input logic     RD2,
    output logic    A,
    output logic    WriteData
);
    always_ff@(posedge clk) begin
        A <= RD1;
        WriteData <= RD2;
    end  
endmodule
