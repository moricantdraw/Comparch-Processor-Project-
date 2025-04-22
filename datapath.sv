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

    output logic    Zero, CarryOut, Overflow, Sign, 
    output logic    [31:0] Adr,        // Instruction address (to instruction memory)
    output logic    [31:0] WriteData,  // Data from reg file (to memory)
    output logic    [31:0] Instr     // Fetched instruction from intermediate register (to control unit)
    // output logic    [31:0] ALUResult,  // Memory address (to data memory) 
);

    // Internal Signals 
    logic [31:0] Result , ALUOut, ALUResult;
    logic [31:0] RD1, RD2, A, SrcA, SrcB, Data;
    logic [31:0] ImmExt;
    logic [31:0] PC, OldPC;

    // nonarchitectural program counter 
    nareg_PC #(32) PC_reg(.clk(clk), .PCNext(Result), .PCWrite(PCWrite), .PC(PC));

     // memory peripherals (actual memory module in top module)
    mux_Adr mux_Address(.PC(PC), .Result(Result), .AdrSrc(AdrSrc), .Adr(Adr));
    nareg_Instr nonarchreg_Instr(.clk(clk), .RD(ReadData), .PC(PC), .IRWrite(IRWrite), .Instr(Instr), .OldPC(OldPC));
    nareg_Data nonarchreg_data(.clk(clk), .ReadData(ReadData), .Data(Data));

    // register file and nonarchitectural register
    register_file rf (
        .clk(clk),
        .a1(instr[19:15]),   // rs1
        .a2(instr[24:20]),   // rs2
        .a3(instr[11:7]),    // rd
        .we3(RegWrite),
        .wd3(Result),        // data to write back
        .rd1(rd1),
        .rd2(rd2)
    );
    nareg_WriteData nonarchreg_WriteData(.clk(clk), .RD1(RD1), .RD2(RD2), .A(A), .WriteData(WriteData));

    // extend unit
    Extend extend(.Instr(Instr[31:7]), .ImmSrc(ImmSrc), .ImmExt(ImmExt));

    // ALU 
    mux_SrcA mux_SrcA(.PC(PC), .OldPC(OldPC), .A(A), .ALUSrcA(ALUSrcA), .SrcA(SrcA));
    mux_SrcB mux_SrcB(.WriteData(WriteData), .ImmExt(ImmExt), .ALUSrcB(ALUSrcB), .SrcB(SrcB));
    ALU alu(.SrcA(SrcA), .SrcB(SrcB), .ALUControl(ALUControl), .ALUResult(ALUResult), .Zero(Zero), cout, overflow, sign);
    flopr #(32) aluReg (clk, reset, ALUResult, ALUOut);
    mux4 #(32) resultMux(ALUOut, Data, ALUResult, ImmExt, ResultSrc, Result );


    // Register File
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

// logic [31:0] Result , ALUOut, ALUResult;
// logic [31:0] RD1, RD2, A , SrcA, SrcB, Data;
// logic [31:0] ImmExt;
// logic [31:0] PC, OldPC;


// //pc
// flopenr #(32) pcFlop(clk, reset, PCWrite, Result, PC);


// //regFile
// regFile rf(clk, RegWrite, instr[19:15], instr[24:20], instr[11:7], Result, RD1, RD2); 
// extend ext(instr[31:7], ImmSrc, ImmExt);
// flopr #(32) regF( clk, reset, RD1, A);
// flopr #(32) regF_2( clk, reset, RD2, WriteData);


// //alu
// mux3 #(32) srcAmux(PC, OldPC, A, ALUSrcA, SrcA);
// mux3 #(32) srcBmux(WriteData, ImmExt, 32'd4, ALUSrcB, SrcB);
// alu alu(SrcA, SrcB, ALUControl, ALUResult, Zero, cout, overflow, sign);
// flopr #(32) aluReg (clk, reset, ALUResult, ALUOut);
// mux4 #(32) resultMux(ALUOut, Data, ALUResult, ImmExt, ResultSrc, Result );

// //mem
// mux2 #(32) adrMux(PC, Result, AdrSrc, Adr);
// flopenr #(32) memFlop1(clk, reset, IRWrite, PC, OldPC); 
// flopenr #(32) memFlop2(clk, reset, IRWrite, ReadData, instr);
// flopr #(32) memDataFlop(clk, reset, ReadData, Data);


