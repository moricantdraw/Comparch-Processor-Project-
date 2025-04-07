module control_unit (
    input logic     clk,
    input logic     [6:0] op,
    input logic     [2:0] funct3,
    input logic     funct7,
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
    
    always_ff @(posedge clk) begin
        case(op) // Unfinished
            7'b0000011: begin
                RegWrite <= 1'b1;
                ImmSrc <= 2'b00;
                ALUSrc <= 1'b1;
                MemWrite <= 1'b0;
                ResultSrc <= 2'b01;
                Branch <= 1'b0;
                ALUOp <= 2'b00;
                Jump <= 1'b0;
            end
        endcase

        case(ALUOp) // How does verilog check for equivalence, 1:0 or 0:1??
            2'b00: ALUControl = 3'b000;
            2'b01: ALUControl = 3'b001;
            2'b10: begin
                case(funct3)
                    3'b000: begin
                        if (funct7 != 2'b11) begin
                            ALUControl = 3'b000;
                        end
                        else begin
                            ALUControl = 3'b001;
                        end
                    end
                    3'b010: ALUControl = 3'b101;
                    3'b110: ALUControl = 3'b011;
                    3'b111: ALUControl = 3'b010;
                endcase
            end
        endcase
    end

endmodule
