`include "main_fsm.sv"
`include "alu_decoder.sv"
`include "instr_decoder.sv"
`include "branch_decoder.sv"

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
    branch_decoder BranchDecoder (
        .op             (op), 
        .funct3         (funct3), 
        .branch         (branch), 
        .beq            (beq), 
        .bne            (bne), 
        .blt            (blt), 
        .bge            (bge), 
        .bltu           (bltu), 
        .bgeu           (bgeu)
    );

	
	assign pcwrite = 
       (beq  &  zero)               // branch if equal
    |  (bne  & ~zero)               // branch if not equal
    |  (bgeu &  cout)               // branch if greater than or equal unsigned
    |  (bltu & ~cout)               // branch if less than unsigned
    |  (bge  & (sign == overflow))  // branch if greater than or equal signed
    |  (blt  & (sign != overflow))  // branch if less than signed
    |  pcupdate;                    // always update if pcupdate is high

	
endmodule 
