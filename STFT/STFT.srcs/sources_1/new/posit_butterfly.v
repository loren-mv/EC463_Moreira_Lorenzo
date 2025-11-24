`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wise Circuits
// Engineer: Lorenzo (Loren) Moreira
// 
// Create Date: 11/15/2025 08:30:11 PM
// Design Name: 
// Module Name: posit_butterfly
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

//module complex_positmult(re_in1, im_in1, re_in2, im_in2, start, re_out, im_out, re_done, im_done);

module posit_butterfly(re_A,im_A,re_B,im_B,re_W,im_W, re_C, im_C, re_D, im_D);
    input[31:0] re_A, im_A;
    input[31:0] re_B, im_B;
    input[31:0] re_W, im_W; //twiddle factor
    output[31:0] re_C, im_C;
    output[31:0] re_D, im_D;
    
    wire[31:0] re_T, im_T;
    complex_positmult mult(.re_in1(re_B),
                        .im_in1(im_B),
                        .re_in2(re_W),
                        .im_in2(im_W),
                        .start(1'b1),
                        .re_out(re_T),
                        .im_out(im_T),
                        im_done()
                        );

//module complex_positaddsub (re_in1, im_in1, re_in2, im_in2, start, re_out,im_out, re_done, im_done);
    complex_positaddsub Cadd(.re_in1(re_A),
                        .im_in1(im_A),
                        .re_in2(re_T),
                        .im_in2(im_T),
                        .start(1'b1),
                        .re_out(re_C),
                        .im_out(im_C),
                        .re_done(), 
                        .im_done()
                        );
    complex_positaddsub Dadd(.re_in1(re_A),
                        .im_in1(im_A),
                        .re_in2(re_T),
                        .im_in2(im_T),
                        .start(1'b1),
                        .re_out(re_D),
                        .im_out(im_D),
                        .re_done(), 
                        .im_done()
                        );                             
    
endmodule
