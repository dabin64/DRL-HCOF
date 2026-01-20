%%解码，得到产线配置
% 修改finally2
%函数输入：序列
%函数输出：产线配置方案
function [plan]= line_decode1(seq,Instance_all)

[FAST]= seq_to_FAST(seq);
plan   = [];
ct = Instance_all.CT;
b = 0;
x = [];
wc = 1;
b_wc_time = [];
ave_time = Instance_all.Ave_Task_time;
for j = 1:size(FAST,2)
    a = FAST(1,j);
    %没有考虑到一个任务就超过工作时间的情况
    if j == 1
        b = b + ave_time(FAST(1,j),1);
        b_wc_time(1,wc) = b;
        x = [x,a];
        plan{1,wc} = x;
        continue;
    end
    if (b + ave_time(FAST(1,j),1) <= ct)%每个装配线的时间小于节拍
        b = b + ave_time(FAST(1,j),1);
        b_wc_time(1,wc) = b;
        x = [x,a];
        plan{1,wc} = x;
        if j ~= size(FAST,2)
            continue;
        end
    end    
    plan{1,wc} = x;
    wc = wc+1;
    if j == size(FAST,2) && sum(x == a(a~=0)) ~=1  %最后一个任务有没有分配isempty(find(x==a))
        plan{1,wc} = a;
        b = ave_time(FAST(1,j),1);
        b_wc_time(1,wc) = b;
    end
    if j ~= size(FAST,2)
        b = ave_time(FAST(1,j),1);
        b_wc_time(1,wc) = b;
        x = [a];
    end
end

%修改，看看是否有超的工作站
for ii = 1:size(plan,2)
    a = ceil(b_wc_time(1,ii)/ct)-1;%最少1，
     if a ~= 0
         plan{1,ii} = [plan{1,ii},zeros(1,a)];%补上并行
     end
 end

% 效率并行
[plan] = short_wc_num(plan,b_wc_time,ct);

end





