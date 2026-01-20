
function [lineconfi,demance]= GA_SABLA_best_solution(solution,Instance,best_code2)
[FAST]       = seq_to_FAST(solution);
[plan]       = line_decode1(FAST,Instance);
wc           = size(plan,2);
demance      = best_code2(wc:end);
if length(demance) ~= max(6,length(Instance.Demance))
     disp(error,'错误');
end
bufset       = [0,best_code2(1:(wc-1))]';
WC = ones(size(plan,2),1);
assign_task                = zeros(1);
for j = 1:size(plan,2)
    assign_plan        = [plan{1,j}];
    a                  = sum(assign_plan==0);
    WC(j)              = WC(j)+a;
    assign_plan        = assign_plan(assign_plan ~=0 );

    for i =1:size(assign_plan,2)
        assign_task(j,i) = assign_plan(1,i);
    end
end

lineconfi               = int32([WC,bufset,assign_task]);
end