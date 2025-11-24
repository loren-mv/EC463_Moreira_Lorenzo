`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wise Circuits
// Engineer: Lorenzo (Loren) Moreira
// 
// Create Date: 11/15/2025 01:44:09 PM
// Design Name: 
// Module Name: complex_fpaddsub
// Project Name: STFT
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


module complex_fpaddsub(
    input[31:0] re_in1, im_in1,
    input[31:0] re_in2, im_in2,
    input op,
    output[31:0] re_out,im_out,
    output re_exception, im_exception
    );
    

   Addition_Subtraction re_addsub (
        .a_operand(re_in1),
        .b_operand(re_in2),
        .AddBar_Sub(op),
        .Exception(re_exception),
        .result(re_out)
    );
    
    Addition_Subtraction im_addsub (
        .a_operand(im_in1),
        .b_operand(im_in2),
        .AddBar_Sub(op),
        .Exception(im_exception),
        .result(im_out)
    );
    
    
    
endmodule
