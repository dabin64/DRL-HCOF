%%序列转成FAST序列
%函数输入：序列
%函数输出：FAST序列
% Updata_Foltask_imd_set_temp	更新后的直接前驱集合
% Updata_Foltask_imd_set	直接后继集合
% pre_task	无前驱任务集合
% first_task	选择的第一个任务
% Candidate	当前可执行任务集合
% Task_permutation	最终的任务序列
function [FAST]= seq_to_FAST(seq)
pre_task   = [];
Task_permutation  = [];
global Instance_all
%获取任务的直接前任任务集
   for i = 1: Instance_all.Task_N
        Foltask_imd_data_temp  = []; 
       if isempty(Instance_all.Pretask_imd_set{1,i})
        updata_Foltask_imd_data = [];  %没有前任任务就直接赋值为空
       else
           % 收集间接前驱
            for j = 1:size(Instance_all.Pretask_imd_set{1,i},2)
                Foltask_imd_data_temp = [Foltask_imd_data_temp,Instance_all.Pretask_imd_set{1,Instance_all.Pretask_imd_set{1,i}(1,j)}];
            end
            % 移除冗余前驱（已在间接前驱中存在）
                commonElements          = intersect(Foltask_imd_data_temp, Instance_all.Pretask_imd_set{1,i});
                updata_Foltask_imd_data = setdiff(Instance_all.Pretask_imd_set{1,i},commonElements);
       end
       Updata_Foltask_imd_set_temp{1,i}=updata_Foltask_imd_data;
   end

   %获取直接跟随任务
   for i = 1: Instance_all.Task_N
       indices  = [];
       for j = 1:numel(Updata_Foltask_imd_set_temp)
           if  ismember(i,Updata_Foltask_imd_set_temp{1,j})
               indices = [indices, j];
           end
       end
       Updata_Foltask_imd_set{1,i} = indices;
   end
   %判断第一个任务
   for i = 1:size(Instance_all.Pretask_imd_set,2)
       if (isempty(Instance_all.Pretask_imd_set{1,i}))
           pre_task = [pre_task,i];
       end
   end
   if size(pre_task,2)>1
       first_task = pre_task(1,1);
       Candidate_1     = pre_task(1,2:end);
   else
       first_task      = pre_task;
       Candidate_1     =[];
   end
   Candidate        = [];
   Task_permutation = [Task_permutation,first_task];
   for j = 1:size(Updata_Foltask_imd_set{1,first_task},2)
       Candidate_isContained  = ismember(Task_permutation,Instance_all.Pretask_set{1,Updata_Foltask_imd_set{1,first_task}(1,j)});
       if (size(find(Candidate_isContained==1),2) == size(Instance_all.Pretask_set{1,Updata_Foltask_imd_set{1,first_task}(1,j)},2))||isempty(Candidate_isContained)
           Candidate = [Candidate,Updata_Foltask_imd_set{1,first_task}(1,j)];
       end
   end
   Candidate        = [Candidate_1,Candidate];
   %%解码过程
   for i = 1: Instance_all.Task_N-1
       [v,index] = max(seq(Candidate));
       Task_permutation = [Task_permutation,Candidate(index)];
       first_task       = Candidate(index);
       Candidate(index) = [];
       %%判断是否增加元素
       if isempty(Updata_Foltask_imd_set{1,first_task})%%没有直接跟随
       else
           for j = 1:size(Updata_Foltask_imd_set{1,first_task},2)
               Candidate_isContained  = ismember(Task_permutation,Instance_all.Pretask_set{1,Updata_Foltask_imd_set{1,first_task}(1,j)});
               if (size(find(Candidate_isContained==1),2) == size(Instance_all.Pretask_set{1,Updata_Foltask_imd_set{1,first_task}(1,j)},2))||isempty(Candidate_isContained)
                   Candidate = [Candidate,Updata_Foltask_imd_set{1,first_task}(1,j)];
               end
           end
           Candidate = unique(Candidate);
       end
       isrepeat = ismember(Candidate,Task_permutation);
       Candidate(find(isrepeat))=[];
   end
   FAST = Task_permutation;
end