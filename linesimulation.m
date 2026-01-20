%%产线性能仿真
%函数输入：产线配置信息，缓冲区配置方案,产品需求
%函数输出：生产线的仿真性能
function [lineperf]= linesimulation(linecon,bufset,demance)
global Instance_all  lineconfi 
javaaddpath("ALS_2_3.jar");
distributionType = "NORM";
lengthType       = int32(1);
cv               = 0.3;
s                = int32(demance);
simLength        = int32(3000);
warmUpPeriod     = int32(100);
WC = ones(size(linecon,2),1);
assign_task                = zeros(1);
for j = 1:size(linecon,2)
    assign_plan        = [linecon{1,j}];
    a                  = sum(assign_plan==0);
    WC(j)              = WC(j)+a;
    assign_plan        = assign_plan(assign_plan ~=0 );
    
    for i =1:size(assign_plan,2)
        assign_task(j,i) = assign_plan(1,i);
    end
end

lc               = int32([WC,bufset,assign_task]);
lineconfi        = lc;
zero_m           = zeros(1,Instance_all.number_model);
tTimes           = [zero_m;Instance_all.Task_time];
cast(tTimes, 'double');
cast(cv, 'double');
randomSeq        = false;
%% 核心语句，查手册得，改参数，输入的参数在上面
%lc需要改，为装配线配置，几个站，每个站做什么
% cv要改，变异系数
% s:模型进入方式
% 增加randomSeq的值，false为模型进入顺序确定，s由数组表示

    lineperf = linesimulator.Simulation(distributionType,cv,simLength,warmUpPeriod,lengthType,s,randomSeq,tTimes,lc);

end