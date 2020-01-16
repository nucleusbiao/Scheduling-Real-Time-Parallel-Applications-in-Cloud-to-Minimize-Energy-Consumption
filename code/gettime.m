function [time, timePerTask]=gettime(info,data,i,sch,xij)
% Get the layer's execution time for each task and the max completion time
if i==1
    sch.st=zeros(info.n,1);
    sch.et=zeros(info.n,1);
    sch.mt=zeros(info.m,1);
    sch.e=0;
    sch.makespan=0;
end
ID_strat=data.level(i,1);
ID_end=data.level(i,2);
ID=ID_strat:1:ID_end;

%According to the assigned server information, the optimal scheduling rule obtains the scheduling plan and time
%Such that the artifacts arranged on the same server have equal completion times and are equal to the machine's total discounted load divided by the machine's capacity
mab=cell(1,info.m);
for i=1:length(ID)
    for j=1:info.m
        if xij(i)==j
            mab{j}=[mab{j} ID(i)];
        end
    end
end
time=zeros(1,info.m);
timePerTask = [];
for i=1:info.m
    if ~isempty(mab{i})
        temp=0;
        for j=1:length(mab{i})
            temp=temp+data.l(mab{i}(j))/data.lamda(mab{i}(j),i);
        end
        time(i)=temp/data.c(i);
        for j=1:length(mab{i})
            timePerTask(mab{i}(j)) = time(i);
        end
    else
        time(i)=0;
    end
end
time=max(time);