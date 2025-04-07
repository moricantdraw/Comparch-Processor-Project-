module Result_mux(
    input logic [31:0] ALUResult,
    input logic [31:0] read_data,
    input logic [31:0] PCPlus4, 
    input logic [1:0] ResultSrc,
    output logic [31:0] Result
);

always_ff @(posedge clk)begin
    Result = ResultSrc[1] ? PCPlus4 : (ResultSrc[0] ? read_data : ALUResult);
end

endmodule
