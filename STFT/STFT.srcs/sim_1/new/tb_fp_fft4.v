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

    // -----------------------------
    // Clock and control
    // -----------------------------
    reg clk;
    reg valid_in;

    // -----------------------------
    // Inputs: x0..x3 (complex)
    // -----------------------------
    reg [31:0] re_x0, im_x0;
    reg [31:0] re_x1, im_x1;
    reg [31:0] re_x2, im_x2;
    reg [31:0] re_x3, im_x3;

    // -----------------------------
    // Outputs: X0..X3 (complex)
    // -----------------------------
    wire [31:0] re_X0, im_X0;
    wire [31:0] re_X1, im_X1;
    wire [31:0] re_X2, im_X2;
    wire [31:0] re_X3, im_X3;
    wire        valid_out;

    // -----------------------------
    // DUT instantiation
    // -----------------------------
    fp_fft4 dut (
        .clk      (clk),
        .valid_in (valid_in),
        .re_x0    (re_x0), .im_x0(im_x0),
        .re_x1    (re_x1), .im_x1(im_x1),
        .re_x2    (re_x2), .im_x2(im_x2),
        .re_x3    (re_x3), .im_x3(im_x3),
        .re_X0    (re_X0), .im_X0(im_X0),
        .re_X1    (re_X1), .im_X1(im_X1),
        .re_X2    (re_X2), .im_X2(im_X2),
        .re_X3    (re_X3), .im_X3(im_X3),
        .valid_out(valid_out)
    );

    // -----------------------------
    // Clock generation (100 MHz)
    // -----------------------------
    initial clk = 1'b0;
    always #5 clk = ~clk;   // 10 ns period

    // -----------------------------
    // FP32 constants (IEEE-754)
    // -----------------------------
    localparam [31:0] FP_0  = 32'h00000000; // 0.0
    localparam [31:0] FP_1  = 32'h3F800000; // 1.0
    localparam [31:0] FP_2  = 32'h40000000; // 2.0
    localparam [31:0] FP_3  = 32'h40400000; // 3.0
    localparam [31:0] FP_4  = 32'h40800000; // 4.0
    localparam [31:0] FP_10 = 32'h41200000; // 10.0
    localparam [31:0] FP_N2 = 32'hC0000000; // -2.0

    // Expected FFT(x = [1,2,3,4])
    // X0 =  10 + j0
    // X1 =  -2 + j2
    // X2 =  -2 + j0
    // X3 =  -2 - j2
    localparam [31:0] EXP_X0_RE = FP_10;
    localparam [31:0] EXP_X0_IM = FP_0;

    localparam [31:0] EXP_X1_RE = FP_N2;
    localparam [31:0] EXP_X1_IM = FP_2;

    localparam [31:0] EXP_X2_RE = FP_N2;
    localparam [31:0] EXP_X2_IM = FP_0;

    localparam [31:0] EXP_X3_RE = FP_N2;
    localparam [31:0] EXP_X3_IM = 32'hC0000000; // -2.0

    integer errors;

    // -----------------------------
    // Simple task to pulse valid_in
    // -----------------------------
    task pulse_valid_in;
    begin
        @(posedge clk);
        valid_in <= 1'b1;
        @(posedge clk);
        valid_in <= 1'b0;
    end
    endtask

    // -----------------------------
    // Main stimulus
    // -----------------------------
    initial begin
        errors   = 0;
        valid_in = 1'b0;

        // Initialize inputs to x = [1, 2, 3, 4], imag = 0
        re_x0 = FP_1;  im_x0 = FP_0;
        re_x1 = FP_2;  im_x1 = FP_0;
        re_x2 = FP_3;  im_x2 = FP_0;
        re_x3 = FP_4;  im_x3 = FP_0;

        // Let clock run a few cycles before starting
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        $display("\n========== fp_fft4 Testbench ==========");
        $display("Input sequence (x0..x3):");
        $display("x0 = (%h, %h)", re_x0, im_x0);
        $display("x1 = (%h, %h)", re_x1, im_x1);
        $display("x2 = (%h, %h)", re_x2, im_x2);
        $display("x3 = (%h, %h)", re_x3, im_x3);

        // Start FFT on this frame
        pulse_valid_in();

        // Wait for FFT to finish and assert valid_out
        wait (valid_out == 1'b1);
        @(posedge clk); // sample on next clock edge

        $display("\nOutputs at valid_out = 1:");
        $display("X0 = (%h, %h)", re_X0, im_X0);
        $display("X1 = (%h, %h)", re_X1, im_X1);
        $display("X2 = (%h, %h)", re_X2, im_X2);
        $display("X3 = (%h, %h)", re_X3, im_X3);

        // -----------------------------
        // Compare against expected
        // -----------------------------
        if (re_X0 !== EXP_X0_RE || im_X0 !== EXP_X0_IM) begin
            $display("ERROR: X0 mismatch. Expected (%h, %h)",
                     EXP_X0_RE, EXP_X0_IM);
            errors = errors + 1;
        end

        if (re_X1 !== EXP_X1_RE || im_X1 !== EXP_X1_IM) begin
            $display("ERROR: X1 mismatch. Expected (%h, %h)",
                     EXP_X1_RE, EXP_X1_IM);
            errors = errors + 1;
        end

        if (re_X2 !== EXP_X2_RE || im_X2 !== EXP_X2_IM) begin
            $display("ERROR: X2 mismatch. Expected (%h, %h)",
                     EXP_X2_RE, EXP_X2_IM);
            errors = errors + 1;
        end

        if (re_X3 !== EXP_X3_RE || im_X3 !== EXP_X3_IM) begin
            $display("ERROR: X3 mismatch. Expected (%h, %h)",
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


