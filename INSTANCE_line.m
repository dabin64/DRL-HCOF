classdef INSTANCE_line < handle    
    properties(SetAccess = private)
        Task_N;
        CT;
        Task_time;
        Precedence;
        lineperf;
        lineconfi;
    end
    methods
        function obj = INSTANCE_line(fitness,cycleTimeAverage,DC,NDC,demance,varargin)
           global   lineconfi
           cd('D:\caokai_files\小论文2\加权平均实验\知识增强maxRL-S-buf100-20\新数据')
            %读取测试例子中的每行数据
            ffid = fopen(varargin{1,1},'r');
            tline = fgetl(ffid);
            i = 1;
            while feof(ffid) == 0
                tline2{i,1} = fgetl(ffid);
                i = i+1;
            end
            tline1            = [tline;tline2];
            obj.Task_N        = str2num( tline1{2,1});   % 任务数量
            Task_N            = str2num( tline1{2,1});
            for i = 1:length(tline1)
                switch tline1{i,1}
                    case '<cycle time>'
                        cycle_time_n = i;
                    case '<task times>'
                        task_time_n  = i;
                    case '<precedence relations>'
                        precedence_relations_n = i;
                    case '<end>'
                        end_n  = i;
                end
            end
            %读取 cycle time
            obj.CT                    =  str2num(tline1{cycle_time_n+1,1});
            % obj.Optimum_m             =  str2num(tline1{optimum_m_n+1,1});
            for i = 1:Task_N
                Task_time(i,:)        = str2num(tline1{task_time_n+i,1}); %读取 task times
            end
             obj.Task_time            = Task_time(:,2:end);
             obj.lineperf             = cycleTimeAverage;
             tline1{end_n,:}          = strrep(tline1{end_n,:},tline1{end_n,:},' ');
             tline1{end_n+1,:}        = '<Best Demance>';
             tline1{end_n+2,:}        = num2str(demance);
             tline1{end_n+3,:}        = '<line performance>';
             tline1{end_n+4,:}        = ['fitness:',num2str(fitness),'  ','cycleTime:',num2str(cycleTimeAverage),...
                                                '  ','designCost:',num2str(DC),'  ','finalNormDesCost:',num2str(NDC)];
             tline1{end_n+5,:}        = strrep(tline1{end_n,:},tline1{end_n,:},' ');
             tline1{end_n+6,:}        = '<line config>';
             for j = 1:size(lineconfi,1)
                 tline1{end_n+6+j,:}    =  num2str(lineconfi(j,:));
             end
             tline1{end_n+7+size(lineconfi,1),:}         = strrep(tline1{end_n,:},tline1{end_n,:},' ');
             tline1{end_n+8+size(lineconfi,1),:}         = '<end>';
             for i = 1:Task_N
                Task_time1(i,:)        = str2num(tline1{task_time_n+i,:}); %读取 task times
             end
             obj.Task_time            = Task_time1(:,2:end);
              fclose(ffid);   
              cd('D:\caokai_files\小论文2\加权平均实验\知识增强maxRL-S-buf100-20\线再平衡结果\方案')
              fid = fopen(varargin{1,1},'wt');
              for k=1:length(tline1)
                  fprintf(fid,'%s\n',tline1{k});              %将newline内的内容逐行写出
              end
              fclose(fid);
        end 
    end
end