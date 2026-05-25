
// Design Module
module seq_detector (
    input clk,            // Clock signal
    input reset,          // Reset signal (Active High)
    input mode,           // 0 = Non-Overlapping, 1 = Overlapping
    input [3:0] seq_len,  // Sequence ki length (e.g., 4 bits)
    input [15:0] pattern, // Wo number jo detect karna hai
    input data_in,        // Input bits jo stream mein aa rahay hain
    output reg detect_out // Output jo 1 ho jaye ga jab match milay ga
);

    reg [15:0] shift_reg;   // Bits ko store karne ke liye
    reg [15:0] dynamic_mask; // Length ke mutabiq bits filter karne ke liye

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 16'b0;
            detect_out <= 1'b0;
        end else begin
            // 1. Shift logic: Naye bit ko shift-in karna
            shift_reg <= {shift_reg[14:0], data_in};
            
            // 2. Dynamic Mask: Jitni length hai utnay 1s generate karna
            // Example: Agar seq_len 4 hai, toh mask 0000...1111 banay ga
            dynamic_mask = (1 << seq_len) - 1;

            // 3. Comparison: Kya shift_reg ke aakhri bits pattern ke barabar hain?
            if ((({shift_reg[14:0], data_in}) & dynamic_mask) == (pattern & dynamic_mask)) begin
                detect_out <= 1'b1;
                
                // Non-Overlapping Mode Check
                if (mode == 1'b0) begin
                    shift_reg <= 16'b0; // Pattern milte hi register clear kar do
                end
            end else begin
                detect_out <= 1'b0;
            end
        end
    end
endmodule