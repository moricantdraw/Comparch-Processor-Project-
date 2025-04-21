module dataPath (
    input logic     clk,
    input logic     PCWrite,
    input logic     AdrSrc,
    // input logic     MemWrite, don't need cuz goes to memory module
    input logic     IRWrite,
    input logic     [1:0] ResultSrc,
    input logic     [3:0] ALUControl,
    input logic     [1:0] ALUSrcA, ALUSrcB,
    input logic     [2:0] ImmSrc,
    input logic     RegWrite,
    input logic     [31:0] ReadData, // from memory module

    output logic    Zero, 
    output logic    [31:0] Adr,        // Instruction address (to instruction memory)
    output logic    [31:0] WriteData,  // Data from reg file (to memory)
    output logic    [31:0] Instr     // Fetched instruction from intermediate register (to control unit)
    // output logic    [31:0] ALUResult,  // Memory address (to data memory) 
);

    //Internal Signals 
    logic [31:0] ImmExt;
    logic [31:0] PCNext, PCPlus4, PCTarget;
    logic [31:0] rd1, rd2, SrcB;
    logic [31:0] Result;

    // Program Counter
    flopr #(32) pcReg (
        .clk(clk), .reset(reset), .d(PCNext), .q(pc)
    );

    adder pc_adder (
        .a(PC), .b(32'd4), .y(PCPlus4)
    );

    adder branch_adder (
        .a(PC), .b(ImmExt), .y(PCTarget)
    );

    // Select next PC based on PCSrc
    assign PCNext = PCSrc ? PCTarget : PCPlus4;

    // Instruction to Memory  
    assign instr = ReadData;

    // Register File 
    regFile rf (
        .clk(clk),
        .we3(RegWrite),
        .a1(instr[19:15]),   // rs1
        .a2(instr[24:20]),   // rs2
        .a3(instr[11:7]),    // rd
        .wd3(Result),        // data to write back
        .rd1(rd1),
        .rd2(rd2)
    );

    assign WriteData = rd2;

    // Immediate Generator 
    extend ext (
        .instr(instr[31:7]),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );

    // ALU Input Selection 
    assign SrcB = ALUSrc ? ImmExt : rd2;

    // ALU 
    alu alu_unit (
        .a(rd1),
        .b(SrcB),
        .aluControl(ALUControl),
        .result(ALUResult),
    );

    // Result Mux
    always_comb begin
        case (ResultSrc)
            2'b00: Result = ALUResult;
            2'b01: Result = ReadData;
            2'b10: Result = ImmExt;
            default: Result = 32'bx;
        endcase
    end

endmodule
