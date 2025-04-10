/*

The updates are that I didn't pull until quite 
late so this isn't compatable with the rest of the processor 
-- it's just using a lot of place holders. 
*/

module riscv(input logic clk, reset);


    // Data memory 
    logic [31:0] WriteData, DataAdr, ReadData;

    // Instruction and control 
    logic [31:0] instr;

    logic        PCSrc;
    logic [1:0]  ResultSrc;
    logic        MemWrite;
    logic [2:0]  ALUControl;
    logic        ALUSrc;
    logic [1:0]  ImmSrc;
    logic        RegWrite;

    // referncing the control unit 
    control_unit cu(
        .clk(clk),
        .reset(reset),
        .op(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7(instr[31:25]),
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUControl(ALUControl),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite)
    );

    /*Datapath 
    I think that the best way to do this is to just shove 
    the entire data path in here. This isn't in the right order yet 
    because I was refercing some australians online. 
    */
    dataPath dp(
        input logic clk, reset,
					  input logic [2:0] ImmSrc, 
					  input logic [3:0] ALUControl, 
					  input logic [1:0] ResultSrc, 
					  input logic RegWrite,
					  input logic [1:0] ALUSrcA, ALUSrcB, 
					  input logic AdrSrc, 
					  input logic PCWrite,  
					  input logic [31:0] ReadData,
					  output logic [31:0] ALUResult, WriteData,
					  input logic [31:0] instr;
                      output logic [31:0] PC );
                      output logic []

		 
logic [31:0] Result;
logic [31:0] SrcA, SrcB;
logic [31:0] ImmExt;
logic [31:0] PCNext, PCPlus4, PCTarget;


//pc
flopr#(32) pcreg(clk, reset, PCNext, PC);
adder   pcadd4(PC, 32'd4, PCPlus4);
adder   pcaddbranch (PC, ImmExt, PCTarget)
flopenr #(32) pcFlop(clk, reset, PCWrite, Result, PC);


//regFile
regFile rf(clk, RegWrite, instr[19:15], instr[24:20], instr[11:7], Result, SrcA, WriteData); 
extend ext(instr[31:7], ImmSrc, ImmExt);

//alu
mux3 #(32) srcAmux(PC, OldPC, A, ALUSrcA, SrcA);
mux3 #(32) srcBmux(WriteData, ImmExt, 32'd4, ALUSrcB, SrcB);
alu alu(SrcA, SrcB, ALUControl, ALUResult, Zero, cout, overflow, sign);
flopr #(32) aluReg (clk, reset, ALUResult, ALUOut);
mux4 #(32) resultMux(ALUOut, Data, ALUResult, ImmExt, ResultSrc, Result );

//mem
mux2 #(32) adrMux(PC, Result, AdrSrc, Adr);
flopenr #(32) memFlop1(clk, reset, IRWrite, PC, OldPC); 
flopenr #(32) memFlop2(clk, reset, IRWrite, ReadData, instr);
flopr #(32) memDataFlop(clk, reset, ReadData, Data);


endmodule
