`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wise Circuits
// Engineer: Lorenzo (Loren) Moreira
// 
// Create Date: 11/15/2025 08:29:38 PM
// Design Name: 
// Module Name: fp_butterfly
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


module fp_butterfly(re_A,im_A,re_B,im_B,re_W,im_W, re_C, im_C, re_D, im_D);
    input[31:0] re_A, im_A;
    input[31:0] re_B, im_B;
    input[31:0] re_W, im_W; //twiddle factor
    output[31:0] re_C, im_C;
    output[31:0] re_D, im_D;
    
    wire[31:0] re_T, im_T;
    complex_fpmult mult(.re_in1(re_B),
                        .im_in1(im_B),
                        .re_in2(re_W),
                        .im_in2(im_W),
                        .re_out(re_T),
                        .im_out(im_T),
                        .re_exception(),
                        .im_exception(),
                        .sum_exception()
                        );
    complex_fpaddsub Cadd(.re_in1(re_A),
                        .im_in1(im_A),
                        .re_in2(re_T),
                        .im_in2(im_T),
                        .op(1'b0),
                        .re_out(re_C),
                        .im_out(im_C),
                        .re_exception(), 
                        .im_exception()
                        );
    complex_fpaddsub Dadd(.re_in1(re_A),
                        .im_in1(im_A),
                        .re_in2(re_T),
                        .im_in2(im_T),
                        .op(1'b1),
                        .re_out(re_D),
                        .im_out(im_D),
                        .re_exception(), 
                        .im_exception()
                        );                             
    
endmodule
