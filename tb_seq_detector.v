// --- DESIGN MODULE ---
module seq_detector (
    input clk,            // Clock signal
    input reset,          // Reset signal (Active High)
    input mode,           // 0 = Non-Overlapping, 1 = Overlapping
    input [3:0] seq_len,  // Sequence ki length
    input [15:0] pattern, // Wo number jo detect karna hai
    input data_in,        // Input bits
    output reg detect_out // Output 1 when match found
);

    reg [15:0] shift_reg;   
    reg [15:0] dynamic_mask; 

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 16'b0;
            detect_out <= 1'b0;
        end else begin
            // Shift logic
            shift_reg <= {shift_reg[14:0], data_in};
            
            // Dynamic Mask logic
            dynamic_mask = (1 << seq_len) - 1;

            // Comparison
            if ((({shift_reg[14:0], data_in}) & dynamic_mask) == (pattern & dynamic_mask)) begin
                detect_out <= 1'b1;
                if (mode == 1'b0) begin
                    shift_reg <= 16'b0; // Non-Overlapping: Clear register
                end
            end else begin
                detect_out <= 1'b0;
            end
        end
    end
endmodule

// --- TESTBENCH ---
`timescale 1ns/1ps

module tb_seq_detector();
    reg clk, reset, mode, data_in;
    reg [3:0] seq_len;
    reg [15:0] pattern;
    wire detect_out;

    // Unit Under Test (UUT)
    seq_detector uut (
        .clk(clk), .reset(reset), .mode(mode), 
        .seq_len(seq_len), .pattern(pattern), 
        .data_in(data_in), .detect_out(detect_out)
    );

    // Clock Generation
    always #5 clk = ~clk;

    initial begin
        // --- 1. Initialization ---
        clk = 0; reset = 1; data_in = 0;
        #15 reset = 0;

        // --- USE CASE 1: Non-Overlapping (Header Detection) ---
        // Pattern: 1101 in stream 1101_1101 (Should detect separately)
        mode = 0; seq_len = 4; pattern = 16'b1101;
        #10 data_in = 1; #10 data_in = 1; #10 data_in = 0; #10 data_in = 1; 
        #10 data_in = 1; #10 data_in = 1; #10 data_in = 0; #10 data_in = 1; 
        #20;

        // --- USE CASE 2: Overlapping (Stream Monitoring) ---
        // Pattern: 101 in stream 10101 (Should detect TWICE)
        reset = 1; #10 reset = 0;
        mode = 1; seq_len = 3; pattern = 16'b101;
        #10 data_in = 1; #10 data_in = 0; #10 data_in = 1; // 1st Match
        #10 data_in = 0; #10 data_in = 1;                 // 2nd Match (Overlap)
        #20;

        // --- USE CASE 3: Dynamic Trigger (Short Signal) ---
        // Pattern: 11 (Sirf 2 bits ka trigger)
        reset = 1; #10 reset = 0;
        mode = 0; seq_len = 2; pattern = 16'b11;
        #10 data_in = 0; #10 data_in = 1; #10 data_in = 1; // Quick Match
        #20;

        $display("Simulation Done!");
        $stop;
    end
endmodule
