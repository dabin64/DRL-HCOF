%%解码，得到产线配置
%函数输入：序列
%函数输出：产线配置方案
function [plan] = line_decode3(seq,Instance_all)
[FAST]= seq_to_FAST(seq);
plan = [];          % 生产线配置方案
ct = Instance_all.CT; % 节拍时间
t = [];              % 按顺序记录的任务时间
x = [];             % 当前工作站任务集合
wc = 0;             % 工作站计数器
b_wc_time = [];     % 记录每个工作站的总时间
ave_time = Instance_all.Ave_Task_time; % 任务平均时间
j = 1;
p = 0;
a = 0;
b = 0;
c = 0;
n = 0;
u = 0;
wc1 = 0;
last=[];

for i = 1:size(FAST,2)
    t(1,i) =  ave_time(FAST(1,i),1);%按顺序记录任务时间
end
abc_max=1;
%j不为最后一个工作站，则继续分配
while size(FAST,2)
 wc = wc+1;
 wc1 = wc1+1;
 for j = abc_max:size(FAST,2)
     t1 = t(abc_max:j);
     t2 = cumsum(t1);
     Task_Now = FAST(1,j);
     p=p+1;

     %看任务时间是否小于ct
     if t2(p) <= ct
        Current_task_order1 = j;
        a = p;
        plan1(wc1,a)=Task_Now;

        if j~=size(FAST,2)
         continue
        else
            last = plan1(wc1,a);
            break 
        end
     end

     %看任务时间是否小于2ct
     if ct < t2(p) && t2(p)<=2*ct
        Current_task_order2 = j;
        n=n+1;
        b = n+a;
        plan2(wc1,b-a)=Task_Now;

        if j~=size(FAST,2)
         continue
        else
            try
            last = [plan1(wc1,a),plan2(wc1,1:b-a)];
            catch
                last = [plan2(wc1,1:b-a),zeros(1:1)];
            end
            break
        end

     end

     %看任务时间是否小于3ct
     if 2*ct < t2(p) && t2(p)<=3*ct
        Current_task_order3 = j;
        u=u+1;
        c = u+b;
        plan3(wc1,c-b)=Task_Now;

        if j~=size(FAST,2)
         continue
        else
            try
            last = [plan1(wc1,a),plan2(wc1,1:b-a),plan3(wc1,1:c-b),zeros(1:2)];
            catch
                try
                last = [plan2(wc1,1:b-a),plan3(wc1,1:c-b),zeros(1:2)];
                catch
                last = [plan3(wc1,1:c-b),zeros(1:2)];
                end
            end
            break
        end

     end

     try
     Load_ct =  t2(a)/ct;
     catch
         Load_ct=0;
     end

     try
     Load_2ct = t2(b)/(2*ct);
     catch
         Load_2ct=0;
     end

     try
     Load_3ct = t2(c)/(3*ct);
     catch
         Load_3ct=0;
     end

     % try
     % Load_ct =  sum(ave_time(plan1(wc1,1:a),1))/ct;
     % catch
     %     Load_ct=0;
     % end
     % try
     % Load_2ct = (Load_ct*ct+sum(ave_time(plan2(wc1,1:b-a),1)))/(2*ct);
     % catch
     %     Load_2ct=0;
     % end
     % try
     % Load_3ct = (Load_2ct*2*ct+sum(ave_time(plan3(wc1,1:c-b),1)))/(3*ct);
     % catch
     %     Load_3ct=0;
     % end

     % Load_ct =  sum(ave_time(plan1(wc1,1:a),1))/ct;
     % Load_2ct = (sum(ave_time(plan1(wc1,1:a),1))+sum(ave_time(plan2(wc1,1:b-a),1)))/(2*ct);
     % Load_3ct = (sum(ave_time(plan1(wc1,1:a),1))+sum(ave_time(plan2(wc1,1:b-a),1))+sum(ave_time(plan3(wc1,1:c-b),1)))/(3*ct);
     Load = [Load_ct,Load_2ct,Load_3ct];
     [~, idx] = max(Load);
     if idx == 1
        plan{1,wc} = plan1(wc1,1:a);
        abc_max=Current_task_order1+1;
        a=0;
        b=0;
        c=0;
        n=0;
        u=0;
        p=0;
        break
     end
     if idx == 2
         try
        plan{1,wc} = [plan1(wc1,1:a),plan2(wc1,1:b-a),zeros(1:1)];
         catch
        plan{1,wc} = [plan2(wc1,1:b-a),zeros(1:1)];
         end
        abc_max=Current_task_order2+1;
        a=0;
        b=0;
        c=0;
        n=0;
        u=0;
        p=0;
        break
     end
     if idx == 3
         try
        plan{1,wc} = [plan1(wc1,1:a),plan2(wc1,1:b-a),plan3(wc1,1:c-b),zeros(1:2)];
         catch
             try
                 plan{1,wc} = [plan2(wc1,1:b-a),plan3(wc1,1:c-b),zeros(1:2)];
             catch
                 plan{1,wc} = [plan3(wc1,1:c-b),zeros(1:2)];
             end
         end
        abc_max=Current_task_order3+1;
        a=0;
        b=0;
        c=0;
        n=0;
        u=0;
        p=0;
        break
     end
 end
 if j==size(FAST,2)
    break
 end
end

if ~isempty (last)

   plan{1,wc} = last;

end

end


