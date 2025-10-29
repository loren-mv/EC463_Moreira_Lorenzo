`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2025 04:57:18 PM
// Design Name: 
// Module Name: convertBF
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


module convertBF(
    input[31:0] fp32in,
    output[15:0] bf16out
    );
    
wire sign = fp32in[31];
wire[7:0] unrounded_exp = fp32in[30:23];

wire[22:0] frac = fp32in[22:0];

wire preG = fp32in[16];
wire G = fp32in[15]; 
wire R = fp32in[14];
wire S = |fp32in[13:0];

wire[2:0] GRS = {G,R,S};

wire[15:0] pos_inf = 16'b0_11111111_0000000;
wire[15:0] neg_inf = 16'b1_11111111_0000000;

wire[6:0] unrounded_frac = fp32in[22:16];
wire[15:0] unrounded_num = {sign, unrounded_exp, unrounded_frac};

assign bf16out = ( ((GRS == 3'b100) && (preG)) || (GRS == 3'b101) || (GRS == 3'b110) || (GRS == 3'b111) ) ? 
        ((unrounded_frac + 1'b1) < (unrounded_frac)) ? 
        ((unrounded_exp + 1'b1) < unrounded_exp) ? 
        ((sign == 1)) ? neg_inf : pos_inf
        : {sign, unrounded_exp + 1'b1, unrounded_frac + 1'b1} 
        : {sign, unrounded_exp, unrounded_frac + 1'b1}
        : unrounded_num;
 

endmodule
