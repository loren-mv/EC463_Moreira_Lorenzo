`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2025 01:22:15 PM
// Design Name: 
// Module Name: bf_fft4
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


module bf_fft4(
    input clk,
    input valid_in,
    input [15:0] re_x0, 
    input [15:0] im_x0,
    input [15:0] re_x1, 
    input [15:0] im_x1,
    input [15:0] re_x2, 
    input [15:0] im_x2,
    input [15:0] re_x3, 
    input [15:0] im_x3,
    output [15:0] re_X0,
    output [15:0] im_X0,  
    output [15:0] re_X1,
    output [15:0] im_X1, 
    output [15:0] re_X2,
    output [15:0] im_X2, 
    output [15:0] re_X3,
    output [15:0] im_X3,
    output valid_out          

);


localparam [15:0] fpone = 32'h3F800000;
localparam [15:0] fpminusone = 32'hBF800000;
localparam [15:0] fpzero = 32'h00000000;


wire[15:0] re_c11, im_c11;
wire[15:0] re_d11, im_d11;
wire[15:0] re_c12, im_c12;
wire[15:0] re_d12, im_d12;

//module fp_butterfly(re_A,im_A,re_B,im_B,re_W,im_W, re_C, im_C, re_D, im_D
//S11 stage 1 part 1
//twiddle factor = 1
wire validS11, validS12;
fp_butterfly S11(.clk(clk),
                 .valid_in(valid_in),
                 .re_A(re_x0),
                 .im_A(im_x0),
                 .re_B(re_x2),
                 .im_B(im_x2),
                 .re_W(fpone),
                 .im_W(fpzero),
                 .re_C(re_c11),
                 .im_C(im_c11),
                 .re_D(re_d11),
                 .im_D(im_d11),
                 .valid_out(validS11)
                 );
//twiddle factor = 1
fp_butterfly S12(.clk(clk),
                 .valid_in(valid_in),
                 .re_A(re_x1),
                 .im_A(im_x1),
                 .re_B(re_x3),
                 .im_B(im_x3),
                 .re_W(fpone),
                 .im_W(fpzero),
                 .re_C(re_c12),
                 .im_C(im_c12),
                 .re_D(re_d12),
                 .im_D(im_d12),
                 .valid_out(validS12)
                 );                 

wire validS2 = validS11 & validS12;

wire validS21, validS22;
//twiddle factor = 1
fp_butterfly S21(.clk(clk),
                 .valid_in(validS2),
                 .re_A(re_c11),
                 .im_A(im_c11),
                 .re_B(re_c12),
                 .im_B(im_c12),
                 .re_W(fpone),
                 .im_W(fpzero),
                 .re_C(re_X0),
                 .im_C(im_X0),
                 .re_D(re_X2),
                 .im_D(im_X2),
                 .valid_out(validS21)
                 );
                 
//twiddle factor = -j                 
fp_butterfly S22(.clk(clk),
                 .valid_in(validS2),
                 .re_A(re_d11),
                 .im_A(im_d11),
                 .re_B(re_d12),
                 .im_B(im_d12),
                 .re_W(fpzero),
                 .im_W(fpminusone),
                 .re_C(re_X1),
                 .im_C(im_X1),
                 .re_D(re_X3),
                 .im_D(im_X3),
                 .valid_out(validS22)
                 );
assign valid_out = validS21 & validS22;

endmodule