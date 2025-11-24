`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 10:58:08 AM
// Design Name: 
// Module Name: tb_fp_stft4_top
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


module tb_fp_stft4_top;

localparam width = 32;

    // DUT signals
    reg                  clk;
    reg                  rst;
    reg                  sample_valid;
    reg  [width-1:0]     sample_re;
    reg  [width-1:0]     sample_im;
    wire [width-1:0]     re_X0, im_X0;
    wire [width-1:0]     re_X1, im_X1;
    wire [width-1:0]     re_X2, im_X2;
    wire [width-1:0]     re_X3, im_X3;
    wire                 frame_done;

    // Instantiate DUT
    fp_stft4_top #(.width(width)) dut (
        .clk(clk),
        .rst(rst),
        .valid_in(sample_valid),
        .re_in(sample_re),
        .im_in(sample_im),
        .re_X0(re_X0), .im_X0(im_X0),
        .re_X1(re_X1), .im_X1(im_X1),
        .re_X2(re_X2), .im_X2(im_X2),
        .re_X3(re_X3), .im_X3(im_X3),
        .frame_done(frame_done)
    );

    // Clock: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Test vectors: x = [1, 2, 3, 4], imag = 0
    localparam [width-1:0] X0_RE = 32'h3F800000; // 1.0
    localparam [width-1:0] X1_RE = 32'h40000000; // 2.0
    localparam [width-1:0] X2_RE = 32'h40400000; // 3.0
    localparam [width-1:0] X3_RE = 32'h40800000; // 4.0
    localparam [width-1:0] ZERO  = 32'h00000000;

    // Expected FFT results:
    // [10, -2 + 2j, -2, -2 - 2j]
    localparam [width-1:0] EXP_X0_RE = 32'h41200000; // 10.0
    localparam [width-1:0] EXP_X0_IM = 32'h00000000; // 0.0

    localparam [width-1:0] EXP_X1_RE = 32'hC0000000; // -2.0
    localparam [width-1:0] EXP_X1_IM = 32'h40000000; //  2.0

    localparam [width-1:0] EXP_X2_RE = 32'hC0000000; // -2.0
    localparam [width-1:0] EXP_X2_IM = 32'h00000000; //  0.0

    localparam [width-1:0] EXP_X3_RE = 32'hC0000000; // -2.0
    localparam [width-1:0] EXP_X3_IM = 32'hC0000000; // -2.0

    integer errors;

    initial begin
        errors       = 0;
        sample_valid = 0;
        sample_re    = ZERO;
        sample_im    = ZERO;

        // Reset
        rst = 1;
        repeat(3) @(posedge clk);
        rst = 0;

        // Apply 4 samples, one per clock with sample_valid = 1
        @(posedge clk);
        sample_valid <= 1;
        sample_re    <= X0_RE;  // 1.0
        sample_im    <= ZERO;

        @(posedge clk);
        sample_re    <= X1_RE;  // 2.0
        sample_im    <= ZERO;

        @(posedge clk);
        sample_re    <= X2_RE;  // 3.0
        sample_im    <= ZERO;

        @(posedge clk);
        sample_re    <= X3_RE;  // 4.0
        sample_im    <= ZERO;

        // Stop sending samples
        @(posedge clk);
        sample_valid <= 0;
        sample_re    <= ZERO;
        sample_im    <= ZERO;

        // Wait for frame_done
        wait(frame_done == 1);
        @(posedge clk); // one extra cycle to be safe

        // Display outputs
        $display("FFT Outputs:");
        $display("X0: re=%h im=%h", re_X0, im_X0);
        $display("X1: re=%h im=%h", re_X1, im_X1);
        $display("X2: re=%h im=%h", re_X2, im_X2);
        $display("X3: re=%h im=%h", re_X3, im_X3);

        // Check against expected values
        if (re_X0 !== EXP_X0_RE || im_X0 !== EXP_X0_IM) begin
            $display("ERROR: X0 mismatch. Expected re=%h im=%h", EXP_X0_RE, EXP_X0_IM);
            errors = errors + 1;
        end
        if (re_X1 !== EXP_X1_RE || im_X1 !== EXP_X1_IM) begin
            $display("ERROR: X1 mismatch. Expected re=%h im=%h", EXP_X1_RE, EXP_X1_IM);
            errors = errors + 1;
        end
        if (re_X2 !== EXP_X2_RE || im_X2 !== EXP_X2_IM) begin
            $display("ERROR: X2 mismatch. Expected re=%h im=%h", EXP_X2_RE, EXP_X2_IM);
            errors = errors + 1;
        end;
        if (re_X3 !== EXP_X3_RE || im_X3 !== EXP_X3_IM) begin
            $display("ERROR: X3 mismatch. Expected re=%h im=%h", EXP_X3_RE, EXP_X3_IM);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("TEST PASSED: FFT4 outputs match expected values.");
        else
            $display("TEST FAILED: %0d mismatches.", errors);

        $finish;
    end
    
endmodule
