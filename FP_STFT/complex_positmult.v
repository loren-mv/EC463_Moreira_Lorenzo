`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2025 03:25:47 PM
// Design Name: 
// Module Name: complex_positmult
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


module complex_positmult(re_in1, im_in1, re_in2, im_in2, start, re_out, im_out, re_done, im_done);

    parameter N = 8;
    //parameter Bs = log2(N); 
    parameter es = 2;	//Posit Exponent Size
    input[N-1:0] re_in1, im_in1;
    input[N-1:0] re_in2, im_in2;
    input start;
    output[N-1:0] re_out,im_out;
    output re_done, im_done;
    wire start = 1'b1;
    //(a + jb)(c + jd) = [ac - bd] + j[ad + bc]
    
    wire[N-1:0] ac;
    wire ac_inf, ac_zero, ac_done;
    
    posit_mult ac_mult(.in1(re_in1), 
                      .in2(re_in2), 
                      .start(start), 
                      .out(ac), 
                      .inf(ac_inf), 
                      .zero(ac_zero), 
                      .done(ac_done));
    wire[N-1:0] bd;
    wire bd_inf, bd_zero, bd_done;
    
    posit_mult bd_mult(.in1(im_in1), 
                      .in2(im_in2), 
                      .start(start), 
                      .out(bd), 
                      .inf(bd_inf), 
                      .zero(bd_zero), 
                      .done(bd_done));
    wire[N-1:0] ad;
    wire ad_inf, ad_zero, ad_done;
    
    posit_mult ad_mult(.in1(re_in1), 
                      .in2(im_in2), 
                      .start(start), 
                      .out(ad), 
                      .inf(ad_inf), 
                      .zero(ad_zero), 
                      .done(ad_done));
    
    wire[N-1:0] bc;
    wire bc_inf, bc_zero, bc_done;
    
    posit_mult bc_mult(.in1(im_in1), 
                      .in2(re_in2), 
                      .start(start), 
                      .out(ad), 
                      .inf(ad_inf), 
                      .zero(ad_zero), 
                      .done(ad_done));
                      
   posit_adder realpart_addsub(.in1(ac),
                               .in2(bd),
                               .start(start),
                               .out(re_out),
                               .inf(),
                               .zero(),
                               .done(re_done));
                               
   posit_adder imaginarypart_addsub(.in1(ad),
                               .in2(bc),
                               .start(start),
                               .out(im_out),
                               .inf(),
                               .zero(),
                               .done(im_done));                               
  
endmodule
