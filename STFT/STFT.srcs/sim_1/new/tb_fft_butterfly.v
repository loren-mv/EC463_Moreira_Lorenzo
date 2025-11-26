`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 01:08:33 PM
// Design Name: 
// Module Name: tb_fft_butterfly
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


module tb_fft_butterfly;

    // Clock & control
    reg clk;
    reg valid_in;

    // Inputs to DUT
    reg  [31:0] re_A, im_A;
    reg  [31:0] re_B, im_B;
    reg  [31:0] re_W, im_W;  // twiddle factor

    // Outputs from DUT
    wire [31:0] re_C, im_C;
    wire [31:0] re_D, im_D;
    wire        valid_out;

    // DUT instantiation
    fp_butterfly dut (
        .clk      (clk),
        .valid_in (valid_in),
        .re_A     (re_A),
        .im_A     (im_A),
        .re_B     (re_B),
        .im_B     (im_B),
        .re_W     (re_W),
        .im_W     (im_W),
        .re_C     (re_C),
        .im_C     (im_C),
        .re_D     (re_D),
        .im_D     (im_D),
        .valid_out(valid_out)
    );

    // -----------------------------
    // Clock generation (100 MHz)
    // -----------------------------
    initial clk = 0;
    always #5 clk = ~clk;   // 10 ns period

    // -----------------------------
    // FP32 constants
    // -----------------------------
    localparam [31:0] FP_ZERO = 32'h00000000; // 0.0
    localparam [31:0] FP_1    = 32'h3F800000; // 1.0
    localparam [31:0] FP_2    = 32'h40000000; // 2.0
    localparam [31:0] FP_3    = 32'h40400000; // 3.0
    localparam [31:0] FP_4    = 32'h40800000; // 4.0
    localparam [31:0] FP_5    = 32'h40A00000; // 5.0
    localparam [31:0] FP_6    = 32'h40C00000; // 6.0
    localparam [31:0] FP_N1   = 32'hBF800000; // -1.0
    localparam [31:0] FP_N2   = 32'hC0000000; // -2.0
    localparam [31:0] FP_N3   = 32'hC0400000; // -3.0
    localparam [31:0] FP_N2F  = 32'hC0000000; // -2.0 (alias)
    localparam [31:0] FP_N6   = 32'hC0C00000; // -6.0

    integer errors;

    // Task: apply one butterfly test
    task run_test;
        input [31:0] t_reA, t_imA, t_reB, t_imB, t_reW, t_imW;
        input [31:0] exp_reC, exp_imC, exp_reD, exp_imD;
        input [127:0] name;
    begin
        @(posedge clk);
        re_A    <= t_reA;
        im_A    <= t_imA;
        re_B    <= t_reB;
        im_B    <= t_imB;
        re_W    <= t_reW;
        im_W    <= t_imW;
        valid_in <= 1'b1;

        // 1-cycle pulse for valid_in
        @(posedge clk);
        valid_in <= 1'b0;

        $display("\n[TB] Starting %s", name);
        $display("[TB] A = (%h, %h), B = (%h, %h), W = (%h, %h)",
                 t_reA, t_imA, t_reB, t_imB, t_reW, t_imW);

        // Wait for butterfly to assert valid_out (handles all IP latency)
        wait (valid_out == 1'b1);

        $display("[TB] Outputs at valid_out=1:");
        $display("     C = (%h, %h)", re_C, im_C);
        $display("     D = (%h, %h)", re_D, im_D);

        // Check results
        if (re_C !== exp_reC || im_C !== exp_imC ||
            re_D !== exp_reD || im_D !== exp_imD) begin
            $display("  ERROR in %s", name);
            $display("    Expected C = (%h, %h)  D = (%h, %h)",
                     exp_reC, exp_imC, exp_reD, exp_imD);
            $display("    Got      C = (%h, %h)  D = (%h, %h)",
                     re_C, im_C, re_D, im_D);
            errors = errors + 1;
        end else begin
            $display("  PASS %s", name);
        end

        // Small gap between tests
        @(posedge clk);
        @(posedge clk);
    end
    endtask

    initial begin
        errors   = 0;
        valid_in = 0;

        re_A = 0; im_A = 0;
        re_B = 0; im_B = 0;
        re_W = 0; im_W = 0;

        // Let clock run a bit
        @(posedge clk);
        @(posedge clk);

        // -------------------------------------------------------
        // Test 1: W = 1 + j0 -> C = A + B, D = A - B
        // A = (1 + j2), B = (3 + j4)
        // C = (4 + j6), D = (-2 - j2)
        // -------------------------------------------------------
        run_test(
            FP_1, FP_2,          // A
            FP_3, FP_4,          // B
            FP_1, FP_ZERO,       // W = 1 + j0
            32'h40800000, FP_6,  // C_re = 4.0, C_im = 6.0
            FP_N2,       FP_N2,  // D_re = -2.0, D_im = -2.0
            "Butterfly Test 1: W=1"
        );

        // -------------------------------------------------------
        // Test 2: Another W = 1 + j0 case
        // A = (5 + j0), B = (-1 + j2)
        // C = (4 + j2), D = (6 - j2)
        // -------------------------------------------------------
        run_test(
            FP_5,   FP_ZERO,     // A
            FP_N1,  FP_2,        // B
            FP_1,   FP_ZERO,     // W = 1 + j0
            32'h40800000, 32'h40000000, // C = (4, 2) => 4.0, 2.0
            FP_6,       FP_N2,   // D = (6, -2) => 6.0, -2.0
            "Butterfly Test 2: W=1"
        );

        // -------------------------------------------------------
        // (Optional) Test 3: non-trivial twiddle W = -j = (0, -1)
        // Let A = (1 + j0), B = (0 + j1)
        // B*W = (0 + j1)*(-j) = 1 + j0
        // C = A + B*W = (2 + j0)
        // D = A - B*W = (0 + j0)
        // -------------------------------------------------------
        run_test(
            FP_1,   FP_ZERO,     // A
            FP_ZERO, FP_1,       // B
            FP_ZERO, FP_N1,      // W = -j = (0, -1)
            FP_2,   FP_ZERO,     // C = 2 + j0
            FP_ZERO,FP_ZERO,     // D = 0 + j0
            "Butterfly Test 3: W=-j"
        );

        // Final report
        if (errors == 0)
            $display("\nAll fp_butterfly tests PASSED.");
        else
            $display("\nfp_butterfly tests FAILED with %0d error(s).", errors);

        $finish;
    end

endmodule
