`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/27 15:46:22
// Design Name: 
// Module Name: clock_tb
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


module clock_tb;
    reg clk;
    reg rst;
    reg [4:0]key;

    wire [7:0] seg_data1;
    wire [7:0] seg_data2;
    wire [7:0] seg_which;
    initial begin
    clk=1'b0;
    rst=1'b1;
    #10000000 key=5'b00001;//开始10ms按s0
    #30000000 key=5'b00000;//按s0 30ms

     #10000000 key=5'b00001;//等10ms再按s0
    #30000000 key=5'b00000;//按s0 30ms
    end
    always #5 clk<=~clk;
    clock clock(
    .clk(clk),
    .rst(rst),
    .key(key),
    .seg_data1(seg_data1),
    .seg_data2(seg_data2),
    .seg_which(seg_which)
    );
endmodule
