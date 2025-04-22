module main_fsm (
    input  logic        clk,
    input  logic [6:0]  op,
    output logic        branch, pcupdate, regwrite, memwrite, irwrite,
    output logic [1:0]  resultsrc,
    output logic [1:0]  alusrcb,
    output logic [1:0]  alusrca,
    output logic        adrsrc,
    output logic [1:0]  aluop
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
        s13 = 4'd13;  // error state


    logic [3:0] state, nextstate;

    always_ff @(posedge clk) begin
        state <= nextstate;
    end

    // Next‐state logic
    always_comb begin
        case (state)
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
        pcupdate  = 1'b0;
        regwrite  = 1'b0;
        memwrite  = 1'b0;
        irwrite   = 1'b0;
        resultsrc = 2'b00;
        alusrcb   = 2'b00;
        alusrca   = 2'b00;
        adrsrc    = 1'b0;
        aluop     = 2'b00;

        case (state)
            s0: begin
                pcupdate  = 1'b1;
                irwrite   = 1'b1;
                resultsrc = 2'b10;
                alusrcb   = 2'b10;
            end
            s1: begin
                alusrcb   = 2'b01;
                alusrca   = 2'b01;
            end
            s2: begin
                alusrcb   = 2'b01;
                alusrca   = 2'b10;
            end
            s3: begin
                alusrcb   = 2'b00;
                adrsrc    = 1'b1;
            end
            s4: begin
                regwrite  = 1'b1;
                resultsrc = 2'b01;
            end
            s5: begin
                memwrite  = 1'b1;
                adrsrc    = 1'b1;
            end
            s6: begin
                alusrca   = 2'b10;
                aluop     = 2'b10;
            end
            s7: begin
                regwrite  = 1'b1;
            end
            s8: begin
                alusrcb   = 2'b01;
                alusrca   = 2'b10;
                aluop     = 2'b10;
            end
            s9: begin
                pcupdate  = 1'b1;
                alusrcb   = 2'b10;
                alusrca   = 2'b01;
            end
            s10: begin
                branch    = 1'b1;
                alusrca   = 2'b10;
                aluop     = 2'b01;
            end
            s11: begin
                alusrcb   = 2'b01;
                alusrca   = 2'b01;
            end
            s12: begin
                regwrite  = 1'b1;
                resultsrc = 2'b11;
            end
            s13: begin
                // error state → X all
                branch    = 1'bx;
                pcupdate  = 1'bx;
                regwrite  = 1'bx;
                memwrite  = 1'bx;
                irwrite   = 1'bx;
                resultsrc = 2'bxx;
                alusrcb   = 2'bxx;
                alusrca   = 2'bxx;
                adrsrc    = 1'bx;
                aluop     = 2'bxx;
            end
        endcase
    end

endmodule
