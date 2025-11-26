`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 12:09:48 PM
// Design Name: 
// Module Name: tb_complex_fpmult
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


module tb_complex_fpmult;
// Clock and handshake
    reg clk;
    reg valid_in;

    // Inputs to DUT
    reg  [31:0] re_in1, im_in1;
    reg  [31:0] re_in2, im_in2;

    // Outputs from DUT
    wire [31:0] re_out, im_out;
    wire        valid_out;

    // Instantiate DUT
    complex_fpmult dut (
        .clk      (clk),
        .valid_in (valid_in),
        .re_in1   (re_in1),
        .im_in1   (im_in1),
        .re_in2   (re_in2),
        .im_in2   (im_in2),
        .re_out   (re_out),
        .im_out   (im_out),
        .valid_out(valid_out)
    );

    // -----------------------------------
    // Clock generation (100 MHz example)
    // -----------------------------------
    initial clk = 0;
    always #5 clk = ~clk;   // 10 ns period

    // -----------------------------------
    // FP32 helper constants (IEEE-754)
    // -----------------------------------
    localparam [31:0] FP_ZERO = 32'h00000000; // 0.0
    localparam [31:0] FP_1    = 32'h3F800000; // 1.0
    localparam [31:0] FP_2    = 32'h40000000; // 2.0
    localparam [31:0] FP_3    = 32'h40400000; // 3.0
    localparam [31:0] FP_4    = 32'h40800000; // 4.0
    localparam [31:0] FP_N1   = 32'hBF800000; // -1.0
    localparam [31:0] FP_N2   = 32'hC0000000; // -2.0
    localparam [31:0] FP_N5   = 32'hC0A00000; // -5.0
    localparam [31:0] FP_10   = 32'h41200000; // 10.0

    integer errors;

    // Task to apply one test vector
    task run_test;
        input [31:0] t_re1, t_im1, t_re2, t_im2;
        input [31:0] exp_re, exp_im;
        input [127:0] name;
    begin
        // Drive inputs
        @(posedge clk);
        re_in1   <= t_re1;
        im_in1   <= t_im1;
        re_in2   <= t_re2;
        im_in2   <= t_im2;
        valid_in <= 1'b1;

        // Pulse valid_in for one cycle
        @(posedge clk);
        valid_in <= 1'b0;

        $display("\n[TB] Starting test %s", name);
        $display("[TB] A = (%h, %h), B = (%h, %h)",
                 t_re1, t_im1, t_re2, t_im2);

        // Wait for DUT to assert valid_out (accounts for IP latency)
        wait (valid_out == 1'b1);

        // Sample outputs when valid_out is high
        $display("[TB] Output at valid_out=1: re_out=%h im_out=%h",
                 re_out, im_out);

        // Compare exact FP bit patterns
        if (re_out !== exp_re || im_out !== exp_im) begin
            $display("  ERROR in %s:", name);
            $display("    Expected re=%h im=%h", exp_re, exp_im);
            $display("    Got      re=%h im=%h", re_out, im_out);
            errors = errors + 1;
        end else begin
            $display("  PASS %s", name);
        end

        // Give a couple of cycles between tests
        @(posedge clk);
        @(posedge clk);
    end
    endtask

    initial begin
        errors   = 0;
        valid_in = 0;
        re_in1   = 0; im_in1 = 0;
        re_in2   = 0; im_in2 = 0;

        // Let things settle
        @(posedge clk);
        @(posedge clk);

        // ------------------------------------
        // Test 1: (1 + j0) * (1 + j0) = 1 + j0
        // ------------------------------------
        run_test(
            FP_1,   FP_ZERO,
            FP_1,   FP_ZERO,
            FP_1,   FP_ZERO,
            "Test1: (1+j0)*(1+j0)"
        );

        // ------------------------------------
        // Test 2: (1 + j2) * (3 + j4)
        //  = (1*3 - 2*4) + j(1*4 + 2*3)
        //  = (3 - 8) + j(4 + 6)
        //  = -5 + j10
        // ------------------------------------
        run_test(
            FP_1,   FP_2,        // 1 + j2
            FP_3,   FP_4,        // 3 + j4
            FP_N5,  FP_10,       // -5 + j10
            "Test2: (1+j2)*(3+j4)"
        );

        // ------------------------------------
        // Test 3: purely imaginary * purely imaginary
        // (0 + j2) * (0 + j3) = -6 + j0
        // ------------------------------------
        run_test(
            FP_ZERO, FP_2,     // 0 + j2
            FP_ZERO, FP_3,     // 0 + j3
            32'hC0C00000,      // -6.0 in IEEE-754
            FP_ZERO,
            "Test3: (j2)*(j3) = -6 + j0"
        );

        // Final report
        if (errors == 0)
            $display("\nAll complex_fpmult tests PASSED.");
        else
            $display("\ncomplex_fpmult tests FAILED with %0d error(s).", errors);

        $finish;
    end
endmodule
