`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2025 05:54:08 PM
// Design Name: 
// Module Name: p_cases
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


module p_cases #(parameter N = 8)(
    input[N-1:0] p1,
    output reg isZero,
    output reg isNaR,
    output reg isLessThanOne
    );
    
    always@(*) begin 
        isZero = 0;
        isNaR = 0;
        isLessThanOne = 0;
        
        if(p1 == {N{1'b0}}) begin
            isZero = 1;
        end
        
        else if (p1 == {N{1'b1}}) begin
            isNaR = 1;
        end
        
//right here i would like to add a function that checks if a number is less
//than one. the conversion of posits differs from the range [0,1) and [1,inf)
//i think this would be an adequate place to do it, however how exactly we process data
//will be a design challenge/process
        
    end
    
endmodule
