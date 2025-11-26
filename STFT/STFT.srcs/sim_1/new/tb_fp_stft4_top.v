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

    // -----------------------------
    // DUT inputs
    // -----------------------------
    reg        clk;
    reg        rst;
    reg        valid_in;
    reg [31:0] re_in;
    reg [31:0] im_in;

    // -----------------------------
    // DUT outputs
    // -----------------------------
    wire [31:0] re_X0;
    wire [31:0] im_X0;
    wire [31:0] re_X1;
    wire [31:0] im_X1;
    wire [31:0] re_X2;
    wire [31:0] im_X2;
    wire [31:0] re_X3;
    wire [31:0] im_X3;
    wire        frame_done;
    wire        valid_out;

    // -----------------------------
    // Instantiate DUT
    // -----------------------------
    fp_stft4_top dut (
        .clk       (clk),
        .rst       (rst),
        .valid_in  (valid_in),
        .re_in     (re_in),
        .im_in     (im_in),
        .re_X0     (re_X0),
        .im_X0     (im_X0),
        .re_X1     (re_X1),
        .im_X1     (im_X1),
        .re_X2     (re_X2),
        .im_X2     (im_X2),
        .re_X3     (re_X3),
        .im_X3     (im_X3),
        .frame_done(frame_done),
        .valid_out (valid_out)
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

    // Expected FFT output for frame [1 2 3 4], unity window
    localparam [31:0] EXP_X0_RE = FP_10;
    localparam [31:0] EXP_X0_IM = FP_0;

    localparam [31:0] EXP_X1_RE = FP_N2;
    localparam [31:0] EXP_X1_IM = FP_2;

    localparam [31:0] EXP_X2_RE = FP_N2;
    localparam [31:0] EXP_X2_IM = FP_0;

    localparam [31:0] EXP_X3_RE = FP_N2;
    localparam [31:0] EXP_X3_IM = 32'hC0000000; // -2.0

    integer errors;
    integer frame_idx;

    // -----------------------------
    // Task: send one 4-sample frame
    // -----------------------------
    task send_frame_4;
        input [31:0] a0, b0;
        input [31:0] a1, b1;
        input [31:0] a2, b2;
        input [31:0] a3, b3;
    begin
        // Sample 0
        @(posedge clk);
        valid_in <= 1'b1;
        re_in    <= a0;
        im_in    <= b0;

        // Sample 1
        @(posedge clk);
        re_in    <= a1;
        im_in    <= b1;

        // Sample 2
        @(posedge clk);
        re_in    <= a2;
        im_in    <= b2;

        // Sample 3
        @(posedge clk);
        re_in    <= a3;
        im_in    <= b3;

        // Deassert valid_in after last sample
        @(posedge clk);
        valid_in <= 1'b0;
        re_in    <= FP_0;
        im_in    <= FP_0;
    end
    endtask

    // -----------------------------
    // Main stimulus
    // -----------------------------
    initial begin
        // Init
        rst      = 1'b1;
        valid_in = 1'b0;
        re_in    = FP_0;
        im_in    = FP_0;
        errors   = 0;

        // Hold reset for a few cycles
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        rst = 1'b0;

        $display("\n==== fp_stft4_top Testbench Start ====\n");

        // Send multiple frames to make sim long enough
        for (frame_idx = 0; frame_idx < 5; frame_idx = frame_idx + 1) begin
            $display("[%0t] Sending frame %0d: [1, 2, 3, 4] (real), imag = 0",
                     $time, frame_idx);

            send_frame_4(FP_1, FP_0,
                         FP_2, FP_0,
                         FP_3, FP_0,
                         FP_4, FP_0);

            // Wait for frame_done
            $display("[%0t] Waiting for frame_done...", $time);
            wait (frame_done == 1'b1);
            $display("[%0t] frame_done asserted.", $time);

            // Wait for valid_out
            $display("[%0t] Waiting for valid_out...", $time);
            wait (valid_out == 1'b1);
            @(posedge clk); // sample outputs next cycle

            $display("[%0t] Outputs:", $time);
            $display("  X0 = (%h, %h)", re_X0, im_X0);
            $display("  X1 = (%h, %h)", re_X1, im_X1);
            $display("  X2 = (%h, %h)", re_X2, im_X2);
            $display("  X3 = (%h, %h)", re_X3, im_X3);

            // Check ONLY if your window is unity [1,1,1,1]
            if (re_X0 !== EXP_X0_RE || im_X0 !== EXP_X0_IM) begin
                $display("  ERROR: X0 mismatch. Expected (%h,%h)",
                         EXP_X0_RE, EXP_X0_IM);
                errors = errors + 1;
            end
            if (re_X1 !== EXP_X1_RE || im_X1 !== EXP_X1_IM) begin
                $display("  ERROR: X1 mismatch. Expected (%h,%h)",
                         EXP_X1_RE, EXP_X1_IM);
                errors = errors + 1;
            end
            if (re_X2 !== EXP_X2_RE || im_X2 !== EXP_X2_IM) begin
                $display("  ERROR: X2 mismatch. Expected (%h,%h)",
                         EXP_X2_RE, EXP_X2_IM);
                errors = errors + 1;
            end
            if (re_X3 !== EXP_X3_RE || im_X3 !== EXP_X3_IM) begin
                $display("  ERROR: X3 mismatch. Expected (%h,%h)",
                         EXP_X3_RE, EXP_X3_IM);
                errors = errors + 1;
            end

            // Some idle cycles between frames
            repeat (20) @(posedge clk);
        end

        if (errors == 0)
            $display("\n==== TEST PASSED: All frames matched expected FFT (assuming unity window). ====\n");
        else
            $display("\n==== TEST FAILED: %0d mismatches detected. ====\n", errors);

        $finish;
    end

endmodule