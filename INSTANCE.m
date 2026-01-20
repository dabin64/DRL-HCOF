classdef INSTANCE < handle    
    properties(SetAccess = private)
        Task_N;
        CT;
        Task_time;
        Precedence;
        Demance;
        Sort;%产品比例
        number_model;
        % Ave_f;
        % Task_freq;
        % Se_pos;
        % Mi_pos;
        % Add_fac;
        % Rep_act;
        % Optimum_m;
        Pretask_set;
        Pretask_imd_set;
        Foltask_set;
        Foltask_N;
        Foltask_imd_set;
        Foltask_imd_N;
        % Updata_Foltask_imd_set;
        Pre_matix;
        Ear_station;
        Lat_station;
        Slack_task;
        PW;
        Tds;
        % Parallel_coe;
        Ave_Task_time;
        % plan;
        % line_cost;
    end
    methods
        function obj = INSTANCE(varargin)
            %读取测试例子中的每行数据
            ffid = fopen(varargin{1,1},'r');
            tline = fgetl(ffid);
            i = 1;
            while feof(ffid) == 0
                tline1{i,1} = fgetl(ffid);
                i = i+1;
            end
            obj.Task_N        = str2num( tline1{1,1});   % 任务数量
            Task_N            = str2num( tline1{1,1});
            for i = 1:length(tline1)
                switch tline1{i,1}
                    case '<cycle time>'
                        cycle_time_n = i;
                    case '<task times>'
                        task_time_n  = i;
                    case '<precedence relations>'
                        precedence_relations_n = i;
                    case '<demance>'
                        demance_n = i;
                    case '<number of model>'
                        number_model_n = i;
                    % case '<setup times backward>'
                    %     s_n = i;
                    % case '<average force>'
                    %     average_force_n = i;
                    % case '<frequency tasks>'
                    %     frequency_tasks_n  = i;
                    % case '<severe postures>'
                    %     severe_postures_n = i;
                    % case '<mild postures>'
                    %     mild_postures_n = i;
                    % case '<additional factor>'
                    %     additional_factor_n  = i;
                    % case '<repetitive actions>'
                    %     repetitive_actions_n  = i;
                    % case '<optimum m>'
                    %     optimum_m_n  = i;
                    % case '<line performance>'
                    %     line_performance_n  = i;
                    % case '<line config>'
                    %     line_config_n  = i;
                    % case '<plan>'
                    %     plan_n  = i;
                    % case '<line cost>'
                    %     line_cost_n  = i;
                    case '<end>'
                        end_n  = i;
                end
            end
            %读取 cycle time
            obj.CT                    =  str2num( tline1{cycle_time_n+1,1});
            str_demance=tline1{demance_n+1,1};
            str_demance=strrep(str_demance, '，', ',');
            parts_demance = strsplit(str_demance, ',');
           
            obj.Demance               =  str2double(parts_demance);%str2num( tline1{demance_n+1,1});
            obj.number_model          =  str2num( tline1{number_model_n+1,1});
            sort = zeros(1,obj.number_model);
            for i = 1:obj.number_model
                  sort(i) = sum((i-1)==obj.Demance);
            end
            obj.Sort                    =  sort;
            % obj.Optimum_m             =  str2num( tline1{optimum_m_n+1,1});
            % obj.line_cost             =  str2num( tline1{line_cost_n+1,1});
            % for i = 1:line_cost_n-2-plan_n
            %     obj.plan{1,i}         =  str2num(tline1{plan_n+i,:});
            % end
            for i = 1:Task_N
                Task_time(i,:)        = str2num(tline1{task_time_n+i,1}); %读取 task times
                % obj.Ave_f(i,:)        = str2num(tline1{average_force_n+i,1});% 读取 average force
                % obj.Task_freq(i,:)    = str2num(tline1{frequency_tasks_n+i,1});% 读取 frequency tasks
                % obj.Se_pos(i,:)       = str2num(tline1{severe_postures_n+i,1});% 读取 severe postures
                % obj.Mi_pos(i,:)       = str2num(tline1{mild_postures_n+i,1});% 读取 mild postures
                % obj.Add_fac(i,:)      = str2num(tline1{additional_factor_n+i,1});% 读取 additional factor
                % obj.Rep_act(i,:)      = str2num(tline1{repetitive_actions_n+i,1});% 读取 repetitive actions
            end
             obj.Task_time            = Task_time;
              % obj.Ave_Task_time        = sum(Task_time,2)./obj.number_model;
              obj.Ave_Task_time        = sum(Task_time.*sort,2)./length(obj.Demance);
             % obj.Ave_Task_time        = sum(Task_time(:,2:end),2);
            % 读取 precedence relations
            % for i = 1:average_force_n - precedence_relations_n-2
            for i = 1:end_n - precedence_relations_n-2
                obj.Precedence(i,:)   = str2num(tline1{precedence_relations_n+i,1});
            end
               fclose(ffid);
               [Pretask_set,Pretask_imd_set,E]           = precede_task(obj);
               [Foltask_set,Foltask_N,Foltask_imd_set,Foltask_imd_N,Pre_matix,L,PW] = follow_task(obj);
               obj.Pretask_set                           = Pretask_set;  
               obj.Pretask_imd_set                       = Pretask_imd_set;
               obj.Foltask_set                           = Foltask_set;
               obj.Foltask_N                             = Foltask_N;
               obj.Foltask_imd_set                       = Foltask_imd_set;
               obj.Foltask_imd_N                         = Foltask_imd_N;
               obj.Pre_matix                             = Pre_matix;
               obj.Ear_station                           = E;
               obj.Lat_station                           = L;
               obj.Slack_task                            = L-E;
               obj.PW                                    = PW;
               obj.Tds                                   = Task_time(:,2)./(L-E+1);
        end
        % set of all tasks which must precede task j
        function [Pretask_set,Pretask_imd_set,E]= precede_task(instanse)
%             clear  Pretask_set E;
            for i= 2:instanse.Task_N
                pretask_imd_data = [];
                for j = 1:length(instanse.Precedence)
                    if(i == instanse.Precedence(j,2))
                        pretask_imd_data  = [pretask_imd_data,instanse.Precedence(j,1)];
                    end
                end
                pretask_imd_set{1,i}      = sort(pretask_imd_data);
            end
            Pretask_imd_set               = pretask_imd_set;
            for i= 2:instanse.Task_N
                pretask_data     = [];
                %   set of all tasks which must precede task j
                for j = 1:length(pretask_imd_set{1,i})
                    pretask_data           = [pretask_data,pretask_imd_set{1,pretask_imd_set{1,i}(1,j)}];
                end
                pretask_imd_set{1,i}       =  [pretask_imd_set{1,i},pretask_data];
                pretask_imd_set{1,i}       =  sort(unique(pretask_imd_set{1,i}));
            end
            Pretask_set = pretask_imd_set;
%             clear  pretask_imd_set;
            % earliest station for task j
            for i= 1:instanse.Task_N
                Sum_pretask_time    = 0;
                for j = 1:length(Pretask_set{1,i})
                    Sum_pretask_time   = Sum_pretask_time + instanse.Ave_Task_time(Pretask_set{1,i}(1,j),1);
                end
                ceil((instanse.Ave_Task_time(i,1)+Sum_pretask_time)/instanse.CT);
                E(i,1) = ceil((instanse.Ave_Task_time(i,1)+Sum_pretask_time)/instanse.CT);
            end
        end
        % set of all tasks which must follow task j
        function [Foltask_set,Foltask_N,Foltask_imd_set,Foltask_imd_N,Pre_matix,L,PW]= follow_task(instanse)
%             clear  Foltask_set foltask_imd_set Foltask_imd_set L ;
            Pre_matix  = zeros(instanse.Task_N,instanse.Task_N);
            for i= 1:instanse.Task_N
                foltask_imd_data = [];
                for j = 1:length(instanse.Precedence)
                    if(i == instanse.Precedence(j,1))
                        foltask_imd_data  = [foltask_imd_data,instanse.Precedence(j,2)];
                    end
                end
                foltask_imd_set{1,i}      = sort(foltask_imd_data);
                Foltask_imd_N(i,:)        = size(foltask_imd_set{1,i},2);
            end
            Foltask_imd_set               = foltask_imd_set;
            for i= 1:instanse.Task_N
                foltask_data     = [];
                %   set of all tasks which must follow task j
                for j = 1:length(foltask_imd_set{1,instanse.Task_N-i+1})
                    foltask_data                           = [foltask_data,foltask_imd_set{1,foltask_imd_set{1,instanse.Task_N-i+1}(1,j)}];
                end
                foltask_imd_set{1,instanse.Task_N-i+1}     =  [foltask_imd_set{1,instanse.Task_N-i+1},foltask_data];
                foltask_imd_set{1,instanse.Task_N-i+1}     =  sort(unique(foltask_imd_set{1,instanse.Task_N-i+1}));
                Foltask_N(instanse.Task_N-i+1,:)           = size(foltask_imd_set{1,instanse.Task_N-i+1},2);
            end
            % foltask_imd_set
            Foltask_set  = foltask_imd_set;
            % Pre_matix
            for i= 1:instanse.Task_N
                for j = 1:length(Foltask_set{1,i})
                    Pre_matix(i,Foltask_set{1,i}(1,j)) = 1;
                    Pre_matix(Foltask_set{1,i}(1,j),i) = 1;
                end
            end
            %  latest station to which task j ca
            for i= 1:instanse.Task_N
                Sum_foltask_time    = 0;
                for j = 1:length(Foltask_set{1,i})
                    Sum_foltask_time   = Sum_foltask_time + instanse.Ave_Task_time(Foltask_set{1,i}(1,j),1);
                end
                PW(i,1) = instanse.Ave_Task_time(i,1) + Sum_foltask_time;
                L(i,1)  = instanse.Task_N - ceil((instanse.Ave_Task_time(i,1)+Sum_foltask_time)/instanse.CT);
            end
        end
    end
end