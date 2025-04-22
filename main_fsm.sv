module main_fsm (
    input  logic        clk, rst, 
    input  logic [6:0]  op,
    output logic        branch, PCUpdate, 
    output logic        RegWrite, MemWrite, IRWrite,
    output logic [1:0]  ResultSrc,
    output logic [1:0]  ALUSrcB,
    output logic [1:0]  ALUSrcA,
    output logic        AdrSrc,
    output logic [1:0]  ALUOp
);
    // States
    localparam logic [3:0]
        s0  = 4'd0,
        s1  = 4'd1,
        s2  = 4'd2,
        s3  = 4'd3,
        s4  = 4'd4,
        s5  = 4'd5,
        s6  = 4'd6,
        s7  = 4'd7,
        s8  = 4'd8,
        s9  = 4'd9,
        s10 = 4'd10,
        s11 = 4'd11,
        s12 = 4'd12,
        s13 = 4'd13,  // error state
        s14 = 4'd14;  // new wait state (reset delay)


    logic [3:0] state, nextstate;

	always_ff @(posedge clk, posedge rst) begin
		if(rst)
			state <= s0;
		else
			state <= nextstate;
        // if (rst)
		// 	state <= s14; // Start in wait state after reset
		// else
		// 	state <= nextstate;
	end

    // Next‐state logic
    always_comb begin
        case (state)
            s14: nextstate = s0; // single-cycle delay after reset
            s0:  nextstate = s1;
            s1:  // decode and dispatch
                case (op)
                    7'b0110011: nextstate = s6;   // R‑type
                    7'b0010011: nextstate = s8;   // I‑arith
                    7'b0000011: nextstate = s2;   // load
                    7'b0100011: nextstate = s2;   // store
                    7'b1100011: nextstate = s10;  // branch
                    7'b1101111: nextstate = s9;   // jal
                    7'b0010111: nextstate = s11;  // auipc
                    7'b0110111: nextstate = s12;  // lui
                    7'b1100111: nextstate = s2;   // jalr (treat like load for addr calc)
                    default:    nextstate = s13;
                endcase
            s2:  // address calculation or JALR
                if (op[5]) begin
                    if (op[6])
                        nextstate = s9;  // JAL
                    else
                        nextstate = s5;  // store
                end else
                    nextstate = s3;      // load
            s3:  nextstate = s4;  // memory access (load)
            s4:  nextstate = s0;  // write‐back (load)
            s5:  nextstate = s0;  // complete store
            s6:  nextstate = s7;  // execute R‑type
            s7:  nextstate = s0;  // write‐back R/I‑arith
            s8:  nextstate = s7;  // execute I‑arith
            s9:  nextstate = s7;  // write‐back jal
            s10: nextstate = s0;  // branch decision
            s11: nextstate = s7;  // write‐back auipc
            s12: nextstate = s0;  // write‐back lui
            s13: nextstate = s13; // error
            default: nextstate = s13;
        endcase
    end

    always_comb begin
        // defaults
        branch    = 1'b0;
        PCUpdate  = 1'b0;
        RegWrite  = 1'b0;
        MemWrite  = 1'b0;
        IRWrite   = 1'b0;
        ResultSrc = 2'b00;
        ALUSrcB   = 2'b00;
        ALUSrcA   = 2'b00;
        AdrSrc    = 1'b0;
        ALUOp     = 2'b00;

        case (state)
            s0: begin
                PCUpdate  = 1'b1;
                IRWrite   = 1'b1;
                ResultSrc = 2'b10;
                ALUSrcB   = 2'b10;
            end
            s1: begin
                ALUSrcB   = 2'b01;
                ALUSrcA   = 2'b01;
            end
            s2: begin
                ALUSrcB   = 2'b01;
                ALUSrcA   = 2'b10;
            end
            s3: begin
                ALUSrcB   = 2'b00;
                AdrSrc    = 1'b1;
            end
            s4: begin
                RegWrite  = 1'b1;
                ResultSrc = 2'b01;
            end
            s5: begin
                MemWrite  = 1'b1;
                AdrSrc    = 1'b1;
            end
            s6: begin
                ALUSrcA   = 2'b10;
                ALUOp     = 2'b10;
            end
            s7: begin
                RegWrite  = 1'b1;
            end
            s8: begin
                ALUSrcB   = 2'b01;
                ALUSrcA   = 2'b10;
                ALUOp     = 2'b10;
            end
            s9: begin
                PCUpdate  = 1'b1;
                ALUSrcB   = 2'b10;
                ALUSrcA   = 2'b01;
            end
            s10: begin
                branch    = 1'b1;
                ALUSrcA   = 2'b10;
                ALUOp     = 2'b01;
            end
            s11: begin
                ALUSrcB   = 2'b01;
                ALUSrcA   = 2'b01;
            end
            s12: begin
                RegWrite  = 1'b1;
                ResultSrc = 2'b11;
            end
            s13: begin
                // error state → X all
                branch    = 1'bx;
                PCUpdate  = 1'bx;
                RegWrite  = 1'bx;
                MemWrite  = 1'bx;
                IRWrite   = 1'bx;
                ResultSrc = 2'bxx;
                ALUSrcB   = 2'bxx;
                ALUSrcA   = 2'bxx;
                AdrSrc    = 1'bx;
                ALUOp     = 2'bxx;
            end
            s14: begin
                // Wait one cycle after reset: all signals default (no IRWrite or PCUpdate)
                IRWrite = 1'b1;
            end
        endcase
    end

endmodule
