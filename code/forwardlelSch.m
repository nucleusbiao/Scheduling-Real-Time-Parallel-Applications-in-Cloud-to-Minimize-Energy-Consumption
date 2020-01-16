function sch=forwardlelSch(info,data)
%function first according to theorem one:the energy consumption of task Ti only depends on its placement select the task placement, 
%Then, according to the theorem two proportional allocation of computing resources.


temp=zeros(1,info.m);
%Initialize task placement
xij=zeros(1,info.n);
numLevel=size(data.level,1);
%For each task,according to the Formula 9, find min e processor according to theorem 1
for i=1:info.n
    for j=1:info.m
        temp(j)=data.alpha(i,j)/data.lamda(i,j);
    end
    [~,xij(i)]=min(temp);
end

timeRef = 0;
sch.xij=xij;
%Hierarchical scheduling, each layer has the same scheduling start time and end time
%according formulas 1 and 11,allocation  computing resources
% and Calculate the execution time for each task
%The completion time of each layer is the maximum completion time of the tasks of that layer
for iNumLevel = 1:numLevel
    taskIDarray = data.level(iNumLevel,1):data.level(iNumLevel,2);
    timeServerMax = 0;
    for iServer = 1:info.m
        timeServer = 0;
        for iTaskPerLevel = 1:size(taskIDarray, 2)
            taskID = taskIDarray(iTaskPerLevel);
            if eq(iServer, xij(taskID))
                Lt = data.l(taskID)/data.lamda(taskID, xij(taskID));
                timeMaxTemp = Lt*max(data.resConPara(xij(taskID),:)./data.resCon(xij(taskID),:));%Formulas  11
                timeServer = timeServer + timeMaxTemp;
            end
        end
        timeServerMax = max(timeServerMax, timeServer);
    end
    timeRef = timeRef + timeServerMax;
end


% Schedule completion time
sch.makeSpanRef = timeRef;
%Initializes the coefficient matrix for calculating the execution time
PLmatrix = zeros(numLevel, data.resType, info.m);
%Calculate the coefficient matrix for the calculation execution layer by
%layer according to theorem 2
for iNumLevel = 1:numLevel
    taskIDarray = data.level(iNumLevel,1):data.level(iNumLevel,2);
    for iResType = 1:data.resType
        for iServer = 1:info.m
            temp = 0;
            for iTaskPerLevel = 1:size(taskIDarray, 2)
                taskID = taskIDarray(iTaskPerLevel);
                if eq(xij(taskID), iServer)
                    Lt = data.l(taskID)/data.lamda(taskID, xij(taskID));
                    temp = temp + data.resConPara(xij(taskID), iResType)*Lt;%Formulas 11
                end
            end
            PLmatrix(iNumLevel, iResType, iServer) = temp;
        end
    end
end
sch.PLmatrix = PLmatrix;
sch.etMatrixServerLevel = zeros(info.m, numLevel);
%Save the execution time of the tasks by the index of processor and the index of task layers
for i = 1:info.m
    for j = 1:numLevel
        sch.ServerLevel{i}{j} = [];%{core}{level}
    end
end

for i=1:numLevel
    sch=optimalSch(info,data,i,sch);
end
sch.e=0;

for i=1:info.n
    sch.e=sch.e+data.alpha(i,sch.xij(i))*data.l(i)/data.lamda(i,sch.xij(i));%The formula 3
end