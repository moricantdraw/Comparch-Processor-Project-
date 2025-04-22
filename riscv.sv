`include "main_controller.sv"
`include "datapath.sv"

module riscv(
    input logic     clk, rst,
    input logic     [31:0] ReadData, // from memory module
    output logic    [31:0] Adr, // to memory module
    output logic    MemWrite, // to memory module
    output logic    [31:0] WriteData, // to memory module
    output logic    [2:0] funct3 // to memory module
);
    // Control Unit IO
    // input logic     [6:0] op, -- from Instr
    // input logic     [2:0] funct3, -- from Instr
    // input logic     funct7, -- from Instr
    // input logic     Zero,
    // output logic    PCSrc,
    // output logic    [1:0]ResultSrc,
    // output logic    MemWrite,
    // output logic    [2:0]ALUControl,
    // output logic    ALUSrc,
    // output logic    [1:0]ImmSrc,
    // output logic    RegWrite

    // Datapath IO
    // input  logic        clk, reset,
    // input  logic [2:0]  ImmSrc,
    // input  logic [3:0]  ALUControl,
    // input  logic [1:0]  ResultSrc,
    // input  logic        ALUSrc,
    // input  logic        PCSrc,
    // input  logic        RegWrite,
    // input  logic [31:0] ReadData,
    // output logic [31:0] pc,         // Instruction address (to instruction memory)
    // output logic [31:0] ALUResult,  // Memory address (to data memory)
    // output logic [31:0] WriteData,  // Data to write to memory
    // output logic [31:0] instr

    logic [1:0] ResultSrc;
    logic [2:0] ImmSrc;
    logic [1:0] ALUSrcA, ALUSrcB;
    logic AdrSrc;
    logic Zero, CarryOut, Overflow, Sign;
    logic [3:0] ALUControl;
    logic IRWrite, PCWrite;
    logic RegWrite;
    logic [31:0] Instr;

    logic opcode = Instr[6:0];
    assign funct3 = Instr[14:12]; // janky specific case of output cuz of memory module
    logic funct7b5 = Instr[30];
    
    // control unit IO
    control_unit ControlUnit (
        .clk            (clk), 
        .rst            (rst),
        .op             (opcode), 
        .funct3         (funct3), 
        .funct7b5       (funct7b5), 
        .Zero           (Zero), 
        .CarryOut       (CarryOut), 
        .Overflow       (Overflow), 
        .Sign           (Sign), 
        .PCWrite        (PCWrite),
        .AdrSrc         (AdrSrc), 
        .MemWrite       (MemWrite), 
        .IRWrite        (IRWrite), 
        .ResultSrc      (ResultSrc), 
        .ALUControl     (ALUControl),
        .ALUSrcA        (ALUSrcA), 
        .ALUSrcB        (ALUSrcB), 
        .ImmSrc         (ImmSrc), 
        .RegWrite       (RegWrite)
    );

    datapath DP (
        .clk            (clk), 
        .rst            (rst),
        .PCWrite        (PCWrite), 
        .AdrSrc         (AdrSrc), 
        .IRWrite        (IRWrite), 
        .ResultSrc      (ResultSrc),
        .ALUControl     (ALUControl), 
        .ALUSrcA        (ALUSrcA), 
        .ALUSrcB        (ALUSrcB), 
        .ImmSrc         (ImmSrc), 
        .RegWrite       (RegWrite),
        .ReadData       (ReadData), 
        .Zero           (Zero), 
        .CarryOut       (CarryOut), 
        .Overflow       (Overflow), 
        .Sign           (Sign), 
        .Adr            (Adr),
        .WriteData      (WriteData), 
        .Instr          (Instr)
    );
endmodule
