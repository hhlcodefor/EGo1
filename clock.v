`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/26 17:04:52
// Design Name: 
// Module Name: clock
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


module clock(
input clk,	//系统时钟
input rst,	//复位
input [4:0]key,	//键盘输入
output [15:0]seg_data //数码管显示数据



    );
	parameter T1S=27'd100000000;   //常量1秒//晶振100MHz周期10ns
	
	reg [26:0]cnt_1s;	//1秒记录
	
	reg [7:0]second=0;	//秒数记录
	reg [7:0]min=0;		//分数记录
	reg [7:0]hour=0;	//小时数记录
	
	
	
	
	always @(posedge clk)	//计时1s
		if(rst)
		cnt_1s<=27'd0;
		else if(cnt_1s==T1S)
		cnt_1s<=27'd0;
		else
		cnt_1s<=cnt_1s+1'b1;

		
	always @(posedge clk)	//时钟时分秒转换
		begin
			if(!rst)
			second=0;
			else if(cnt_1s==T1S)
			second=second+1;	//秒计时
			else if(second==60)
				begin
				min=min+1;	//分计时
				second=0;
				if(min==60)
					begin
					hour=hour+1;  //小时计时
					min=0;
					if(hour==24)
					hour=0;
					else
					hour=hour;
					end
				else
				min=min;
				end
			else
			second=second;
		end
endmodule

					
				
