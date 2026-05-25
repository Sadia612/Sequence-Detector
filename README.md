# Sequence-Detector
Designed and implemented a configurable sequence detector using Verilog HDL on Intel FPGA. The system supports both overlapping and non-overlapping sequence detection modes with dynamic sequence length handling.
**Features**
Verilog HDL based design
Intel FPGA implementation
Overlapping sequence detection
Non-overlapping sequence detection
Dynamic sequence length support
Shift register based detection
Real-time bit stream processing
**Technologies Used**
Verilog HDL
Intel FPGA
**How It Works**
Input bits are continuously shifted into a shift register.
The detector compares incoming bit patterns with the target sequence.
When the sequence matches, detect_out becomes HIGH.
**Supports:**
Overlapping mode
Non-overlapping mode
