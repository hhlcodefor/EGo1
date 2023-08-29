`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/29 18:58:22
// Design Name: 
// Module Name: music_2tiger
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


module music_2tiger(

    input          clk     ,//系统时钟 100MHZ
    input cancel_music,//取消闹钟

    output  reg    beep    , //一段一段承载音频输出的pwm信号

);
//参数定义
//每个音符震动一次所占用的时钟周期

//低音
parameter  MIN_DO = 19'd381679,//(100_000_000/262)
            MIN_RE = 19'd340136,//(100_000_000/294)
            MIN_MI = 19'd303030,//(100_000_000/330)
            MIN_FA = 19'd286533,//(100_000_000/349)
            MIN_SO = 19'd255102,//(100_000_000/392)
            MIN_LA = 19'd227273,//(100_000_000/440)
            MIN_XI = 19'd202429;//(100_000_000/494)
//中音
parameter  MID_DO = 18'd191205,//(100_000_000/523)
            MID_RE = 18'd170358,//(100_000_000/587)
            MID_MI = 18'd151745,//(100_000_000/659)
            MID_FA = 18'd143266,//(100_000_000/698)
            MID_SO = 18'd127551,//(100_000_000/784)
            MID_LA = 18'd113636,//(100_000_000/880)
            MID_XI = 18'd101215;//(100_000_000/988)
//高音
parameter  MAX_DO = 17'd95511,//(100_000_000/1047)
            MAX_RE = 17'd85106,//(100_000_000/1175)
            MAX_MI = 17'd75815,//(100_000_000/1319)
            MAX_FA = 17'd71582,//(100_000_000/1397)
            MAX_SO = 17'd63776,//(100_000_000/1568)
            MAX_LA = 17'd56818,//(100_000_000/1760)
            MAX_XI = 17'd50839;//(100_000_000/1967)
parameter TIME_750ms = 27'd75_000_000,//750ms,3/4拍
          TIME_250ms = 26'd25_000_000,//250ms,1/4拍
          TIME_1000ms = 27'd100_000_000;//1000ms,一拍
parameter  NOTE_NUM = 6'd35;//音符个数  36个

//信号定义
reg    [24:0]    cnt_delay   ;//各种拍子的计数器
reg    [5:0]     cnt_note    ;//音符计数器
reg    [18:0]    cnt_freq    ;//音符播放计数器
reg    [18:0]    freq_data   ;//当前音符周期数值

wire   [17:0]    duty_data   ;//占空比
wire             end_note    ;//单个音符播放结束标志
wire             end_flag    ;//所有音符结束标志

reg    [27:0]    cnt_delay_r ;//当前音符节拍所占时间

reg              flag        ;//表示到达该音调频率倒数对应的，周期时间中的高电平的一部分，控制beep的高低

//节拍计数器  cnt_delay
always @(posedge clk or negedge cancel_music)begin      //不断累积时间，与1拍，1/4拍，3/4拍的持续时间比较
    if(!cancel_music)begin
        cnt_delay <= 25'd0;
    end
    else if(cnt_delay == cnt_delay_r)begin
        cnt_delay <= 25'd0;
    end
    else begin
        cnt_delay <= cnt_delay + 1'b1;
    end
end
//音符计数器  cnt_note
always @(posedge clk or negedge cancel_music)begin      //累计节拍数量并与36总节拍数对比//记音频的个数
    if(!cancel_music)begin
        cnt_note <= 6'd0;
    end
    else if(end_flag)begin
        cnt_note <= 6'd0;                               //控制循环播放
    end
    else if(cnt_delay == cnt_delay_r)begin
        cnt_note <= cnt_note + 1'b1;
    end
    else begin
        cnt_note <= cnt_note;
    end
end

//所有音符结束标志 end_flag
assign end_flag = cnt_note == NOTE_NUM && cnt_delay == cnt_delay_r; //36个音符输出结束且最后一个音符持续时间结束时候end_flag=1

//单个音符振动周期 cnt_freq
always @(posedge clk or negedge cancel_music)begin      //记录当前音符周期时间，直到end_note开始另一个音符
    if(!cancel_music)begin
        cnt_freq <= 19'd1;
    end
    else if(end_note)begin
        cnt_freq <= 19'd1;
    end
    else begin
        cnt_freq <= cnt_freq + 1'b1;
    end
end
//单个音符的一个小周期走完的标志 end_note
//记录的持续时间已经达到其音调频率倒数对应的的周期时间，表示走完一个音调频率(一个现实中的音调由很多个小周期构成，这个只是表示走完了一个小周期，一个现实中的音符结束由另外的cnt_delay == cnt_delay_r控制)
assign end_note = (cnt_freq == freq_data);


//音符数据选择 freq_data
always @(posedge clk or negedge cancel_music)begin
    if(!cancel_music)begin
        freq_data <= MAX_DO;
    end
    else begin
        case(cnt_note)
            6'd0:begin
                freq_data <= MID_DO;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd1:begin
                freq_data <= MID_RE;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd2:begin
                freq_data <= MID_MI;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd3:begin
                freq_data <= MID_DO;
                cnt_delay_r <= TIME_1000ms;
            end
            ////////////////////////////////////////////////////第1节
            6'd4:begin
                freq_data <= MID_DO;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd5:begin
                freq_data <= MID_RE;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd6:begin
                freq_data <= MID_MI;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd7:begin
                freq_data <= MID_DO;
                cnt_delay_r <= TIME_1000ms;
            end
            ////////////////////////////////////////////////////第2节
            6'd8:begin
                freq_data <= MID_MI;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd9:begin
                freq_data <= MID_FA;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd10:begin
                freq_data <= MID_SO;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd11:begin
                freq_data <= MID_SO;
                cnt_delay_r <= TIME_1000ms;
            ////////////////////////////////////////////////////第3节
            end
            6'd12:begin
                freq_data <= MID_MI;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd13:begin
                freq_data <= MID_FA;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd14:begin
                freq_data <= MID_SO;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd15:begin
                freq_data <= MID_SO;
                cnt_delay_r <= TIME_1000ms;
            ////////////////////////////////////////////////////第4节
            end
            6'd16:begin
                freq_data <= MID_SO;
                cnt_delay_r <= TIME_750ms;
            end
            6'd17:begin
                freq_data <= MID_LA;
                cnt_delay_r <= TIME_250ms;
            end
            6'd18:begin
                freq_data <= MID_SO;
                cnt_delay_r <= TIME_750ms;
            end
            6'd19:begin
                freq_data <= MID_FA;
                cnt_delay_r <= TIME_250ms;
            end
            6'd20:begin
                freq_data <= MID_MI;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd21:begin
                freq_data <= MID_DO;
                cnt_delay_r <= TIME_1000ms;
            end
            ////////////////////////////////////////////////////第5节
            6'd22:begin
                freq_data <= MID_SO;
                cnt_delay_r <= TIME_750ms;
            end
            6'd23:begin
                freq_data <= MID_LA;
                cnt_delay_r <= TIME_250ms;
            end
            6'd24:begin
                freq_data <= MID_SO;
                cnt_delay_r <= TIME_750ms;
            end
            6'd25:begin
                freq_data <= MID_FA;
                cnt_delay_r <= TIME_250ms;
            end
            6'd26:begin
                freq_data <= MID_MI;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd27:begin
                freq_data <= MID_DO;
                cnt_delay_r <= TIME_1000ms;
            end
            ////////////////////////////////////////////////////第6节
            6'd28:begin
                freq_data <= MID_DO;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd29:begin
                freq_data <= MIN_SO;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd30:begin
                freq_data <= MID_DO;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd31:begin
                freq_data <= MID_DO;
                cnt_delay_r <= TIME_1000ms;
            end
            ////////////////////////////////////////////////////第7节
            6'd32:begin
                freq_data <= MID_RE;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd33:begin
                freq_data <= MIN_SO;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd34:begin
                freq_data <= MID_DO;
                cnt_delay_r <= TIME_1000ms;
            end
            6'd35:begin
                freq_data <= MID_DO;
                cnt_delay_r <= TIME_1000ms;
            end
            ////////////////////////////////////////////////////第8节
            default:begin
                freq_data <= MID_RE;
                cnt_delay_r <= TIME_1000ms;
            end
        endcase
    end
end
//占空比 duty_data
assign duty_data = freq_data >> 3;//移位越多，占空比越高
// flag
always @(posedge clk or negedge cancel_music)begin
    if(!cancel_music)begin
        flag <= 1'b0;
    end
    else begin
        flag <= (cnt_freq >= duty_data) ? 1'b1 : 1'b0;  //在一个音符频率倒数对应的的小周期中，前面一部分是低，后一部分是高，具体取决于duty_data是fred_data的多少向右的位移，
    end                                                 //若不移相当于duty_data=fred_data，则没有低电平出现，输出全是高电平，是错误的输出
                                                        //移3位则，一个音符的小周期中前87.5%是低电平，后12.5%是高电平
end

//输出 beep
always @(posedge clk or negedge cancel_music)begin
    if(!cancel_music)begin
        beep <= 1'b0;
    end
    else if(flag)begin
        beep <= 1'b1;
    end
    else begin
        beep <= 1'b0;
    end
end
endmodule
