module branchDec(
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic branch,
    output logic beq, bne, blt, bge, bltu, bgeu
);

    always_comb begin
        beq  = 0;
        bne  = 0;
        blt  = 0;
        bge  = 0;
        bltu = 0;
        bgeu = 0;

        if (op == 7'b1100011 && branch) begin
            case (funct3)
                3'b000: beq  = 1; 
                3'b001: bne  = 1; 
                3'b100: blt  = 1;
                3'b101: bge  = 1; 
                3'b110: bltu = 1; 
                3'b111: bgeu = 1;
            endcase
        end
    end
                
endmodule  
