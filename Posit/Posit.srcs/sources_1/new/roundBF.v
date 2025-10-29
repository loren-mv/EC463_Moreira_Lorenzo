`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2025 09:07:54 PM
// Design Name: 
// Module Name: roundBF
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


module round_UP_BF(
    input[15:0] bf16_unrounded,
    input[2:0] GRS,
    output[15:0] bf16num
    );
 // Extract fields
    wire sign = bf16_unrounded[15];
    reg [7:0] exponent;
    reg [6:0] fraction;

    // Intermediate rounding
    reg [7:0] frac_extended;
    reg carry;

    // Round-to-nearest-even condition
    wire G = GRS[2];
    wire R = GRS[1];
    wire S = GRS[0];
    wire round_up = G & (R | S | bf16_unrounded[0]); // uses preguard bit

    always @(*) begin
        exponent = bf16_unrounded[14:7];
        fraction = bf16_unrounded[6:0];

        // Add rounding increment
        {carry, frac_extended} = {1'b0, fraction} + round_up;

        // Handle carry overflow
        if (carry) begin
            exponent = exponent + 8'd1;
            fraction = 7'd0;
        end else begin
            fraction = frac_extended[6:0];
        end
    end

    assign bf16num = {sign, exponent, fraction};
    
     
endmodule
