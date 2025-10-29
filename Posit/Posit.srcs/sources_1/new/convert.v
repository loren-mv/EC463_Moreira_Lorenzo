`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2025 05:03:06 PM
// Design Name: 
// Module Name: convert
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: FP32 -> Posit synchronous converter (Verilog-2001 compatible)
//              - procedural regime encoding (no replication with variable)
//              - fraction alignment using shifts (no SV [a -: b] slices)
//              - integer declarations at module scope
// 
//////////////////////////////////////////////////////////////////////////////////

module convert #(parameter N = 32, parameter ES = 2)(

    input              clk,        // clock
    input              rst,        // synchronous reset
    input      [31:0]  fp32_in,    // IEEE 754 float input
    output reg [N-1:0] posit_out   // Posit output
);

    // -------------------------------
    // Stage 1: Extract FP32 components
    // -------------------------------
    wire sign;
    wire [7:0] exp;
    wire [22:0] frac;

    assign sign = fp32_in[31];
    assign exp  = fp32_in[30:23];
    assign frac = fp32_in[22:0];

    // -------------------------------
    // Stage 2: Decode IEEE float
    // -------------------------------
    wire signed [8:0] E = exp - 127;       // unbiased exponent
    wire [23:0] M = {1'b1, frac};          // normalized mantissa (1.f)

    // -------------------------------
    // Stage 3: Compute Posit parameters
    // -------------------------------
    // Split E into k and exponent_posit
    wire signed [8:0] k = E >>> ES;        // regime scaling
    wire [ES-1:0] exp_posit = E[ES-1:0];   // low bits of exponent

    // -------------------------------
    // Stage 4: Regime encoding
    // -------------------------------
    reg [N-2:0] regime_bits;
    integer regime_size;
    reg [N-1:0] posit_comb;
    reg [N-1:0] fraction_trunc;
    integer i;
    integer frac_len;
    
always @(*) begin
    if (k >= 0) begin
        // Start with all 1s, and place terminating 0 after k ones
        for (i = 0; i < N-1; i = i + 1) begin
            if (i < k + 1)
                regime_bits[N-2-i] = 1'b1;
            else if (i == k + 1)
                regime_bits[N-2-i] = 1'b0;
            else
                regime_bits[N-2-i] = 1'b0; // Fill remaining with zeros
        end
        regime_size = k + 2;
    end else begin
        for (i = 0; i < N-1; i = i + 1) begin
            if (i < (-k))
                regime_bits[N-2-i] = 1'b0;
            else if (i == (-k))
                regime_bits[N-2-i] = 1'b1;
            else
                regime_bits[N-2-i] = 1'b0;
        end
        regime_size = (-k) + 1;
    end
    
    frac_len = N - 1 - regime_size - ES;  // number of fraction bits we can fit
    fraction_trunc = 0;                   // default
    
    for (i = 0; i < (N - 1 - ES); i = i + 1) begin
        if (i < (N - 1 - regime_size - ES) && (22 - i) >= 0)
            fraction_trunc[N-2-i] = frac[22 - i];
    end
    posit_comb = {sign, regime_bits[N-2:0], exp_posit, fraction_trunc};
end


    // -------------------------------
    // Stage 5: Register output
    // -------------------------------
    always @(posedge clk) begin
        if (rst)
            posit_out <= {N{1'b0}};
        else
            posit_out <= posit_comb;
    end

endmodule
