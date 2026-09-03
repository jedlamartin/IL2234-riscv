module rf #(
    parameter int BW    = 32,
    parameter int DEPTH = 32
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic [BW-1:0]            data_in,
    output logic [BW-1:0]            data_out_1,
    output logic [BW-1:0]            data_out_2,
    input  logic [$clog2(DEPTH)-1:0] read_addr_1,
    input  logic [$clog2(DEPTH)-1:0] read_addr_2,
    input  logic [$clog2(DEPTH)-1:0] write_addr,
    input  logic                     write_en_n,
    input  logic                     chip_en
);

    // YOUR CODE

endmodule 
