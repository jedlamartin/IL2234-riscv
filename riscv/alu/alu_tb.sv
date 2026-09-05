`timescale 1ns / 1ps

module alu_tb;

localparam BW = 32;

logic [BW-1:0] in_a;
logic [BW-1:0] in_b;
logic [3:0]    opcode;
logic [BW-1:0] out;
logic [2:0]    flags; // {overflow, negative, zero}

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
    
alu #(.BW(BW)) uut(
    .in_a(in_a), 
    .in_b(in_b), 
    .opcode(opcode),
    .out(out),
    .flags(flags)
);

initial begin
    $display("---------------------------------------------");
    
    // 1. ADD (0000): Normal addition
    in_a = 32'd15; in_b = 32'd25; opcode = 4'b0000; #10;
    $display("ADD (15 + 25)           -> out = %0d (exp 40), flags = %b", out, flags);
    
    // 2. ADD (0000): Positive Overflow (0x7FFFFFFF + 1)
    in_a = 32'h7FFFFFFF; in_b = 32'h00000001; opcode = 4'b0000; #10;
    $display("ADD (Overflow)          -> out = 0x%h, flags = %b (exp OF=1)", out, flags);

    // 3. SUB (0001): Normal subtraction
    in_a = 32'd50; in_b = 32'd20; opcode = 4'b0001; #10;
    $display("SUB (50 - 20)           -> out = %0d (exp 30), flags = %b", out, flags);

    // 4. SUB (0001): Zero result test (Zero flag should assert)
    in_a = 32'd100; in_b = 32'd100; opcode = 4'b0001; #10;
    $display("SUB (100 - 100)         -> out = %0d (exp 0), flags = %b (exp Zero=1)", out, flags);

    // 5. SUB (0001): Negative result (Negative flag should assert)
    in_a = 32'd10; in_b = 32'd20; opcode = 4'b0001; #10;
    $display("SUB (10 - 20)           -> out = %0d (exp -10), flags = %b (exp Neg=1)", $signed(out), flags);

    // 6. SLL (0010): Shift Left Logical
    in_a = 32'h00000001; in_b = 32'd4; opcode = 4'b0010; #10;
    $display("SLL (1 << 4)            -> out = 0x%h (exp 0x00000010)", out);

    // 7. SLT (0100): Signed comparison (-5 < 5 -> true)
    in_a = -32'd5; in_b = 32'd5; opcode = 4'b0100; #10;
    $display("SLT (-5 < 5)            -> out = %0d (exp 1)", out);

    // 8. SLTU (0110): Unsigned comparison (0xFFFFFFFF < 1 -> false)
    in_a = 32'hFFFFFFFF; in_b = 32'd1; opcode = 4'b0110; #10;
    $display("SLTU (MaxUnsigned < 1)  -> out = %0d (exp 0)", out);

    // 9. XOR (1000): Bitwise XOR
    in_a = 32'hAAAAFFFF; in_b = 32'h5555FFFF; opcode = 4'b1000; #10;
    $display("XOR                     -> out = 0x%h (exp 0xffff0000)", out);

    // 10. SRL (1010): Logical Right Shift
    in_a = 32'hF0000000; in_b = 32'd4; opcode = 4'b1010; #10;
    $display("SRL (0xF0000000 >> 4)   -> out = 0x%h (exp 0x0F000000)", out);

    // 11. SRA (1011): Arithmetic Right Shift (Preserves sign)
    in_a = 32'hF0000000; in_b = 32'd4; opcode = 4'b1011; #10;
    $display("SRA (0xF0000000 >>> 4)  -> out = 0x%h (exp 0xFF000000)", out);

    // 12. OR (1100): Bitwise OR
    in_a = 32'hF0F00000; in_b = 32'h0F0F0000; opcode = 4'b1100; #10;
    $display("OR                      -> out = 0x%h (exp 0xFFFF0000)", out);

    // 13. AND (1110): Bitwise AND
    in_a = 32'hFF00FF00; in_b = 32'hF0F0F0F0; opcode = 4'b1110; #10;
    $display("AND                     -> out = 0x%h (exp 0xF000F000)", out);

    // 14. PASS_B (1111): Pass operand B
    in_a = 32'h11111111; in_b = 32'hDEADBEEF; opcode = 4'b1111; #10;
    $display("PASS_B                  -> out = 0x%h (exp 0xDEADBEEF)", out);

    // 15. Default Opcode (Undefined code -> 0)
    in_a = 32'hFFFFFFFF; in_b = 32'hFFFFFFFF; opcode = 4'b0011; #10;
    $display("Default (unused opcode) -> out = 0x%h (exp 0x00000000)", out);

    $display("---------------------------------------------");
    $finish;
end

endmodule
