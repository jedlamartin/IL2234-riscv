`timescale 1ns / 1ps

module memory_tb;

logic        clk;
logic        rst_n;
logic [31:0] addr;
logic [31:0] data_out;
logic [31:0] data_in;
logic [3:0]  write_en;
logic        read_en;
logic        mem_ready;

memory uut(
    .clk(clk),
    .rst_n(rst_n),
    .addr(addr),
    .data_out(data_out),
    .data_in(data_in),
    .write_en(write_en),
    .read_en(read_en),
    .mem_ready(mem_ready)
);

always #5 clk = ~clk;

task step_and_print();
    @(negedge clk);
    $display("[%0t] Addr: 0x%0h | read_en: %b | write_en: %b | mem_ready: %b | data_out: 0x%08h", 
             $time, addr, read_en, write_en, mem_ready, data_out);
endtask

initial begin
    clk = 0;
    rst_n = 0;
    read_en = 0;
    write_en = 0;
    addr = 0;
    data_in = '0;
    
    $display("--- Resetting ---");
    step_and_print();
    rst_n = 1;
    step_and_print();

    // ==========================================
    // Read Tests
    // ==========================================
    
    // Single Data Read (Word 0)
    $display("\n--- Single Read ---");
    read_en = 1;
    addr = 32'h0000_0000;
    step_and_print(); 
    @(posedge clk); 
    read_en = 0;
    step_and_print();
    step_and_print();
    step_and_print();

    // Triple Pipelined Read (Words 1, 2, 3)
    $display("\n--- Triple Pipelined Read ---");
    read_en = 1;
    addr = 32'h0000_0004; 
    step_and_print(); 
    
    addr = 32'h0000_0008; 
    step_and_print(); 
    
    addr = 32'h0000_000C; 
    step_and_print(); 
    @(posedge clk); 
    read_en = 0; 
    step_and_print(); 
    step_and_print(); 
    step_and_print(); 

    $display("Read tests finished.");
    
    // ==========================================
    // Write Tests
    // ==========================================

    // 3A. Full Word Write
    $display("\n--- Full Word Write (0xDEADBEEF to Addr 0x14) ---");
    addr = 32'h0000_0014;
    data_in = 32'hDEADBEEF;
    write_en = 4'b1111; // Enable all 4 bytes
    step_and_print(); 
    write_en = 4'b0000;

    // Verify Full Word Write
    $display("\n--- Verify Full Word Write ---");
    read_en = 1;
    addr = 32'h0000_0014;
    step_and_print();
    @(posedge clk);
    read_en = 0;
    step_and_print(); // Should read 0xDEADBEEF
    step_and_print();

    // Byte-wise Write
    $display("\n--- Byte-wise Write (Overwrite byte 1 with 0xAA) ---");
    addr = 32'h0000_0014;
    data_in = 32'h0000AA00; // Put data in the exact byte lane matching write_en
    write_en = 4'b0010;     // Enable ONLY byte 1 (bits 15:8)
    step_and_print(); 
    write_en = 4'b0000;

    // Verify Byte-wise Write
    $display("\n--- Verify Byte-wise Write ---");
    read_en = 1;
    addr = 32'h0000_0014;
    step_and_print();
    @(posedge clk);
    read_en = 0;
    step_and_print(); // Should read 0xDEADAAEF
    step_and_print();

    $display("\nSimulation finished.");
    $finish;
end

endmodule
