`timescale 1ns/1ps
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
    reg[4:0] key;
    reg alarm_power_data;
    reg key_power_data;

    wire[7:0] seg_data1;
    wire[7:0] seg_data2;
    wire[7:0] seg_which;
    wire alarm_data;
    wire alarm_edit_data;
    wire alarm_power_data_out;
    wire pwm;
    wire audio_sd;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        key = 5'b00000;
        alarm_power_data = 1;
        key_power_data = 1;
        // #10000000 key=5'b00001;//开始10ms按s0
        //#30000000 key=5'b00000;//按s0 30ms

        // #10000000 key=5'b00001;//等10ms再按s0
        //#30000000 key=5'b00000;//按s0 30ms
    end
    always #5 clk <= ~clk;
    clock clock(
        .clk(clk),
        .rst(rst),
        .key(key),
        .alarm_power_data(alarm_power_data),
        .key_power_data(key_power_data),

        .seg_data1(seg_data1),
        .seg_data2(seg_data2),
        .seg_which(seg_which),
        .alarm_data(alarm_data),
        .alarm_edit_data(alarm_edit_data),
        .alarm_power_data_out(alarm_power_data_out),
        .pwm(pwm),
        .audio_sd(audio_sd)
    );
endmodule
