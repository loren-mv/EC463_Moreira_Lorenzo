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
    //input clk,
    input valid_in,
    input[31:0] re_in1, im_in1,
    input[31:0] re_in2, im_in2,
    output[31:0] re_out,im_out,
    output valid_out
    );
    
		
//(a + jb)(c + jd) = [ac - bd] + j[ad + bc]
wire[31:0] ac;
wire ac_tvalid;

floating_point_2 ProdRe(.s_axis_a_tdata(re_in1),
                    .s_axis_a_tvalid(valid_in), 
                    .s_axis_b_tdata(re_in2),
                    .s_axis_b_tvalid(valid_in), 
                    .m_axis_result_tdata(ac),
                    .m_axis_result_tvalid(ac_tvalid)
                    );
             

wire[31:0] bd;
wire bd_tvalid;
floating_point_2 ProdIm(.s_axis_a_tdata(im_in1),
                    .s_axis_a_tvalid(valid_in), 
                    .s_axis_b_tdata(im_in2),
                    .s_axis_b_tvalid(valid_in), 
                    .m_axis_result_tdata(bd),
                    .m_axis_result_tvalid(bd_tvalid)
                    );

wire[31:0] ad;
wire ad_tvalid;

floating_point_2 ProdReIm(.s_axis_a_tdata(re_in1),
                    .s_axis_a_tvalid(valid_in), 
                    .s_axis_b_tdata(im_in2),
                    .s_axis_b_tvalid(valid_in), 
                    .m_axis_result_tdata(ad),
                    .m_axis_result_tvalid(ad_tvalid)
                    );

wire[31:0] bc;

floating_point_2 ProdImRe(.s_axis_a_tdata(im_in1),
                    .s_axis_a_tvalid(valid_in), 
                    .s_axis_b_tdata(re_in2),
                    .s_axis_b_tvalid(valid_in), 
                    .m_axis_result_tdata(bc),
                    .m_axis_result_tvalid(bc_tvalid)
                    );


wire valid_prod; 
assign valid_prod = bc_tvalid & ad_tvalid & bc_tvalid & ac_tvalid;     
//(a + jb)(c + jd) = [ac - bd] + j[ad + bc]

//wire[31:0] bc;
wire re_tvalid;       

floating_point_0 realpart_addsub(.s_axis_a_tdata(ac),
                    .s_axis_a_tvalid(valid_prod),
                    .s_axis_operation_tdata(8'h01),
                    .s_axis_operation_tvalid(valid_prod),
                    .s_axis_b_tdata(bd),
                    .s_axis_b_tvalid(valid_prod),
                    .m_axis_result_tdata(re_out),
                    .m_axis_result_tvalid(re_tvalid)
                    );

wire im_tvalid;
floating_point_0 im_addsub(.s_axis_a_tdata(ad),
                    .s_axis_a_tvalid(valid_prod),
                    .s_axis_operation_tdata(8'h00),
                    .s_axis_operation_tvalid(valid_prod),
                    .s_axis_b_tdata(bc),
                    .s_axis_b_tvalid(valid_prod),
                    .m_axis_result_tdata(im_out),
                    .m_axis_result_tvalid(im_tvalid)
                    
    );

assign valid_out = re_tvalid & im_tvalid;

endmodule
