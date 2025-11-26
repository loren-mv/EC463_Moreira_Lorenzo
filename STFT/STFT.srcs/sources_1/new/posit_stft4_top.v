`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wise Circuits
// Engineer: Lorenzo (Loren) Moreira
// 
// Create Date: 11/16/2025 08:30:36 PM
// Design Name: 
// Module Name: posit_stft4_top
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


module posit_stft4_top(clk, rst, valid_in, re_in, im_in, re_X0, im_X0, re_X1, im_X1, re_X2, im_X2, re_X3, im_X3, frame_done);
    parameter width = 32;
    input clk, rst, valid_in;
    input[width-1:0] re_in;
    input[width-1:0] im_in;
    output[width-1:0] re_X0;
    output[width-1:0] im_X0;    
    output[width-1:0] re_X1;
    output[width-1:0] im_X1;
    output[width-1:0] re_X2;
    output[width-1:0] im_X2;
    output[width-1:0] re_X3;
    output[width-1:0] im_X3;
    output reg frame_done;
    
    localparam F = 4; //fft size
    localparam idx_width = 2; //log2(F)
    
    reg[width-1:0] re_buf[0:F-1];
    reg[width-1:0] im_buf[0:F-1];
    reg[idx_width-1:0] write_idx;
    
    integer i;
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            write_idx <= {idx_width{1'b0}};
            frame_done <= 1'b0;
            
            for(i = 0; i < F; i = i + 1) begin
                re_buf[i] <= {width{1'b0}};
                im_buf[i] <= {width{1'b0}};
            end
        
        end 
        else begin
            frame_done <= 1'b0;
            
            if(valid_in) begin
            re_buf[write_idx] <= re_in;
            im_buf[write_idx] <= im_in;
            
                if(write_idx == F -1) begin
                    write_idx <= {idx_width{1'b0}};
                    frame_done <= 1'b1;
                end 
                else begin
                    write_idx <= write_idx + 1'b1;
                end
            end
        end
    end
    
        wire[width-1:0] re_w0, im_w0;
        wire[width-1:0] re_w1, im_w1;
        wire[width-1:0] re_w2, im_w2;
        wire[width-1:0] re_w3, im_w3;    

        
        posit_box_window w0(.index(0), .re_w(re_w0), .im_w(im_w0));
        posit_box_window w1(.index(0), .re_w(re_w1), .im_w(im_w1));
        posit_box_window w2(.index(0), .re_w(re_w2), .im_w(im_w2));
        posit_box_window w3(.index(0), .re_w(re_w3), .im_w(im_w3));
        
        
        wire[width-1:0] re_xw0, im_xw0;
        wire[width-1:0] re_xw1, im_xw1;
        wire[width-1:0] re_xw2, im_xw2;
        wire[width-1:0] re_xw3, im_xw3; 
        
        
        complex_positmult s0(.re_in1(re_w0), .im_in1(im_w0),
                          .re_in2(re_buf[0]), .im_in2(im_buf[0]),
                          .re_out(re_xw0),. im_out(im_xw0),
                          .re_exception(), .im_exception(), .sum_exception());
        
        complex_positmult s1(.re_in1(re_w1), .im_in1(im_w1),
                          .re_in2(re_buf[1]), .im_in2(im_buf[1]),
                          .re_out(re_xw1),. im_out(im_xw1),
                          .re_exception(), .im_exception(), .sum_exception());                  
        
         complex_positmult s2(.re_in1(re_w2), .im_in1(im_w2),
                          .re_in2(re_buf[2]), .im_in2(im_buf[2]),
                          .re_out(re_xw2),. im_out(im_xw2),
                          .re_exception(), .im_exception(), .sum_exception());
                          
        complex_positmult s3(.re_in1(re_w3), .im_in1(im_w3),
                          .re_in2(re_buf[3]), .im_in2(im_buf[3]),
                          .re_out(re_xw3),. im_out(im_xw3),
                          .re_exception(), .im_exception(), .sum_exception());
        posit_fft4 fft4 (
        .re_x0(re_xw0), .im_x0(im_xw0),
        .re_x1(re_xw1), .im_x1(im_xw1),
        .re_x2(re_xw2), .im_x2(im_xw2),
        .re_x3(re_xw3), .im_x3(im_xw3),
        .re_X0(re_X0),     .im_X0(im_X0),
        .re_X1(re_X1),     .im_X1(im_X1),
        .re_X2(re_X2),     .im_X2(im_X2),
        .re_X3(re_X3),     .im_X3(im_X3)
      );

endmodule
