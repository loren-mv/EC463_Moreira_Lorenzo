`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Boston University WISE Circuits
// Engineer: Lorenzo (Loren) Moreira
// 
// Create Date: 10/02/2025 05:04:18 PM
// Design Name: 
// Module Name: multiplication
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


module multiplication#(parameter N = 8)(
    input[N-1:0] p1,p2,
    output[N-1:0] product 
    );
    
    wire p1_isZero, p1_isNaR, p2_isZero, p2_isNaR;
    p_cases P1C(.p1(p1), .isZero(p1_isZero), .isNaR(p1_isNaR));
    p_cases P2c(.p1(p2), .isZero(p2_isZero), .isNaR(p2_isNaR));


endmodule
