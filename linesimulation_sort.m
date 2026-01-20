%%产线性能仿真
%函数输入：产线配置信息，缓冲区配置方案,产品需求
%函数输出：生产线的仿真性能
function [CTeff]= linesimulation_sort(lineconfi,Instance,demance)
javaaddpath("ALS_2_3.jar");

%以下是仿真部分
distributionType = "NORM";
lengthType       = int32(1);
cv               = 0.3;
s                = int32(demance);
% % 不同产品数量有不同的仿真负载
%% 例子仿真长度为1/100

    simLength        = int32(3000);

warmUpPeriod     = int32(100);
zero_m           = zeros(1,Instance.number_model);
tTimes           = [zero_m;Instance.Task_time];
lc              = lineconfi;
cast(tTimes, 'double');
cast(cv, 'double');
randomSeq = false;
%% 核心语句，查手册得，改参数，输入的参数在上面
%lc需要改，为装配线配置，几个站，每个站做什么
% cv要改，变异系数
% s:模型进入方式
% 增加randomSeq的值，false为模型进入顺序确定，s由数组表示

lineperf = linesimulator.Simulation(distributionType,cv,simLength,warmUpPeriod,lengthType,s,randomSeq,tTimes,lc);
CTeff = lineperf.cycleTimeAverage;
 % end

end