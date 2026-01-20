%% 效率并行，只到4变3
function [plan] = short_wc_num(plan,b_wc_time,ct)
plan2 = plan;
b_wc_time1 = b_wc_time;
pra2_1 = 0;
while ~isempty(pra2_1)
%超节拍工作站的合并
%有并行的两个合并
pra2_1 = [];
for i1 = 1:size(plan2,2)-1
    a1 = b_wc_time1(1,i1);
    a2 = b_wc_time1(1,i1+1);
    wc_2 = sum(plan2{1,i1}==0)+sum(plan2{1,i1+1}==0);
    if  (a1+a2) <= (1+wc_2)*ct
        pra2_1 = [pra2_1 , i1];
    end
end
% 若有提升效率的
if size(pra2_1,2) > 0
    for i2 = pra2_1
        if b_wc_time1(1,i2:i2+1) ~=0
            plan2{1,i2} = [plan2{1,i2},plan2{1,i2+1}];
            plan2{1,i2+1} = 0;
            b_wc_time1(1,i2) = sum(b_wc_time1(1,i2:i2+1),2);
            b_wc_time1(1,i2+1) = 0;
        end
    end
    %并行结果合并
    plan1 = [];
    ii = 1;
    for j = 1:size(plan2,2)
        %检查是否已经被拉去并行
        if sum(plan2{1,j}) ~= 0
            plan1 {1,ii}                = [plan2{1,j}];
            ii                          = ii+1;
        else
            continue;
        end
    end
    b_wc_time1                         = b_wc_time1(b_wc_time1~=0);
    plan2                                = plan1;
end
end

%% 检查是否有满足提高效率的3变2
pra3_2 = [];
for i1 = 1:size(plan2,2)-2
    a1 = b_wc_time1(1,i1);
    a2 = b_wc_time1(1,i1+1);
    a3 = b_wc_time1(1,i1+2);
    if  (a1+a2+a3) <= (2)*ct 
        pra3_2 = [pra3_2 , i1];
    end
end
% 若有提升效率的
if size(pra3_2,2) > 0
    for i2 = pra3_2
        if b_wc_time1(1,i2:i2+2) ~=0
            plan2{1,i2} = [plan2{1,i2},plan2{1,i2+1},plan2{1,i2+2},0];
            plan2{1,i2+1} = 0;
            plan2{1,i2+2} = 0;
            b_wc_time1(1,i2) = sum(b_wc_time1(1,i2:i2+2),2);
            b_wc_time1(1,i2+1) = 0;
            b_wc_time1(1,i2+2) = 0;
        end
    end
    %并行结果合并
    plan1 = [];
    ii = 1;
    for j = 1:size(plan2,2)
        %检查是否已经被拉去并行
        if sum(plan2{1,j}) ~= 0
            plan1 {1,ii}                = [plan2{1,j}];
            ii                          = ii+1;
        else
            continue;
        end
    end
    b_wc_time1                         = b_wc_time1(b_wc_time1~=0);
    plan2                                = plan1;
end
%% 4 变3
pra4_3 = [];
for i1 = 1:size(plan2,2)-3
    a1 = b_wc_time1(1,i1);
    a2 = b_wc_time1(1,i1+1);
    a3 = b_wc_time1(1,i1+2);
    a4 = b_wc_time1(1,i1+3);
    if  (a1+a2+a3+a4) <= (3)*ct
        pra4_3 = [pra4_3 , i1];
    end
end
% 若有提升效率的
if size(pra4_3,2) > 0
    for i2 = pra4_3
        if b_wc_time1(1,i2:i2+3) ~=0
            plan2{1,i2} = [plan2{1,i2},plan2{1,i2+1},plan2{1,i2+2},plan2{1,i2+3},0,0];
            plan2{1,i2+1} = 0;
            plan2{1,i2+2} = 0;
            plan2{1,i2+3} = 0;
            b_wc_time1(1,i2) = sum(b_wc_time1(1,i2:i2+3),2);
            b_wc_time1(1,i2+1) = 0;
            b_wc_time1(1,i2+2) = 0;
            b_wc_time1(1,i2+3) = 0;
        end
    end
    %并行结果合并
    ii = 1;
    plan1 = [];
    for j = 1:size(plan2,2)
        %检查是否已经被拉去并行
        if sum(plan2{1,j}) ~= 0
            plan1 {1,ii}                = [plan2{1,j}];
            ii                          = ii+1;
        else
            continue;
        end
    end
    b_wc_time1                         = b_wc_time1(b_wc_time1~=0);
    plan2                              = plan1;
end

%%
plan   = plan2;
b_wc_time = b_wc_time1;

end