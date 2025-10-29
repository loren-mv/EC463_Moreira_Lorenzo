`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2025 11:03:38 AM
// Design Name: 
// Module Name: tb_fp32_to_posit_sync
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


module tb_convert;

 
    // --------------------------------------------
    // Parameters for DUT (Device Under Test)
    // --------------------------------------------
    parameter N  = 16;   // posit size
    parameter ES = 1;   // exponent size

    // --------------------------------------------
    // Testbench signals
    // --------------------------------------------
    reg clk;
    reg rst;
    reg [31:0] fp32_in;
    wire [N-1:0] posit_out;

    // --------------------------------------------
    // Instantiate DUT
    // --------------------------------------------
    convert #(.N(N), .ES(ES)) dut (
        .clk(clk),
        .rst(rst),
        .fp32_in(fp32_in),
        .posit_out(posit_out)
    );

    // --------------------------------------------
    // Clock generation: 10ns period (100 MHz)
    // --------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // --------------------------------------------
    // Task to apply test vectors
    // --------------------------------------------
    task convert(input [31:0] val);
        begin
            fp32_in = val;
            @(posedge clk);  // wait one clock
            #1;              // small delay for output settle
            $display("FP32 input = %h -> Posit output = %b", val, posit_out);
        end
    endtask

    // --------------------------------------------
    // Test sequence
    // --------------------------------------------
    initial begin
        $display("===============================================");
        $display("    FP32 to Posit Conversion Testbench");
        $display("===============================================");
        $display(" Time(ns) | FP32(hex) | Posit(binary)");
        $display("-----------------------------------------------");

        // Initialize
        rst = 1;
        fp32_in = 32'b0;
        repeat(2) @(posedge clk);
        rst = 0;

        // Apply a few IEEE 754 float values:
        // Format: sign exponent fraction
        convert(32'h3F800000); // 1.0
        convert(32'h40000000); // 2.0
        convert(32'h40400000); // 3.0
        convert(32'hC0000000); // -2.0
        convert(32'h3F000000); // 0.5
        convert(32'h00000000); // 0.0
        convert(32'h7F800000); // +Inf
        convert(32'hFF800000); // -Inf

        // Wait a few cycles and finish
        repeat(3) @(posedge clk);
        $display("===============================================");
        $finish;
    end
endmodule
