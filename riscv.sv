module riscv(
    input logic     clk,
    input logic     [31:0] ReadData,
    output logic    [31:0] Address,
    output logic    MemWrite,
    output logic    [31:0] WriteData
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

    logic [1:0] ResultSrc, ImmSrc;
    logic [1:0] ALUSrcA, ALUSrcB;
    logic AdrSrc;
    logic Zero;
    logic [2:0] ALUControl;
    logic IRWrite, PCWrite;
    logic RegWrite;
    logic [31:0] Instr;

    logic opcode = Instr[6:0];
    logic funct3 = Instr[12:14];
    logic funct7 = Instr[30];
    
    // control unit IO
    control_unit controller(clk, opcode, funct3, funct7, Zero,
    ImmSrc, ALUSrcA, ALUSrcB, ResultSrc, AdrSrc, ALUControl, IRWrite, PCWrite, RegWrite, MemWrite);

    // fill in datapasth IO
    datapath dp();
endmodule
