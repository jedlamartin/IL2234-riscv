module alu_top(
    input logic CLK_100MHZ,

    input logic [15:0] SW, // On-board Slide Switches
    input logic [3:0]  BTN, // On-board Buttons

    
    output logic [15:0] LED, // On-board LEDs
    
    // On-board 7-Segment display 0
    output logic [3:0] D0_AN,
    output logic [7:0] D0_SEG,
    
    // On-board 7-Segment display 1
    output logic [3:0] D1_AN,
    output logic [7:0] D1_SEG
);

logic clk, btn;
assign clk = CLK_100MHZ;
assign btn = BTN[0];

// Reset
logic eos;
logic rst;
assign rst = !eos;

STARTUPE2 #(
   .PROG_USR("FALSE"),  // Activate program event security feature. Requires encrypted bitstreams.
   .SIM_CCLK_FREQ(0.0)  // Set the Configuration Clock Frequency(ns) for simulation.
)
STARTUPE2_inst (
   .CFGCLK(),        // 1-bit output: Configuration main clock output
   .CFGMCLK(),       // 1-bit output: Configuration internal oscillator clock output
   .EOS(eos),        // 1-bit output: Active high output signal indicating the End Of Startup.
   .PREQ(),          // 1-bit output: PROGRAM request to fabric output
   .CLK(1'b0),       // 1-bit input: User start-up clock input
   .GSR(1'b0),       // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
   .GTS(1'b0),       // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
   .KEYCLEARB(1'b0), // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
   .PACK(1'b0),      // 1-bit input: PROGRAM acknowledge input
   .USRCCLKO(1'b0),  // 1-bit input: User CCLK input
                     // For Zynq-7000 devices, this input must be tied to GND
   .USRCCLKTS(1'b0), // 1-bit input: User CCLK 3-state enable input
                     // For Zynq-7000 devices, this input must be tied to VCC
   .USRDONEO(1'b1),  // 1-bit input: User DONE pin output control
   .USRDONETS(1'b0)  // 1-bit input: User DONE 3-state enable output
);

// Alias for LED
logic [15:0] led;
assign LED = led; 

// Edge detection for BTN[0]
logic [2:0] btn_shr;
logic en;

always_ff @(posedge clk) begin
    if (rst) begin
        btn_shr <= 3'b000;
    end else begin
        btn_shr <= {btn_shr[1:0], btn};
    end
end

assign en = btn_shr[2] & !btn_shr[1];



localparam BW = 16;
logic [BW-1:0] alu_in_a;
logic [BW-1:0] alu_in_b;
logic [3:0] alu_opcode;
logic [BW-1:0] alu_out;
logic [2:0] alu_flags;

alu #(.BW(BW)) alu_i(
    .in_a(alu_in_a),
    .in_b(alu_in_b),
    .opcode(alu_opcode),
    .out(alu_out),
    .flags(alu_flags)
);



typedef enum logic [1:0] {
    OP1 = 2'd0,
    OP2 = 2'd1,
    OPC = 2'd2,
    RES = 2'd3
} state_e;

state_e state, next_state;

// State update
always_ff @(posedge clk) begin
    if (rst) begin
        state <= OP1;
    end else if (en) begin
        state <= next_state;
    end
end

// Next state logic
always_comb begin
    case (state)
        OP1: next_state = OP2;
        OP2: next_state = OPC;
        OPC: next_state = RES;
        default: next_state = OP1;
    endcase
end



logic [BW-1:0] seg_data_l;
logic [BW-1:0] seg_data_r;

// Output logic
always_comb begin
    case(state)
        OP1: begin
            seg_data_l = '0;
            seg_data_r = SW;
            led = SW;
        end
        OP2: begin
            seg_data_l = SW;
            seg_data_r = alu_in_a;
            led = SW;
        end
        OPC: begin
            seg_data_l = alu_in_b;
            seg_data_r = alu_in_a;
            led = {12'b0, SW[3:0]};
        end
        RES: begin
            seg_data_r = alu_out;
            seg_data_l = '0;
            led = {13'd0, alu_flags};
        end
        default: begin
            seg_data_l = '0;
            seg_data_r = '0;
            led = '0;
        end
    endcase
end

// Input logic for the ALU
always_ff @(posedge clk) begin
    if(rst) begin
        alu_in_a <= '0;
        alu_in_b <= '0;
        alu_opcode <= '0;
    end else if (en) begin
        case (state)
            OP1: begin
                alu_in_a <= SW;
            end
            OP2: begin
                alu_in_b <= SW;
            end
            OPC: begin
                alu_opcode <= SW[3:0];
            end
            default: ;
        endcase
    end
end

logic is_signed;
assign is_signed = BTN[1]; 

logic [15:0] disp_data_l, disp_data_r;
logic [3:0]  dots_l, dots_r;

// Left Display Formatter
always_comb begin
    if (is_signed && seg_data_l[15]) begin
        disp_data_l = -seg_data_l;
        dots_l = 4'b0111;
    end else begin
        disp_data_l = seg_data_l;
        dots_l = 4'b1111;
    end
end

// Right Display Formatter
always_comb begin
    if (is_signed && seg_data_r[15]) begin
        disp_data_r = -seg_data_r;
        dots_r = 4'b0111;
    end else begin
        disp_data_r = seg_data_r;
        dots_r = 4'b1111;
    end
end

kw4281_driver driver_left (
    .rst_n(~rst),
    .clk(CLK_100MHZ), 
    .input_bcd(disp_data_l), 
    .input_dots(dots_l),
    .an(D0_AN), 
    .seg(D0_SEG)
);

kw4281_driver driver_right (
    .rst_n(~rst), 
    .clk(CLK_100MHZ), 
    .input_bcd(disp_data_r), 
    .input_dots(dots_r),
    .an(D1_AN), 
    .seg(D1_SEG)
);

endmodule
