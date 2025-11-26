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
    input clk, valid_in,
    input[31:0] re_in1, im_in1,
    input[31:0] re_in2, im_in2,
    input op,
    output[31:0] re_out,im_out,
    output out_valid
    );
    
wire re_addsubA_tready, re_addubOP_tready, re_addsubB_tready;
wire m_re_tready;

floating_point_0 re_addsub(.aclk(clk),
                    .s_axis_a_tdata(re_in1),
                    .s_axis_a_tready(re_addsubA_tready),
                    .s_axis_a_tvalid(valid_in),
                    .s_axis_operation_tdata({31'b0000_0000_0000_0000_0000_0000_0000_000, op}),
                    .s_axis_operation_tready(re_addsubOP_tready),
                    .s_axis_operation_tvalid(valid_in),
                    .s_axis_b_tdata(re_in2),
                    .s_axis_b_tready(re_addsubB_tready),
                    .s_axis_b_tvalid(valid_in),
                    .m_axis_result_tdata(re_out),
                    .m_axis_result_tready(1'b1),
                    .m_axis_result_tvalid(m_re_tvalid)
                    
    );

wire im_addsubA_tready, im_addubOP_tready, im_addsubB_tready;
wire m_im_tready;
wire im_addsubA_tvalid, im_addsubB_tvalid, im_addsubOP_tvalid;
floating_point_0 im_addsub(.aclk(clk),
                    .s_axis_a_tdata(im_in1),
                    .s_axis_a_tready(im_addsubA_tready),
                    .s_axis_a_tvalid(valid_in),
                    .s_axis_operation_tdata({31'b0000_0000_0000_0000_0000_0000_0000_000, op}),
                    .s_axis_operation_tready(im_addsubOP_tready),
                    .s_axis_operation_tvalid(valid_in),
                    .s_axis_b_tdata(im_in2),
                    .s_axis_b_tready(im_addsubB_tready),
                    .s_axis_b_tvalid(valid_in),
                    .m_axis_result_tdata(im_out),
                    .m_axis_result_tready(1'b1),
                    .m_axis_result_tvalid(m_im_tvalid)
                    
    );

    assign out_valid = m_re_tvalid & m_im_tvalid;
    
    
endmodule
