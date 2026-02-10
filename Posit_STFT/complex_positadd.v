`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2026 11:18:36 AM
// Design Name: 
// Module Name: complex_positadd
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


module complex_positadd(
    input valid_in,
    input[31:0] re_in1, im_in1,
    input[31:0] re_in2, im_in2,
    input op,
    output[31:0] re_out,im_out,
    output out_valid
    );
    
wire[31:0] c;
wire[31:0] d;

assign c = (op == 1'b0) ? re_in2 : {~re_in2[31], re_in2[30:0]};
assign d = (op == 1'b0) ? im_in2 : {~im_in2[31], im_in2[30:0]};

wire re_addsub_inf, re_addsub_zero, re_addsub_done;
posit_add re_addsub(.in1(re_in1), 
                    .in2(c),
                    .start(valid_in), 
                    .out(re_out),
                    .inf(re_addsub_inf),
                    .zero(re_addsub_zero),
                    .done(re_addsub_done)
                    );


wire im_addsub_inf, im_addsub_zero, im_addsub_done;
posit_add im_addsub(.in1(im_in1), 
                    .in2(d),
                    .start(valid_in), 
                    .out(im_out),
                    .inf(im_addsub_inf),
                    .zero(im_addsub_zero),
                    .done(im_addsub_done)
                    );

    assign out_valid = re_addsub_done & im_addsub_done;
    
    
endmodule
