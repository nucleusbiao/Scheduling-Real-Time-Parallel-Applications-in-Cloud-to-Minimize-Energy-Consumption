function sch=optimalSch(info,data,i,sch)
%According to the assigned server information, the optimal scheduling rule obtains the scheduling plan and time
%Such that the artifacts arranged on the same server have equal completion times and are equal to the machine's total discounted load divided by the machine's capacity
level = i;
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
xij=sch.xij;
%Initializes the array of structures,save the task placement as a structured array
mab=cell(1,info.m);
for i=1:length(ID)
    for j=1:info.m
        if xij(ID(i))==j
            mab{j}=[mab{j} ID(i)];
        end
    end
end

mkMax = 0;
% Calculate the start time and execution time of all tasks placed on each layer of processor i by formula  11
for i=1:info.m
    if ~isempty(mab{i})        
        for j=1:length(mab{i})
            taskID = mab{i}(j);
            iServer = sch.xij(taskID);
            [value, indexMin] = min(data.resCon(i,:)./sch.PLmatrix(level, :, iServer));%The formula  11
            mkMax = max(mkMax, 1/value);
            sch.st(mab{i}(j)) = sch.makespan;            
            sch.et(mab{i}(j)) = 1/value;
            sch.ServerLevel{i}{level} = [sch.ServerLevel{i}{level}, [mab{i}(j); 1/value]];
        end
        %The execution time of each task per layer
        sch.etMatrixServerLevel(i,level) = 1/value;
    else
        sch.mt(i)=sch.makespan;
    end
end
sch.makespan = sch.makespan + mkMax;
sch.mt=max(sch.makespan);