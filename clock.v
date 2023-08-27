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
	//input [4:0]key,	//键盘输入
	output [7:0]seg_data1, //第一个四位数码管显示数据
	output [7:0]seg_data2,	//第二个四位数码管显示数据
	output [7:0]seg_which	//数码管位选信号

    );
	parameter T1S=27'd100000000;   //常量1s//晶振100MHz周期10ns
	reg [26:0]cnt_1s;	//1秒计录
	reg [7:0]second=0;	//秒数记录
	reg [7:0]min=0;		//分数记录
	reg [7:0]hour=0;	//小时数记录
	reg [17:0] cnt_sm;	//数码管扫描计录//频率500Hz
	reg [2:0] cnt_which;	//决定哪一位数码管显示//十进制
	reg [7:0] which;	//决定哪一位数码管显示//二进制
	reg [3:0] num;	//用于将内部时间一位一位传给数码管段码翻译部分
	reg [7:0] smg;	//承载一位数码管的段码
	reg DIR=1'B0;	//上升沿作为500Hz扫频

	always @(posedge clk)	//计时1s
		if(rst)
		cnt_1s<=27'd0;
		else if(cnt_1s==T1S)
		cnt_1s<=27'd0;
		else
		cnt_1s<=cnt_1s+1'b1;


	always @(posedge clk)	//时钟时分秒转换逻辑
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

	always @(posedge clk)	//数码管扫描//频率500Hz
	begin
		if (cnt_sm==18'd200000)
		begin
			cnt_sm<=0;
			DIR<=1'b1;	//产生一个上升沿
		end
		else
		begin
			cnt_sm<=cnt_sm+1;
			DIR<=1'B0;
		end
	end

	always @(posedge DIR)	//根据500hz的频率，生成cnt_which,作为显示某位数码管的依据
	begin
		if(cnt_which==7)
		cnt_which<=0;
		else begin
			cnt_which<=cnt_which+1;
		end
	end

	always @(posedge clk)
	begin
		case (cnt_which)
			3'd0:begin
				which<=8'b10000000;
			end
			3'd1:begin
				which<=8'b01000000;
			end
			3'd2:begin
				which<=8'b00100000;
			end
			3'd3:begin
				which<=8'b00010000;
			end
			3'd4:begin
				which<=8'b00001000;
			end
			3'd5:begin
				which<=8'b00000100;
			end
			3'd6:begin
				which<=8'b00000010;
			end
			3'd7:begin
				which<=8'b00000001;
			end
			default :  which<=8'b00000000;
		endcase
	end

	always @(posedge clk)	//用于将程序内部计算的时间拆成8个数字，一位一位传给数码管翻译部分，翻译成用于显示的段码
	begin
		case(cnt_which)
			3'd0:num<=hour/10;	//小时数的十位
			3'd1:num<=hour%10;	//小时数的个位
			3'd2:num<=10;	//10无实际意义，用于翻译数码管段时显示'-'段，分割时分秒
			3'd3:num<=min/10;	//分钟数的十位
			3'd4:num<=min%10;	//分钟数的个位
			3'd5:num<=10;
			3'd6:num<=second/10;	//秒数的十位
			3'd7:num<=second%10;	//秒数的个位
			default : num<=0;
		endcase
	end

	always @(posedge clk)	//数码管段码翻译部分，将需要显示的数字转化成数码管相对应的段码
	begin
		if(num<=9)
		case (num)
			4'd0:smg<=8'b11111100;
			4'd1:smg<=8'b01100000;
			4'd2:smg<=8'b11011010;
			4'd3:smg<=8'b11110010;
			4'd4:smg<=8'b01100110;
			4'd5:smg<=8'b10110110;
			4'd6:smg<=8'b10111110;
			4'd7:smg<=8'b11100000;
			4'd8:smg<=8'b11111110;
			4'd9:smg<=8'b11110110;
			default : smg<=8'b00000000;
		endcase
		else
		begin
			smg<=8'b00000010;	//分隔符"-"，分割时分秒
		end

	end

	assign seg_data1=smg;	//段码传输
	assign seg_data2=smg;	//段码传输
	assign seg_which=which;	//位选传输

endmodule

					
				
