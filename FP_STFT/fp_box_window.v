`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wise Circuits
// Engineer: Lorenzo (Loren) Moreira
// 
// Create Date: 11/15/2025 06:32:37 PM
// Design Name: 
// Module Name: fp_box_window
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


module fp_box_window(index, re_w, im_w, valid_out);
parameter W = 4; // W = width of the window
input wire [$clog2(W)-1:0] index; //index will be useful in the case we implement
                                  //windows of different values,
                                  //the list can be generated on matlab/python
                                  //then made into a rom and read them. 
output [31:0] re_w;
output [31:0] im_w;
output valid_out;
localparam [31:0] fp_one = 32'h3F800000;
localparam [31:0] fp_zero = 32'h0000000;
                                 //might be useful later

 assign re_w = fp_one;
 assign im_w = fp_zero;
 assign valid_out = 1'b1;


endmodule
