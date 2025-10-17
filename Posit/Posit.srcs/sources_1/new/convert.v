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
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module convert #(parameter N = 32, parameter ES = 2)(
    input clk,        
    input rst,        
    input[31:0]  fp32_in,    // IEEE 754 float input
    output reg [N-1:0] posit_out   
    );

    wire sign;
    wire [7:0] exp;
    wire [22:0] frac;

    assign sign = fp32_in[31];
    assign exp  = fp32_in[30:23];
    assign frac = fp32_in[22:0];
    
    wire signed [8:0] E = exp - 127;      
    wire [23:0] M = {1'b1, frac};
    
    wire signed [8:0] k = E >>> ES;       
    wire [ES-1:0] exp_posit = E[ES-1:0];
    
    reg [N-2:0] regime_bits;
    integer regime_size;
    reg [N-1:0] posit_comb;
    
      always @(*) begin
        regime_bits = 'b0;
        regime_size = 0;
        posit_comb  = 'b0;

        if (k >= 0) begin
            regime_size = k + 2;  // run of 1's + terminating 0
            regime_bits = { (N-1){1'b1} };
            regime_bits[N - regime_size] = 1'b0;
        end else begin
            regime_size = (-k) + 1; // run of 0's + terminating 1
            regime_bits = { (N-1){1'b0} };
            regime_bits[N - regime_size] = 1'b1;
        end

        posit_comb = {sign, regime_bits[N-2:0]};

        // (Simplified: not including fraction rounding/truncation logic)
    end
    
    always @(posedge clk) begin
        if (rst)
            posit_out <= {N{1'b0}};
        else
            posit_out <= posit_comb;
    end
    
endmodule
