module riscv (
    input logic clk,
    input logic rst_n,

    // memory
    input logic mem_ready,
    input logic [31:0] data_in,
    output logic [31:0] data_out,
    output logic [31:0] addr,
    output logic [3:0] write_en,
    output logic read_en,
    
    output logic [31:0] trap_pc
);

    // YOUR CODE

endmodule
