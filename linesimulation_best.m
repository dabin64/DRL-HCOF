%%产线性能仿真
%函数输入：产线配置信息，缓冲区配置方案,产品需求
%函数输出：生产线的仿真性能
function [DC_tmep,DCC1,wc1,wo1,buf1,Etot1,cteff1,max_buf1]= linesimulation_best(best_lc,Instance,Demance)

javaaddpath("ALS_2_3.jar");
wc1 = size(best_lc,1);
wo1 = sum(best_lc(:,1));
buf1 = sum(best_lc(:,2));
max_buf1 = max(best_lc(:,2));
ever_etot = int32(sum((best_lc(:,3:end)~=0),2));
if sum(ever_etot,1) ~= Instance.Task_N
      disp(error,'错误');
end
Etot1 = sum(ever_etot.* best_lc(:,1),'all');

%以下是仿真部分
distributionType = "NORM";
lengthType       = int32(1);
cv               = 0.3;
s                = int32(Demance);
% % 不同产品数量有不同的仿真负载
%% 例子仿真长度为1/100

    simLength        = int32(5000);

warmUpPeriod     = int32(100);
zero_m           = zeros(1,Instance.number_model);
tTimes           = [zero_m;Instance.Task_time];
lc              = best_lc;
cast(tTimes, 'double');
cast(cv, 'double');
randomSeq = false;
%% 核心语句，查手册得，改参数，输入的参数在上面
%lc需要改，为装配线配置，几个站，每个站做什么
% cv要改，变异系数
% s:模型进入方式
% 增加randomSeq的值，false为模型进入顺序确定，s由数组表示
CT10 = zeros(1,10);
for i = 1:10
    lineperf = linesimulator.Simulation(distributionType,cv,simLength,warmUpPeriod,lengthType,s,randomSeq,tTimes,lc);
    CT10(i) = lineperf.cycleTimeAverage;
end
cteff1 = mean(CT10);

DCC1 = wo1*30000+Etot1*3000+300*buf1;
 if(cteff1>Instance.CT)
     %z此时为200
 DC_tmep                    = DCC1*(1+20*(((cteff1-Instance.CT)/Instance.CT)^2));
 else
 DC_tmep                    = DCC1 ;
 end

end