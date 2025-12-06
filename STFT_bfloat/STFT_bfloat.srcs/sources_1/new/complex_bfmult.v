`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wise Circuits
// Engineer: Lorenzo (Loren) Moreira
// 
// Create Date: 12/06/2025 01:18:50 PM
// Design Name: 
// Module Name: complex_bfmult
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


module complex_bfmult(
    input clk,valid_in,
    input[15:0] re_in1, im_in1,
    input[15:0] re_in2, im_in2,
    output[15:0] re_out,im_out,
    output valid_out
    );
    
		
//(a + jb)(c + jd) = [ac - bd] + j[ad + bc]
wire[15:0] ac;
wire prodreA_tready,prodreB_tready, ac_tready, ac_tvalid;

floating_point_2 ProdRe(.aclk(clk),
                    .s_axis_a_tdata(re_in1),
                    .s_axis_a_tready(prodreA_tready),
                    .s_axis_a_tvalid(valid_in), 
                    .s_axis_b_tdata(re_in2),
                    .s_axis_b_tready(prodreB_tready),
                    .s_axis_b_tvalid(valid_in), 
                    .m_axis_result_tdata(ac),
                    .m_axis_result_tready(1'b1),
                    .m_axis_result_tvalid(ac_tvalid)
                    );
             

wire[15:0] bd;
wire prodimA_tready, prodimB_tready, b_tready, bd_tready, bd_tvalid;
floating_point_2 ProdIm(.aclk(clk),
                    .s_axis_a_tdata(im_in1),
                    .s_axis_a_tready(prodimA_tready),
                    .s_axis_a_tvalid(valid_in), 
                    .s_axis_b_tdata(im_in2),
                    .s_axis_b_tready(prodimB_tready),
                    .s_axis_b_tvalid(valid_in), 
                    .m_axis_result_tdata(bd),
                    .m_axis_result_tready(1'b1),
                    .m_axis_result_tvalid(bd_tvalid)
                    );

wire[15:0] ad;
wire ad_tready, ad_tvalid;
wire prodreimA_tready, prodreimB_tready;
floating_point_2 ProdReIm(.aclk(clk),
                    .s_axis_a_tdata(re_in1),
                    .s_axis_a_tready(prodreimA_tready),
                    .s_axis_a_tvalid(valid_in), 
                    .s_axis_b_tdata(im_in2),
                    .s_axis_b_tready(prodreimB_tready),
                    .s_axis_b_tvalid(valid_in), 
                    .m_axis_result_tdata(ad),
                    .m_axis_result_tready(1'b1),
                    .m_axis_result_tvalid(ad_tvalid)
                    );

wire[15:0] bc;
wire bc_tready, bc_tvalid;
wire prodimreA_tready, prodimreB_tready;
floating_point_2 ProdImRe(.aclk(clk),
                    .s_axis_a_tdata(im_in1),
                    .s_axis_a_tready(prodimreA_tready),
                    .s_axis_a_tvalid(valid_in), 
                    .s_axis_b_tdata(re_in2),
                    .s_axis_b_tready(prodimreB_tready),
                    .s_axis_b_tvalid(valid_in), 
                    .m_axis_result_tdata(bc),
                    .m_axis_result_tready(1'b1),
                    .m_axis_result_tvalid(bc_tvalid)
                    );


wire valid_prod; 
assign valid_prod = bc_tvalid & ad_tvalid & bc_tvalid & ac_tvalid;     
//(a + jb)(c + jd) = [ac - bd] + j[ad + bc]

//wire[31:0] bc;
wire re_tready, re_tvalid;       
wire real_addsubA_tready, real_addsubB_tready, real_addsubOP_tready;
floating_point_0 realpart_addsub(.aclk(clk),
                    .s_axis_a_tdata(ac),
                    .s_axis_a_tready(real_addsubA_tready),
                    .s_axis_a_tvalid(valid_prod),
                    .s_axis_operation_tdata(8'h01),
                    .s_axis_operation_tready(real_addsubOP_tready),
                    .s_axis_operation_tvalid(valid_prod),
                    .s_axis_b_tdata(bd),
                    .s_axis_b_tready(real_addsubB_tready),
                    .s_axis_b_tvalid(valid_prod),
                    .m_axis_result_tdata(re_out),
                    .m_axis_result_tready(1'b1),
                    .m_axis_result_tvalid(re_tvalid)
                    );

wire im_tready, im_tvalid;
wire im_addsubA_tready, im_addsubB_tready, im_addsubOP_tready;
floating_point_0 im_addsub(.aclk(clk),
                    .s_axis_a_tdata(ad),
                    .s_axis_a_tready(im_addsubA_tready),
                    .s_axis_a_tvalid(valid_prod),
                    .s_axis_operation_tdata(8'h00),
                    .s_axis_operation_tready(im_addsubOP_tready),
                    .s_axis_operation_tvalid(valid_prod),
                    .s_axis_b_tdata(bc),
                    .s_axis_b_tready(im_addsubB_tready),
                    .s_axis_b_tvalid(valid_prod),
                    .m_axis_result_tdata(im_out),
                    .m_axis_result_tready(1'b1),
                    .m_axis_result_tvalid(im_tvalid)
                    
    );

assign valid_out = re_tvalid & im_tvalid;

endmodule
