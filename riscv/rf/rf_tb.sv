`timescale 1ns / 1ps

module rf_tb;

localparam BW = 32;
localparam DEPTH = 32;

logic                     clk;
logic                     rst_n;
logic [BW-1:0]            data_in;
logic [BW-1:0]            data_out_1;
logic [BW-1:0]            data_out_2;
logic [$clog2(DEPTH)-1:0] read_addr_1;
logic [$clog2(DEPTH)-1:0] read_addr_2;
logic [$clog2(DEPTH)-1:0] write_addr;
logic                     write_en_n;
logic                     chip_en;

rf #(.BW(BW), .DEPTH(DEPTH)) uut (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .data_out_1(data_out_1),
    .data_out_2(data_out_2),
    .read_addr_1(read_addr_1),
    .read_addr_2(read_addr_2),
    .write_addr(write_addr),
    .write_en_n(write_en_n),
    .chip_en(chip_en)
);

always #5 clk = ~clk;

task print_rf_contents();
    $display("\n--- Current Register File Contents ---");
    for(int i = 0; i < DEPTH; i++) begin
        $display("Reg[%2d] = 0x%h", i, uut.mem[i]);
    end
    $display("--------------------------------------\n");
endtask

initial begin
    // Initialize Signals
    clk          = 0;
    rst_n        = 0;
    chip_en      = 0;
    write_en_n   = 1;
    write_addr   = '0;
    read_addr_1  = '0;
    read_addr_2  = '0;
    data_in      = '0;

    // 1. Reset Test
    $display("[TEST 1] Applying Asynchronous Reset...");
    #15;
    rst_n = 1;
    @(negedge clk);
    print_rf_contents();

    // 2. Hardwired Zero Write Test
    $display("[TEST 2] Attempting write to Register 0 (Hardwired Zero)...");
    chip_en    = 1;
    write_en_n = 0;
    write_addr = 0;
    data_in    = 32'hDEADBEEF;
    @(negedge clk);
    write_en_n = 1;

    // 3. Randomized Write Operations
    $display("[TEST 3] Performing Randomized Writes...");
    chip_en    = 1;
    write_en_n = 0;
    for (int i = 1; i < DEPTH; i++) begin
        @(negedge clk);
        write_addr = i;
        data_in    = $urandom();
    end
    @(negedge clk);
    write_en_n = 1;
    print_rf_contents();

    // 4. Randomized Read Operations
    $display("[TEST 4] Performing Randomized Read Operations...");
    for (int k = 0; k < 10; k++) begin
        @(negedge clk);
        read_addr_1 = $urandom_range(0, DEPTH-1);
        read_addr_2 = $urandom_range(0, DEPTH-1);
        @(posedge clk);
        #1;
        $display("READ -> Addr1: %2d | Out1: 0x%h || Addr2: %2d | Out2: 0x%h", 
                 read_addr_1, data_out_1, read_addr_2, data_out_2);
    end

    // 5. Standby Mode Test
    $display("\n[TEST 5] Testing Standby Mode (chip_en = 0)...");
    @(negedge clk);
    chip_en = 0;
    @(posedge clk);
    #1;
    $display("STANDBY -> Out1: 0x%h | Out2: 0x%h (Expected: 0x0)", data_out_1, data_out_2);

    $display("\n=== Testbench Completed Successfully ===");
    $finish;
end

endmodule