`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wise Circuits
// Engineer: Lorenzo (Loren) Moreira
// 
// Create Date: 11/15/2025 02:12:21 PM
// Design Name: 
// Module Name: complex_positaddsub
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


module complex_positaddsub (re_in1, im_in1, re_in2, im_in2, start, re_out,im_out, re_done, im_done);
    
    parameter N = 8;
    //parameter Bs = log2(N); 
    parameter es = 2;	//Posit Exponent Size
    input[N-1:0] re_in1, im_in1;
    input[N-1:0] re_in2, im_in2;
    input start;
    output[N-1:0] re_out,im_out;
    output re_done, im_done;
    
    //module posit_adder (in1, in2, start, out, inf, zero, done);
    posit_adder re_add(.in1(re_in1),
                        .in2(re_in2),
                        .start(1'b1), 
                        .out(re_out), 
                        .inf(), 
                        .zero(), 
                        .done(re_done));
    posit_adder im_add(.in1(im_in1), 
                        .in2(im_in2), 
                        .start(1'b1), 
                        .out(im_out), 
                        .inf(), 
                        .zero(), 
                        .done(im_done));
    
endmodule
