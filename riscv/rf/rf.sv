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

logic [BW-1:0] mem [DEPTH];

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for(int i = 0; i < DEPTH; i++) begin
            mem[i] <= '0;
        end
        data_out_1 <= '0;
        data_out_2 <= '0;
    end else if (!chip_en) begin
        data_out_1 <= '0;
        data_out_2 <= '0;
    end else begin
        if (!write_en_n & write_addr != '0) begin
            mem[write_addr] <= data_in;
        end
        data_out_1 <= (read_addr_1 == '0) ? '0 : mem[read_addr_1];
        data_out_2 <= (read_addr_2 == '0) ? '0 : mem[read_addr_2];
    end
end

endmodule 
