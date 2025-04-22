module control_unit(
    input logic clk,
    input logic reset,
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic funct7b5,
    input logic zero, carry_out, overflow, sign,
    output logic [2:0] immsrc,
    output logic [1:0] alusrca, alusrcb,
    output logic [1:0] resultsrc,
    output logic adrsrc,
    output logic [3:0] alucontrol,
    output logic irwrite, pcwrite,
    output logic regwrite, memwrite
);

	logic beq, bne, blt, bge, bltu, bgeu, branch, pcupdate;
	logic [1:0] aluop;
	
    main_fsm MainFSM (
        .clk            (clk), 
        .op             (op), 
        .branch         (branch), 
        .pcupdate       (pcupdate), 
        .regwrite       (regwrite), 
        .memwrite       (memwrite), 
        .irwrite        (irwrite), 
        .resultsrc      (resultsrc), 
        .alusrcb        (alusrcb), 
        .alusrca        (alusrca), 
        .adrsrc         (adrsrc), 
        .aluop          (aluop)
    );
    alu_decoder AluDecoder (
        .aluop          (aluop), 
        .op5            (op[5]), 
        .funct7b5       (funct7b5), 
        .funct3         (funct3), 
        .alucontrol     (alucontrol)
    );
    instr_decoder InstrDecoder (
        .op             (op), 
        .immsrc         (immsrc)
    );

    // Branch instructions
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
	
	assign pcwrite = 
       (beq  &  zero)               // branch if equal
    |  (bne  & ~zero)               // branch if not equal
    |  (bgeu &  cout)               // branch if greater than or equal unsigned
    |  (bltu & ~cout)               // branch if less than unsigned
    |  (bge  & (sign == overflow))  // branch if greater than or equal signed
    |  (blt  & (sign != overflow))  // branch if less than signed
    |  pcupdate;                    // always update if pcupdate is high

	
endmodule 
