module control_unit (
    input logic     [6:0] op,
    input logic     [2:0] funct3,
    input logic     funct7,
    input logic     Zero,
    output logic    PCSrc,
    output logic    [1:0]ResultSrc,
    output logic    MemWrite,
    output logic    [2:0]ALUControl,
    output logic    ALUSrc,
    output logic    [1:0]ImmSrc,
    output logic    RegWrite
);

    logic Branch;
    logic Jump;
    logic [1:0] ALUOp;
    logic RtypeSub;
    assign RtypeSub = funct7 & op[5];


    logic [10:0] controls;

    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;
    
    always_comb begin
        case(op)

            7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
            7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
            7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R–type
            7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
            7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I–type ALU
            7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
            default: controls = 11'bx_xx_x_x_xx_x_xx_x; // ???
        endcase

        case(ALUOp) // How does verilog check for equivalence, 1:0 or 0:1??
            2'b00: ALUControl = 3'b000;
            2'b01: ALUControl = 3'b001;
            default: begin
                case(funct3)
                    3'b000: begin
                        if (RtypeSub)
                            ALUControl = 3'b001;
                        else 
                            ALUControl = 3'b000;
                    end
                    3'b010: ALUControl = 3'b101;
                    3'b110: ALUControl = 3'b011;
                    3'b111: ALUControl = 3'b010;
                endcase
            end
        endcase
    end

    assign PCSrc = Branch & Zero | Jump;

endmodule
