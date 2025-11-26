`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 12:20:46 PM
// Design Name: 
// Module Name: tb_complex_fpaddsub
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


module tb_complex_fpaddsub;

    // Clock & control
    reg clk;
    reg valid_in;
    reg op;  // 0 = add, 1 = subtract (assumed)

    // Inputs to DUT
    reg  [31:0] re_in1, im_in1;
    reg  [31:0] re_in2, im_in2;

    // Outputs from DUT
    wire [31:0] re_out, im_out;
    wire        out_valid;

    // Instantiate DUT
    complex_fpaddsub dut (
        .clk      (clk),
        .valid_in (valid_in),
        .re_in1   (re_in1),
        .im_in1   (im_in1),
        .re_in2   (re_in2),
        .im_in2   (im_in2),
        .op       (op),
        .re_out   (re_out),
        .im_out   (im_out),
        .out_valid(out_valid)
    );

    // ---------------------------
    // Clock generation (100 MHz)
    // ---------------------------
    initial clk = 0;
    always #5 clk = ~clk;   // 10 ns period

    // ---------------------------
    // FP32 constants
    // ---------------------------
    localparam [31:0] FP_ZERO = 32'h00000000; // 0.0
    localparam [31:0] FP_1    = 32'h3F800000; // 1.0
    localparam [31:0] FP_2    = 32'h40000000; // 2.0
    localparam [31:0] FP_3    = 32'h40400000; // 3.0
    localparam [31:0] FP_4    = 32'h40800000; // 4.0
    localparam [31:0] FP_N1   = 32'hBF800000; // -1.0
    localparam [31:0] FP_N2   = 32'hC0000000; // -2.0
    localparam [31:0] FP_5    = 32'h40A00000; // 5.0
    localparam [31:0] FP_N5   = 32'hC0A00000; // -5.0

    integer errors;

    // Task: run one add/sub test
    task run_test;
        input [31:0] t_re1, t_im1, t_re2, t_im2;
        input        t_op;        // 0=add, 1=sub
        input [31:0] exp_re, exp_im;
        input [127:0] name;
    begin
        @(posedge clk);
        re_in1   <= t_re1;
        im_in1   <= t_im1;
        re_in2   <= t_re2;
        im_in2   <= t_im2;
        op       <= t_op;
        valid_in <= 1'b1;

        // one-cycle valid_in pulse
        @(posedge clk);
        valid_in <= 1'b0;

        $display("\n[TB] Starting %s", name);
        $display("[TB] A = (%h, %h), B = (%h, %h), op=%0d",
                 t_re1, t_im1, t_re2, t_im2, t_op);

        // Wait for DUT to assert out_valid (handles FP IP latency)
        wait (out_valid == 1'b1);

        $display("[TB] Output at out_valid=1: re_out=%h im_out=%h",
                 re_out, im_out);

        if (re_out !== exp_re || im_out !== exp_im) begin
            $display("  ERROR in %s", name);
            $display("    Expected re=%h im=%h", exp_re, exp_im);
            $display("    Got      re=%h im=%h", re_out, im_out);
            errors = errors + 1;
        end else begin
            $display("  PASS %s", name);
        end

        // gap between tests
        @(posedge clk);
        @(posedge clk);
    end
    endtask

    initial begin
        errors   = 0;
        valid_in = 0;
        op       = 0;
        re_in1   = 0; im_in1 = 0;
        re_in2   = 0; im_in2 = 0;

        // let clock run a bit
        @(posedge clk);
        @(posedge clk);

        // ----------------------------------------
        // Test 1: (1 + j2) + (3 + j4) = (4 + j6)
        // ----------------------------------------
        run_test(
            FP_1, FP_2,
            FP_3, FP_4,
            1'b0,            // add
            32'h40800000,    // 4.0
            32'h40C00000,    // 6.0
            "ADD: (1+j2) + (3+j4)"
        );

        // ----------------------------------------
        // Test 2: (1 + j2) - (3 + j4) = (-2 - j2)
        // ----------------------------------------
        run_test(
            FP_1, FP_2,
            FP_3, FP_4,
            1'b1,            // subtract
            FP_N2,           // -2.0
            FP_N2,           // -2.0
            "SUB: (1+j2) - (3+j4)"
        );

        // ----------------------------------------
        // Test 3: (0 + j0) + (5 + j(-1)) = (5 - j1)
        // ----------------------------------------
        run_test(
            FP_ZERO, FP_ZERO,
            FP_5,    FP_N1,
            1'b0,            // add
            FP_5,
            FP_N1,
            "ADD: (0+0j) + (5-j1)"
        );

        // ----------------------------------------
        // Test 4: (5 + j(-1)) - (5 + j(-1)) = 0 + j0
        // ----------------------------------------
        run_test(
            FP_5,   FP_N1,
            FP_5,   FP_N1,
            1'b1,            // subtract
            FP_ZERO,
            FP_ZERO,
            "SUB: (5-j1) - (5-j1)"
        );

        if (errors == 0)
            $display("\nAll complex_fpaddsub tests PASSED.");
        else
            $display("\ncomplex_fpaddsub tests FAILED with %0d error(s).", errors);

        $finish;
    end
endmodule
