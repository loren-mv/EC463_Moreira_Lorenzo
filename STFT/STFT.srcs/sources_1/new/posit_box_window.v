`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wise Circuits
// Engineer: Lorenzo (Loren) Moreira
// 
// Create Date: 11/15/2025 06:39:10 PM
// Design Name: 
// Module Name: posit_box_window
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


module posit_box_window(index, w_out);
parameter N = 32;
parameter W = 4;
input wire [$clog2(4)-1:0] index;
output reg[31:0] w_out;

localparam[N-1:0] posit_one = (1 << (N-2));

always@(*)begin 
    w_out = posit_one;
end

endmodule
