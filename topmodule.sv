/*

The updates are that I didn't pull until quite 
late so this isn't compatable with the rest of the processor 
-- it's just using a lot of place holders. 
*/

module top(input logic clk, reset);


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
					  input logic IRWrite,
					  input logic RegWrite,
					  input logic [1:0] ALUSrcA, ALUSrcB, 
					  input logic AdrSrc, 
					  input logic PCWrite,  
					  input logic [31:0] ReadData,
					  output logic Zero, cout, overflow, sign, 
					  output logic [31:0] Adr, 
					  output logic [31:0] WriteData,
					  output logic [31:0] instr);

		 
logic [31:0] Result , ALUOut, ALUResult;
logic [31:0] RD1, RD2, A , SrcA, SrcB, Data;
logic [31:0] ImmExt;
logic [31:0] PC, OldPC;


//pc
flopenr #(32) pcFlop(clk, reset, PCWrite, Result, PC);


//regFile
regFile rf(clk, RegWrite, instr[19:15], instr[24:20], instr[11:7], Result, RD1, RD2); 
extend ext(instr[31:7], ImmSrc, ImmExt);
flopr #(32) regF( clk, reset, RD1, A);
flopr #(32) regF_2( clk, reset, RD2, WriteData);


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


/* do we need anything for the memory 
    // === Memory (both instruction + data) ===
    memory mem(
        .clk(clk),
        .we(MemWrite),
        .a(DataAdr),
        .wd(WriteData),
        .rd(ReadData)
    );
*/
endmodule
