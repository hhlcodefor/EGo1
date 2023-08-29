# EGo1
暑校电设课程

## 运行时的问题

### 8/27<br>
 编程设置初值问题<br>
__解决方法：__ 写仿真文件，未设初值的仿真信号全是XXXXX，以找到未设初值信号
### 8/28<br>
 按键抖动问题<br>
__解决方法：__ 找到了消抖算法


 单位时间加模块中，S4按键与S1按键在实际硬件上功能重复且非法调用，可能是数值溢出的问题
 [Synth 8-2292] literal value truncated to fit in 2 bits ["D:/vivado/clock/clock.srcs/sources_1/new/clock.v":115]<br>

__解决方法：__ 分析仿真发现确实是数值溢出，之前认为1'd5代表的一个位宽可以装一个十进制数字，
 但是在计算机内部一个位宽还是二进制的位宽,1'd5产生溢出101舍去前面两位只剩1，导致
第5个按键和第一个按键1被程序混淆
### 8/29<br>
 秒表状态机问题，设置reg[1:0]play变量初值为0时，play变量取反后无法被play==1的条件所判断<br>
__解决方法：__ 在定义秒表状态变量play时选择定义单字节变量reg play=0，取反后可以直接使用play==1进行条件判断<br>

## 版本日志
### 8/27 <br>
v1.0 (首个可用版本，基本时钟逻辑与显示)<br>
### 8/28 
v1.1 (存在硬件S1按键S4相互重复的问题)<br>
v2.0 (可用版本，添加时间正反序单位调节)<br>
### 8/29 <BR>
v3.0 (可用版本，添加秒表)<br>
v3.1 (添加了注释)<br>
v4.0 (可用版本，添加闹钟)<br>
v4.1 (不可用，添加闹钟音乐模块)<br>
