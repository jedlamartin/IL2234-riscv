module memory (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] addr,
    output logic [31:0] data_out,
    input  logic [31:0] data_in,
    input  logic [3:0]  write_en,
    input  logic        read_en,
    output logic        mem_ready
);

logic sram_en;
assign sram_en = read_en | (|write_en);

data_sram data_sram_i (
  .clka(clk),        // input wire clka
  .ena(sram_en),      // input wire ena
  .wea(write_en),     // input wire [3 : 0] wea
  .addra(addr[15:2]), // input wire [13 : 0] addra
  .dina(data_in),     // input wire [31 : 0] dina
  .douta(data_out)    // output wire [31 : 0] douta
);

typedef enum logic [1:0] {
    IDLE = 2'b00,
    WAIT_RD = 2'b01,
    READY_RD = 2'b10,
    READY_WR = 2'b11
} state_t; 

state_t state, next_state;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= IDLE;
    else state <= next_state;
end

always_comb begin
    case (state)
        IDLE: begin
            if(read_en)
                next_state = WAIT_RD;
             else if(|write_en)
                next_state = READY_WR;
             else
                next_state = IDLE;
        end
        WAIT_RD: begin
             if(read_en)
                next_state = READY_RD;
             else if(|write_en)
                next_state = READY_WR;
             else
                next_state = IDLE;
        end
        READY_RD: begin
             if(read_en)
                next_state = READY_RD;
             else if(|write_en)
                next_state = READY_WR;
             else
                next_state = IDLE;
        end
        READY_WR: begin
             if(|write_en)
                next_state = READY_WR;
             else if(read_en)
                next_state = WAIT_RD;
             else
                next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end

assign mem_ready = (state == READY_RD) | (state == READY_WR);


endmodule