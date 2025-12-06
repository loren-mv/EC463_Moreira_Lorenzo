`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2025 01:23:06 PM
// Design Name: 
// Module Name: bf_stft4_top
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


module bf_stft4_top(clk, rst, valid_in, re_in, im_in, re_X0, im_X0, re_X1, im_X1, re_X2, im_X2, re_X3, im_X3, frame_done, valid_out);
    input clk, rst, valid_in;
    input[15:0] re_in;
    input[15:0] im_in;
    output[15:0] re_X0;
    output[15:0] im_X0;    
    output[15:0] re_X1;
    output[15:0] im_X1;
    output[15:0] re_X2;
    output[15:0] im_X2;
    output[15:0] re_X3;
    output[15:0] im_X3;
    output reg frame_done;
    output valid_out;
    
    localparam F = 4; //fft size
    localparam idx_width = 2; //log2(F)
    
    reg[15:0] re_buf[0:F-1];
    reg[15:0] im_buf[0:F-1];
    reg[idx_width-1:0] write_idx;
    
    integer i;
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            write_idx <= {idx_width{1'b0}};
            frame_done <= 1'b0;
            
            for(i = 0; i < F; i = i + 1) begin
                re_buf[i] <= {32{1'b0}};
                im_buf[i] <= {32{1'b0}};
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
    
        wire[15:0] re_w0, im_w0;
        wire[15:0] re_w1, im_w1;
        wire[15:0] re_w2, im_w2;
        wire[15:0] re_w3, im_w3;    
        wire valid_w0, valid_w1, valid_w2, valid_w3;
        
        fp_box_window w0(.index(0), 
                         .re_w(re_w0), 
                         .im_w(im_w0),
                         .valid_out(valid_w0)
                         );
        fp_box_window w1(.index(0), 
                         .re_w(re_w1), 
                         .im_w(im_w1),
                         .valid_out(valid_w1)
                         );
        fp_box_window w2(.index(0),
                         .re_w(re_w2),
                         .im_w(im_w2),
                         .valid_out(valid_w2)
                         );
        fp_box_window w3(.index(0),
                         .re_w(re_w3),
                         .im_w(im_w3),
                         .valid_out(valid_w3)
                         );
        
        wire valid_w;
        assign valid_w = valid_w0 & valid_w1 & valid_w2 & valid_w3;
        
        wire[15:0] re_xw0, im_xw0;
        wire[15:0] re_xw1, im_xw1;
        wire[15:0] re_xw2, im_xw2;
        wire[15:0] re_xw3, im_xw3; 
        
        wire valid_s0, valid_s1, valid_s2, valid_s3;
        
        complex_fpmult s0(.clk(clk),
                          .valid_in(valid_w),
                          .re_in1(re_w0), 
                          .im_in1(im_w0),
                          .re_in2(re_buf[0]),
                          .im_in2(im_buf[0]),
                          .re_out(re_xw0),
                          .im_out(im_xw0),
                          .valid_out(valid_s0)
                          );
        
        complex_fpmult s1(.clk(clk),
                          .valid_in(valid_w),
                          .re_in1(re_w1),
                          .im_in1(im_w1),
                          .re_in2(re_buf[1]),
                          .im_in2(im_buf[1]),
                          .re_out(re_xw1),
                          .im_out(im_xw1),
                          .valid_out(valid_s1)
                          );                  
        
         complex_fpmult s2(.clk(clk),
                          .valid_in(valid_w),
                          .re_in1(re_w2),
                          .im_in1(im_w2),
                          .re_in2(re_buf[2]),
                          .im_in2(im_buf[2]),
                          .re_out(re_xw2),
                          .im_out(im_xw2),
                          .valid_out(valid_s2)
                          );
                          
        complex_fpmult s3(.clk(clk),
                          .valid_in(valid_w),
                          .re_in1(re_w3),
                          .im_in1(im_w3),
                          .re_in2(re_buf[3]),
                          .im_in2(im_buf[3]),
                          .re_out(re_xw3),
                          .im_out(im_xw3),
                          .valid_out(valid_s3)
                          );
                          
        wire valid_s;
        assign valid_s = valid_s0 & valid_s1 & valid_s2 & valid_s3;
        fp_fft4 fft4 (.clk(clk),
                      .valid_in(valid_s),
                      .re_x0(re_xw0), 
                      .im_x0(im_xw0),
                      .re_x1(re_xw1), 
                      .im_x1(im_xw1),
                      .re_x2(re_xw2),
                      .im_x2(im_xw2),
                      .re_x3(re_xw3), 
                      .im_x3(im_xw3),
                      .re_X0(re_X0),     
                      .im_X0(im_X0),
                      .re_X1(re_X1),     
                      .im_X1(im_X1),
                      .re_X2(re_X2),     
                      .im_X2(im_X2),
                      .re_X3(re_X3),     
                      .im_X3(im_X3),
                      .valid_out(valid_out)
                      );

endmodule