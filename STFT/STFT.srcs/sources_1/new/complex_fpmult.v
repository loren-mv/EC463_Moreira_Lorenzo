`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wise Circuits
// Engineer: Lorenzo (Loren) Moreira
// 
// Create Date: 11/15/2025 02:41:08 PM
// Design Name: 
// Module Name: complex_fpmult
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
// chainsaw man movie so unbelievably fire
//////////////////////////////////////////////////////////////////////////////////


module complex_fpmult(
    input[31:0] re_in1, im_in1,
    input[31:0] re_in2, im_in2,
    output[31:0] re_out,im_out,
    output re_exception, im_exception, sum_exception
    );
    
		
//(a + jb)(c + jd) = [ac - bd] + j[ad + bc]
wire[31:0] ac;
wire ProdReOF, ProdReUF, ProdReException;
Multiplication ProdRe(.a_operand(re_in1), 
                    .b_operand(re_in2), 
                    .Exception(ProdReException), 
                    .Overflow(ProdReOF), 
                    .Underflow(ProdReUF), 
                    .result(ac));

wire[31:0] bd;
wire ProdImOF, ProdImUF, ProdImException;
Multiplication ProdIm(.a_operand(im_in1), 
                    .b_operand(im_in2), 
                    .Exception(ProdImException), 
                    .Overflow(ProdImOF), 
                    .Underflow(ProdImUF), 
                    .result(bd));

wire[31:0] ad;
wire ProdReImOF, ProdReImUF, ProdReImException;
Multiplication ProdReIm(.a_operand(re_in1), 
                    .b_operand(im_in2), 
                    .Exception(ProdReImException), 
                    .Overflow(ProdReImOF), 
                    .Underflow(ProdReImUF), 
                    .result(ad));

wire[31:0] bc;
wire ProdImReOF, ProdImReUF, ProdImReException;
Multiplication ProdImRe(.a_operand(im_in1), 
                    .b_operand(re_in2), 
                    .Exception(ProdImReException), 
                    .Overflow(ProdImReOF), 
                    .Underflow(ProdImReUF), 
                    .result(bc));
                    
//(a + jb)(c + jd) = [ac - bd] + j[ad + bc]
wire realpart_exception;        
Addition_Subtraction realpart_addsub(
        .a_operand(ac),
        .b_operand(bd),
        .AddBar_Sub(1'b1),
        .Exception(realpart_exception),
        .result(re_out)
    );

wire imaginarypart_exception;
Addition_Subtraction im_addsub(
        .a_operand(ad),
        .b_operand(bc),
        .AddBar_Sub(1'b0),
        .Exception(imaginarypart_exception),
        .result(im_out)
    );

assign re_exception = ProdReException || ProdImException;
assign im_exception = ProdReImException || ProdImReException;
assign sum_exception = realpart_exception || imaginarypart_exception;


endmodule
