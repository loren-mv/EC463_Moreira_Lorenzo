`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2026 10:50:27 AM
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


module complex_positmult(
    //input clk,
    input valid_in,
    input[31:0] re_in1, im_in1,
    input[31:0] re_in2, im_in2,
    output[31:0] re_out,im_out,
    output valid_out
    );
    
//module posit_add (in1, in2, start, out, inf, zero, done);
//module posit_mult(in1, in2, start, out, inf, zero, done);

		
//(a + jb)(c + jd) = [ac - bd] + j[ad + bc]
wire[31:0] ac;
wire ProdRe_inf, ProdRe_zero, ProdRe_done;

posit_mult ProdRe(.in1(re_in1), 
                    .in2(re_in2),
                    .start(valid_in), 
                    .out(ac),
                    .inf(ProdRe_inf),
                    .zero(ProdRe_zero),
                    .done(ProdRe_done)
                    );
             

wire[31:0] bd;
wire ProdIm_inf, ProdIm_zero, ProdIm_done;

posit_mult ProdIm(.in1(im_in1), 
                    .in2(im_in2),
                    .start(valid_in), 
                    .out(bd),
                    .inf(ProdIm_inf),
                    .zero(ProdIm_zero),
                    .done(ProdIm_done)
                    );

wire[31:0] ad;
wire ProdReIm_inf, ProdReIm_zero, ProdReIm_done;

posit_mult ProdReIm(.in1(re_in1), 
                    .in2(im_in2),
                    .start(valid_in), 
                    .out(ad),
                    .inf(ProdReIm_inf),
                    .zero(ProdReIm_zero),
                    .done(ProdReIm_done)
                    );

wire[31:0] bc;
wire ProdImRe_inf, ProdImRe_zero, ProdImRe_done;

posit_mult ProdImRe(.in1(im1_in1), 
                    .in2(re_in2),
                    .start(valid_in), 
                    .out(ad),
                    .inf(ProdImRe_inf),
                    .zero(ProdImRe_zero),
                    .done(ProdImRe_done)
                    );


wire valid_prod; 
assign valid_prod = ProdRe_done & ProdIm_done & ProdReIm_done & ProdImRe_done;     
//(a + jb)(c + jd) = [ac - bd] + j[ad + bc]

//wire[31:0] bc;     
wire[31:0]neg_bd = {~bd[31], bd[30:0]};
 
wire re_addsub_inf, re_addsub_zero, re_addsub_done;
posit_add realpart_addsub(.in1(ac), 
                    .in2(neg_bd),
                    .start(valid_prod), 
                    .out(re_out),
                    .inf(re_addsub_inf),
                    .zero(re_addsub_zero),
                    .done(re_addsub_done)
                    );

wire im_addsub_inf, im_addsub_zero, im_addsub_done;
posit_add im_addsub(.in1(ad), 
                    .in2(bc),
                    .start(valid_prod), 
                    .out(im_out),
                    .inf(im_addsub_inf),
                    .zero(im_addsub_zero),
                    .done(im_addsub_done)
                    );

assign valid_out = re_addsub_done & im_addsub_done;

endmodule
