`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2025 05:03:06 PM
// Design Name: 
// Module Name: convert
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


module convert #(parameter N = 8)(
    input isZero,
    input isNaR,
    input isLessThanOne,
    output reg [N-1:0] converted_num
    );
    
    always@(*) begin
        
        if(isZero) begin
            converted_num = {N{1'b0}};
        end
        
        else if(isNaR) begin
            converted_num = {N{1'b1}};
        end
        
        else begin
        
        end
    
    end
    
endmodule
