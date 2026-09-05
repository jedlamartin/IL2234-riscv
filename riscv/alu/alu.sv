module alu #(
    parameter BW = 32
) (
    input  logic [BW-1:0]  in_a,
    input  logic [BW-1:0]  in_b,
    input  logic [3:0]     opcode,
    output logic [BW-1:0]  out,
    output logic [2:0]     flags // {overflow, negative, zero}
);

typedef enum logic [3:0] {
    ADD    = 4'b0000,
    SUB    = 4'b0001,
    SLL    = 4'b0010,
    SLT    = 4'b0100,
    SLTU   = 4'b0110,
    XOR    = 4'b1000,
    SRL    = 4'b1010,
    SRA    = 4'b1011,
    OR     = 4'b1100,
    AND    = 4'b1110,
    PASS_B = 4'b1111
} alu_op_t;

logic [$clog2(BW)-1:0] shamt;
logic overflow, negative, zero;

assign shamt = in_b[$clog2(BW)-1:0];
assign zero = out == 0;
assign negative = out[BW-1];
assign flags = {overflow, negative, zero};


always_comb begin
    overflow = 0;
    case (opcode)
        ADD: begin 
            out = in_a + in_b;
            overflow = (in_a[BW-1] & in_b[BW-1] & !out[BW-1]) | (!in_a[BW-1] & !in_b[BW-1] & out[BW-1]);
        end
        SUB: begin 
            out = in_a - in_b;
            overflow = (in_a[BW-1] & !in_b[BW-1] & !out[BW-1]) | (!in_a[BW-1] & in_b[BW-1] & out[BW-1]);
        end
        
        SLL: out = in_a << shamt;
        SRL: out = in_a >> shamt;
        SRA: out = $signed(in_a) >>> shamt;
        
        SLT: out = ($signed(in_a) < $signed(in_b)) ? {{(BW-1){1'b0}}, 1'b1} : '0;
        SLTU: out = (in_a < in_b) ? {{(BW-1){1'b0}}, 1'b1} : '0;

        XOR: out = in_a ^ in_b;
        OR: out = in_a | in_b;
        AND: out = in_a & in_b;
        
        PASS_B: out = in_b;
        
        default: out = 0;

    endcase
end

endmodule
