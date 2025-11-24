`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 11:41:15 AM
// Design Name: 
// Module Name: tb_fp_fft4
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


module tb_fp_fft4;

reg  [31:0] re_x0, im_x0;
    reg  [31:0] re_x1, im_x1;
    reg  [31:0] re_x2, im_x2;
    reg  [31:0] re_x3, im_x3;

    wire [31:0] re_X0, im_X0;
    wire [31:0] re_X1, im_X1;
    wire [31:0] re_X2, im_X2;
    wire [31:0] re_X3, im_X3;

    // Instantiate DUT
    fp_fft4 dut (
        .re_x0(re_x0), .im_x0(im_x0),
        .re_x1(re_x1), .im_x1(im_x1),
        .re_x2(re_x2), .im_x2(im_x2),
        .re_x3(re_x3), .im_x3(im_x3),
        .re_X0(re_X0), .im_X0(im_X0),
        .re_X1(re_X1), .im_X1(im_X1),
        .re_X2(re_X2), .im_X2(im_X2),
        .re_X3(re_X3), .im_X3(im_X3)
    );

    // Helpful FP32 constants
    localparam [31:0] FP_ZERO = 32'h00000000;
    localparam [31:0] FP_1    = 32'h3F800000; // 1.0
    localparam [31:0] FP_2    = 32'h40000000; // 2.0
    localparam [31:0] FP_3    = 32'h40400000; // 3.0
    localparam [31:0] FP_4    = 32'h40800000; // 4.0

    // Expected FFT results for x = [1,2,3,4]
    // X = [10, -2+2j, -2, -2-2j]
    localparam [31:0] EXP_X0_RE = 32'h41200000; // 10.0
    localparam [31:0] EXP_X0_IM = 32'h00000000; // 0.0

    localparam [31:0] EXP_X1_RE = 32'hC0000000; // -2.0
    localparam [31:0] EXP_X1_IM = 32'h40000000; //  2.0

    localparam [31:0] EXP_X2_RE = 32'hC0000000; // -2.0
    localparam [31:0] EXP_X2_IM = 32'h00000000; //  0.0

    localparam [31:0] EXP_X3_RE = 32'hC0000000; // -2.0
    localparam [31:0] EXP_X3_IM = 32'hC0000000; // -2.0

    integer errors;

    initial begin
        errors = 0;

        // Apply input vector: x = [1, 2, 3, 4], imag = 0
        re_x0 = FP_1;  im_x0 = FP_ZERO;
        re_x1 = FP_2;  im_x1 = FP_ZERO;
        re_x2 = FP_3;  im_x2 = FP_ZERO;
        re_x3 = FP_4;  im_x3 = FP_ZERO;

        // Wait a little for combinational logic to settle
        #10;

        $display("==== fp_fft4 test ====");
        $display("Inputs:");
        $display("x0: re=%h im=%h", re_x0, im_x0);
        $display("x1: re=%h im=%h", re_x1, im_x1);
        $display("x2: re=%h im=%h", re_x2, im_x2);
        $display("x3: re=%h im=%h", re_x3, im_x3);

        $display("\nOutputs:");
        $display("X0: re=%h im=%h", re_X0, im_X0);
        $display("X1: re=%h im=%h", re_X1, im_X1);
        $display("X2: re=%h im=%h", re_X2, im_X2);
        $display("X3: re=%h im=%h", re_X3, im_X3);

        // Compare against expected
        if (re_X0 !== EXP_X0_RE || im_X0 !== EXP_X0_IM) begin
            $display("ERROR: X0 mismatch. Expected re=%h im=%h",
                     EXP_X0_RE, EXP_X0_IM);
            errors = errors + 1;
        end

        if (re_X1 !== EXP_X1_RE || im_X1 !== EXP_X1_IM) begin
            $display("ERROR: X1 mismatch. Expected re=%h im=%h",
                     EXP_X1_RE, EXP_X1_IM);
            errors = errors + 1;
        end

        if (re_X2 !== EXP_X2_RE || im_X2 !== EXP_X2_IM) begin
            $display("ERROR: X2 mismatch. Expected re=%h im=%h",
                     EXP_X2_RE, EXP_X2_IM);
            errors = errors + 1;
        end

        if (re_X3 !== EXP_X3_RE || im_X3 !== EXP_X3_IM) begin
            $display("ERROR: X3 mismatch. Expected re=%h im=%h",
                     EXP_X3_RE, EXP_X3_IM);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("\nTEST PASSED: fp_fft4 outputs match expected FFT.");
        else
            $display("\nTEST FAILED: %0d mismatches detected.", errors);

        $finish;
    end
    
endmodule
