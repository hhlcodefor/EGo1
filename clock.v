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

	output [7:0]seg_data1, //第一个四位数码管显示数据
	output [7:0]seg_data2,	//第二个四位数码管显示数据
	output [7:0]seg_which	//数码管位选信号

    );
	parameter T1S=27'd100000000;   //常量1s//晶振100MHz周期10ns
	reg [26:0]cnt_1s=0;	//1秒计录
	reg [7:0]second=59;	//秒数记录
	reg [7:0]min=59;		//分数记录
	reg [7:0]hour=23;	//小时数记录
	reg [17:0] cnt_sm=0;	//数码管扫描计录//频率500Hz//周期2us
	reg [2:0] cnt_which=0;	//决定哪一位数码管显示//十进制
	reg [7:0] which=0;	//决定哪一位数码管显示//二进制
	reg [3:0] num=0;	//用于将内部时间一位一位传给数码管段码翻译部分
	reg [7:0] smg=0;	//承载一位数码管的段码
	reg pulse=1'b0;	//上升沿作为500Hz扫频

	parameter xd=21'd2000000;	//削抖计时20ms
	reg [20:0] cnt_xd=0;		//削抖记录
	reg [2:0]key_data=3'd0;	//按键数据//十进制//就是板子上按键的标号
	reg state=0;		//时钟模式//状态机
	reg [25:0]cnt_trinkle=0;	//手动调节时间功能//闪烁记录
	reg [1:0]change_which=0;	//手动调节时间功能//调节时间类型，时？分？秒？
	reg shine = 1'b0;	//数码管暗灭状态

	///////////////////////////////////////////////////////////////    时钟逻辑部分
	always @(posedge clk)	//计时1s
		if(cnt_1s==T1S)
		cnt_1s<=27'd0;
		else
		cnt_1s<=cnt_1s+1'b1;


	always @(posedge clk)	//时钟时分秒转换逻辑
		begin
			if(!rst)
			second=0;
			else if (state==0)	//时钟逻辑状态
			begin
			if(cnt_1s==T1S)
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
			else
		begin
			case (key_data)
				3'd2:
					begin	//按s1所调时间类型减少一个单位
					case(change_which)
					2'd0:begin
						if(hour==0)
						hour=23;
						else
						hour=hour-1;
					end
					2'd1:begin
						if(min==0)
						min=59;
						else
						min=min-1;
					end
					2'd2:begin
						if(second==0)
						second=59;
						else
						second=second-1;
					end
					default : second=second;
					endcase
					end
				3'd5:
					begin	//按s4所调时间类型增加一个单位
					case(change_which)
					2'd0:begin
						if(hour==23)
						hour=0;
						else
						hour=hour+1;
					end
					2'd1:begin
						if(min==59)
						min=0;
						else
						min=min+1;
					end
					2'd2:begin
						if(second==59)
						second=0;
						else
						second=second+1;
					end
					default : second=second;
					endcase
					end
				default :
				begin
				second=second;
				min=min;
				hour=hour;
				end
				endcase
		end
	end

	///////////////////////////////////////////////////////////////    手动调整时间部分
	always  @(posedge clk)	//削抖，不超过20ms的按键信号会被过滤
	begin
		if (key==5'b00000)
		cnt_xd<=0;
		else if (cnt_xd==xd)
		cnt_xd<=xd;
		else
		cnt_xd<=cnt_xd+1;
	end

	always @(posedge clk)	//辨识按下的按键标号
	begin
		if(cnt_xd==0)
		key_data<=0;
		else if (cnt_xd==(xd-21'b1))
			case(key)
				5'b10000:key_data<=5;
				5'b01000:key_data<=4;
				5'b00100:key_data<=3;
				5'b00010:key_data<=2;
				5'b00001:key_data<=1;
			endcase
		else
		key_data<=0;
	end

	always @(posedge clk)		//两状态切换//未来想改成多状态切换的状态机
	begin
		if(key_data==1)
			state<=~state;
		else
			state<=state;
	end

	always @(posedge clk)	//change_which决定调整时间类型，时？分？秒？
	begin
		if (state==1) begin
			if(key_data==3)
			begin
				change_which=change_which+1;
				if (change_which==3)
				change_which=0;
				else
				change_which=change_which;
			end
			else
			change_which=change_which;
		end
		else
		change_which=0;
	end

	///////////////////////////////////////////////////////////////    数码管显示部分
	always @(posedge clk)	//数码管扫描//频率500Hz//周期2us
	begin
		if (cnt_sm==18'd200000)
		begin
			cnt_sm<=0;
			pulse<=1'b1;	//产生一个上升沿
		end
		else
		begin
			cnt_sm<=cnt_sm+1;
			pulse<=1'B0;
		end
	end

	always @(posedge pulse)	//根据500hz的频率，生成cnt_which,作为显示某位数码管的依据
	begin
		if(cnt_which==7)
		cnt_which<=0;
		else begin
			cnt_which<=cnt_which+1;
		end
	end

	always @(posedge clk)	//位于"调整时间状态时"shine控制调整时间时数码管的闪烁,shine=0表示亮起，闪烁周期为0.5s,正常状态不启动
	begin
		if(state==1)		//后续开发闹钟也要闪烁，到时候再加
		begin
			if(cnt_trinkle==26'd50000000)
			begin
				cnt_trinkle<=0;
				shine<=~shine;
			end
			else
			cnt_trinkle<=cnt_trinkle+1;
		end
		else begin
			cnt_trinkle<=0;
			shine<=0;
		end
	end

	always @(posedge clk)	//将十进制的cnt_which,译成二进制的which,用以选择显示的数码管//考虑shine闪烁模块的影响
	begin
		case (cnt_which)
			3'd0:begin
				if (shine==0)	//平时时钟模式shine=0表示亮起
				which<=8'b10000000;
				else if(change_which==0)	//此时shine！=0表示调整时间状态一定开启，控制熄灭
				which<=8'b00000000;
				else
				which<=8'b10000000;
			end
			3'd1:begin
				if (shine==0)	//平时时钟模式shine=0表示亮起
				which<=8'b01000000;
				else if(change_which==0)	//此时shine！=0表示调整时间状态一定开启，控制熄灭
				which<=8'b00000000;
				else
				which<=8'b01000000;
			end
			3'd2:begin
				which<=8'b00100000;		//这一位为分割符，不需要闪烁
			end
			3'd3:begin
				if (shine==0)	//平时时钟模式shine=0表示亮起
				which<=8'b00010000;
				else if(change_which==1)	//此时shine！=0，表示调整时间状态一定开启，控制熄灭
				which<=8'b00000000;
				else
				which<=8'b00010000;
			end
			3'd4:begin
				if (shine==0)	//平时时钟模式shine=0表示亮起
				which<=8'b00001000;
				else if(change_which==1)	//此时shine！=0，表示调整时间状态一定开启，控制熄灭
				which<=8'b00000000;
				else
				which<=8'b00001000;
			end
			3'd5:begin
				which<=8'b00000100;		//这一位为分割符，不需要闪烁
			end
			3'd6:begin
				if (shine==0)	//平时时钟模式shine=0表示亮起
				which<=8'b00000010;
				else if(change_which==2)	//此时shine！=0，表示调整时间状态一定开启，控制熄灭
				which<=8'b00000000;
				else
				which<=8'b00000010;
			end
			3'd7:begin
				if (shine==0)	//平时时钟模式shine=0表示亮起
				which<=8'b00000001;
				else if(change_which==2)	//此时shine！=0，表示调整时间状态一定开启，控制熄灭
				which<=8'b00000000;
				else
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

					
				
