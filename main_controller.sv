`include "main_fsm.sv"
`include "alu_decoder.sv"
`include "instr_decoder.sv"
`include "branch_decoder.sv"

module control_unit(
    input logic clk, rst,
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic funct7b5,
    input logic Zero, CarryOut, Overflow, Sign,
    output logic [2:0] ImmSrc,
    output logic [1:0] ALUSrcA, ALUSrcB,
    output logic [1:0] ResultSrc,
    output logic AdrSrc,
    output logic [3:0] ALUControl,
    output logic IRWrite, PCWrite,
    output logic RegWrite, MemWrite
);

	logic beq, bne, blt, bge, bltu, bgeu, branch, PCUpdate;
	logic [1:0] ALUOp;
	
    main_fsm MainFSM (
        .clk            (clk), 
        .rst            (rst),
        .op             (op), 
        .branch         (branch), 
        .PCUpdate       (PCUpdate), 
        .RegWrite       (RegWrite), 
        .MemWrite       (MemWrite), 
        .IRWrite        (IRWrite), 
        .ResultSrc      (ResultSrc), 
        .ALUSrcB        (ALUSrcB), 
        .ALUSrcA        (ALUSrcA), 
        .AdrSrc         (AdrSrc), 
        .ALUOp          (ALUOp)
    );
    alu_decoder AluDecoder (
        .ALUOp          (ALUOp), 
        .op5            (op[5]), 
        .funct7b5       (funct7b5), 
        .funct3         (funct3), 
        .ALUControl     (ALUControl)
    );
    instr_decoder InstrDecoder (
        .op             (op), 
        .ImmSrc         (ImmSrc)
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

	
	assign PCWrite = 
       (beq  &  Zero)               // branch if equal
    |  (bne  & ~Zero)               // branch if not equal
    |  (bgeu &  CarryOut)           // branch if greater than or equal unSigned
    |  (bltu & ~CarryOut)           // branch if less than unSigned
    |  (bge  & (Sign == Overflow))  // branch if greater than or equal Signed
    |  (blt  & (Sign != Overflow))  // branch if less than Signed
    |  PCUpdate;                    // always update if PCUpdate is high

	
endmodule 
