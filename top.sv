`include "riscv.sv"
`include "memory.sv"

module top(
    input logic clk, rst,
    output logic [31:0] WriteData, Adr,
    output logic MemWrite
    
);
    logic [31:0] ReadData;
    logic [2:0] funct3, memory_funct3; // i hope this is right for shared funct3
    assign memory_funct3 = 3'b010;
    
    riscv rv_multi (
        .clk            (clk), 
        .rst            (rst),
        .ReadData       (ReadData), 
        .Adr            (Adr), 
        .MemWrite       (MemWrite), 
        .WriteData      (WriteData), 
        .funct3         (funct3)
    );
    memory #(
        .INIT_FILE      ("rv32i_test.txt")
    ) memory (
        .clk            (clk), 
        .write_mem      (MemWrite), 
        .funct3         (memory_funct3), 
        .write_address  (Adr), 
        .write_data     (WriteData),
        .read_address   (Adr), 
        .read_data      (ReadData)
    );

    // memory module IO
    // input logic     clk, --- check
    // input logic     write_mem, --- check
    // input logic     [2:0] funct3, --- // Instr[14:12]...? --> expose funct3
    // input logic     [31:0] write_address, --- Adr from mux selection
    // input logic     [31:0] write_data, --- check
    // input logic     [31:0] read_address, --- Adr from mux selection
    // output logic    [31:0] read_data, --- check
endmodule
