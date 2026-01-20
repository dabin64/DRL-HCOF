clc;
clear;
clear all
clear java
global Instance_all lineconfi bestndc  best_code2 dqn % actorNet 
warning('off') 

javaaddpath("ALS_2_3.jar");
%导入强化学习智能体
% if exist('f_PPO_mode.mat','file')
%     load('f_PPO_mode.mat','actorNet');
if exist('max2_s4_100_model.mat','file')
    load('max2_s4_100_model.mat','dqn');
else
    error('未找到训练好的模型，请先运行 dqn_train.m 进行训练。');
end

%读取数据
cd('D:\caokai_files\小论文2\加权平均实验\知识增强maxRL-S-buf100-20\新数据')
                         % addpath函数用于将目录添加到MATLAB的搜索路径中,当你调用一个函数、脚本或其他 MATLAB 文件时，MATLAB 会在这些目录中查找它们。
                         % genpath用于生成指定目录下的所有子目录的完整路径列表
                         % cd：用于显示当前工作目录的路径。如果没有参数，cd 会返回当前工作目录的路径。
addpath(genpath(cd));
                          % fullfile 是 MATLAB 中用于构建完整文件路径的函数。
fileFolder                           = fullfile('D:\caokai_files\小论文2\加权平均实验\知识增强maxRL-S-buf100-20\新数据');
                          % dir 函数用于列出指定目录中的文件和文件夹的信息，返回一个结构体数组，每个元素包含一个文件或文件夹的信息。
                          % 如名称、大小、日期等。没有指定目录，dir 将列出当前工作目录的内容。
dirOutput                            = dir(fullfile(fileFolder,'*.alb'));% *.m 是一个通配符，用于匹配所有 .m 文件
fileNames                            = {dirOutput.name}' ;%行转列
n_fileNames                          = length(fileNames);
cd('D:\caokai_files\小论文2\加权平均实验\知识增强maxRL-S-buf100-20\新数据')
addpath(genpath(cd));
      %输出数据
title_front                         = {'序号', '例子名称', '任务数量', '平均生产周期时间', 'NDC-mean','NDC-std','NDC-mediman','NDC-IGD',...
                                                    'CTvs-mean','CTvs-std','最优best_CTEFF','最少成本best_DC',...
                                                    '最优best_NDC','最优best_WC','最优best_WO','最优best_ETOT','最优best_BUF', ...
                                                    'MAX_buf','%B','mean_time'}; 

% 主循环

all_output_data =[];
all_output_data1 =[];
all_time = [];
bestndc_all = {};
jj  = 0;
tt  = 0;
all_best_lc ={};
for i = 1:n_fileNames%n_fileNames%每个例子循环 1:n_fileNames
    cd('D:\caokai_files\小论文2\加权平均实验\知识增强maxRL-S-buf100-20\新数据')
    addpath(genpath(cd));
       re_num                  = 20;%单个实验重复次数

       Instance_in             = INSTANCE(fileNames{i, 1}); %通过类来读取数据，解析
       Instance_all            = Instance_in ; %另存解析数据，全局变量
       Number_index            = i; %第几个例子
       Instances_name          = fileNames{i, 1}; %例子名称
       Task_N                  = Instance_in.Task_N; %解析出的例子任务数
       CT                      = Instance_in.CT; %解析出的CT
       min_NDC = [];
       best_plan={};
       bestndc_all_single=[];
       fitness_NDC = [];
       Demance = [];
       end_time    = 0;
       start_time = cputime;
       for j = 1:re_num
           bestndc                 = [];
           % 该算法重复15次，计算结果保存在 all_output_data
           tt                                   = tt+1;
                           %GA下的文件platemo ，这里DE是差分进化算法，要改
                           % P.decs：决策变量的值，即优化过程中找到的解。
                           % P.objs：目标函数值，即在 P.decs 对应的解处计算的目标函数的值。
                           % P.cons：约束函数值，如果问题有约束的话。
           [P.decs,P.objs,P.cons]               = platemo('algorithm',@GA,'problem',@SABLA,'N',5,'maxFE',100,'cr',0.6,'mut',0.55);
           [~,Best_I]                           = min(P.objs);
           solution                             = P.decs(Best_I,:);
           [lineconfi,demance]                  = GA_SABLA_best_solution(solution,Instance_all,best_code2);
           [NDC1,DC1,wc1,wo1,buf1,Etot1,cteff1,max_buf1]                                 ...
                                                              = linesimulation_best(lineconfi,Instance_all,demance);
           Demance(j,:)                                        = demance;
           best_plan(:,j)                                    = {lineconfi};
           bestndc_all_single(j,:)                            = bestndc;
           fitness_NDC(j)                                     = P.objs(Best_I,:);
           all_output_data(tt,1)                 = wc1;%wc总数
           all_output_data(tt,2)                 = wo1;%ws总数
           all_output_data(tt,3)                 = Etot1;%设备数
           all_output_data(tt,4)                 = buf1;%缓冲区数量
           all_output_data(tt,5)                 = max_buf1;%max_buf
           all_output_data(tt,6)                 = cteff1;%仿真时间
           all_output_data(tt,7)                 = NDC1;%NDC
           all_output_data(tt,8)                 = DC1;%DC
           all_output_data(tt,9)                 = Task_N ;
           all_output_data(tt,10)                = Instance_in.number_model;
           all_output_data(tt,11)                = CT;
           min_NDC(j,:)                          = all_output_data((tt-1)+1:tt,1:8);
       end
       jj=jj+1;
       all_time(jj)                                          = (cputime-start_time)/j;
       %选择最优解
       bestndc_all{jj}                                       = bestndc_all_single;
       [~,minx]                                              = min(min_NDC(:,7));%重复3次后最小ndc
       demance                                               = Demance(minx,:);
       best_next_n                                           = min_NDC(minx,:);
       all_best_lc{jj}                                       = best_plan{:,minx};
       lineconfi                                             = best_plan{:,minx};
       cycleTimeAverage                                      = best_next_n(6);
       %数据编入
       INSTANCE_line(fitness_NDC(minx),cycleTimeAverage,best_next_n(8),best_next_n(7),demance,fileNames{i, 1});
       
       % 计算平均值等
       all_output_data1(jj,1)     =mean(all_output_data((jj-1)*j+1:j*jj,7));                   %mean
       all_output_data1(jj,2)     =std(all_output_data((jj-1)*j+1:j*jj,7));                    %std
       all_output_data1(jj,3)     =prctile(all_output_data((jj-1)*j+1:j*jj,7),50);             %mediman
       all_output_data1(jj,4)     =prctile(all_output_data((jj-1)*j+1:j*jj,7),75)-prctile(all_output_data((jj-1)*j+1:j*jj,7),25);%IGD
       all_output_data1(jj,5)     =mean(all_output_data((jj-1)*j+1:j*jj,6));                   %CT
       all_output_data1(jj,6)     =std(all_output_data((jj-1)*j+1:j*jj,6));                    %std

        B_b = sum(lineconfi(:,2)~=0)/best_next_n(1);%缓冲区率
        %接下来是数据汇总
        one_output_data(1,:)                                      = title_front;                    %第一行，数据名称
        one_output_data(jj+1,1)                                   = num2cell(Number_index);          %序号
        one_output_data(jj+1,2)                                   = cellstr(Instances_name);         %例子名称
        one_output_data(jj+1,3)                                   = num2cell(Task_N);                %任务数量
        one_output_data(jj+1,4)                                   = num2cell(CT);                    %平均生产周期时间
        one_output_data(jj+1,5)                                   = num2cell(all_output_data1(jj,1));%mean
        one_output_data(jj+1,6)                                   = num2cell(all_output_data1(jj,2));%std
        one_output_data(jj+1,7)                                   = num2cell(all_output_data1(jj,3));%median
        one_output_data(jj+1,8)                                   = num2cell(all_output_data1(jj,4));%IGD
        one_output_data(jj+1,9)                                   = num2cell(all_output_data1(jj,5));%ct
        one_output_data(jj+1,10)                                   = num2cell(all_output_data1(jj,6));%std
        one_output_data(jj+1,11)                                   = {best_next_n(6)};
        one_output_data(jj+1,12)                                  = {best_next_n(8)};
        one_output_data(jj+1,13)                                  = {best_next_n(7)};
        one_output_data(jj+1,14)                                  = {best_next_n(1)};
        one_output_data(jj+1,15)                                  = {best_next_n(2)};
        one_output_data(jj+1,16)                                  = {best_next_n(3)};
        one_output_data(jj+1,17)                                  = {best_next_n(4)};
        one_output_data(jj+1,18)                                  = {best_next_n(5)};
        one_output_data(jj+1,19)                                  = {B_b};
        one_output_data(jj+1,20)                                  = num2cell(all_time(jj));
% end
cd('D:\caokai_files\小论文2\加权平均实验\知识增强maxRL-S-buf100-20\线再平衡结果\')
% addpath(genpath(cd));
%保存为Excel数据
writecell(one_output_data,'max加权RL-S-buf100-20.xls');
% save 函数用于将工作空间中的变量保存到 .mat 文件中
save('maxSADE_实验RL-S-buf100-20.mat','all_output_data');
save('maxfinally_实验RL-S-buf100-20.mat','bestndc_all','fileNames','all_best_lc');
end
