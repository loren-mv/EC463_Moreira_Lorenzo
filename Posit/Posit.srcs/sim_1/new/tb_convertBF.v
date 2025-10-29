`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2025 03:12:25 PM
// Design Name: 
// Module Name: tb_convertBF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_convertBF;
 // Inputs and outputs
    reg  [31:0] fp32in;
    wire [15:0] bf16out;

    // Instantiate the DUT (Device Under Test)
    convertBF uut (
        .fp32in(fp32in),
        .bf16out(bf16out)
    );

    // Task to display results nicely
    task display_conversion;
        input [31:0] fp32;
        begin
            $display("FP32 in  = %b (%h)", fp32, fp32);
            #1; // small delay for output to settle
            $display("BF16 out = %b (%h)\n", bf16out, bf16out);
        end
    endtask

    initial begin
        $display("=====================================");
        $display(" Testbench for convertBF module ");
        $display("=====================================");

        // Test 1: +1.0 -> expected BF16 = 0x3F80
        fp32in = 32'h3F800000; 
        #5 display_conversion(fp32in);

        // Test 2: -2.0 -> expected BF16 = 0xC000
        fp32in = 32'hC0000000;
        #5 display_conversion(fp32in);

        // Test 3: +0.5 -> expected BF16 = 0x3F00
        fp32in = 32'h3F000000;
        #5 display_conversion(fp32in);

        // Test 4: +100.0 -> expected BF16 = 0x42C8
        fp32in = 32'h42C80000;
        #5 display_conversion(fp32in);

        // Test 5: Smallest positive normal number (~1.18e-38)
        fp32in = 32'h00800000;
        #5 display_conversion(fp32in);

        // Test 6: Zero
        fp32in = 32'h00000000;
        #5 display_conversion(fp32in);

        // Test 7: Negative zero
        fp32in = 32'h80000000;
        #5 display_conversion(fp32in);

        // Test 8: Positive infinity
        fp32in = 32'h7F800000;
        #5 display_conversion(fp32in);

        // Test 9: Negative infinity
        fp32in = 32'hFF800000;
        #5 display_conversion(fp32in);

        // Test 10: NaN
        fp32in = 32'h7FC00000;
        #5 display_conversion(fp32in);

        $display("=====================================");
        $display("          Testbench Complete          ");
        $display("=====================================");
        $finish;
    end

endmodule
