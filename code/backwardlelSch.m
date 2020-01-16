function sch2=backwardlelSch(info,data,sch)
%If the schedule from Algorithm 2 has
%already met the real-time constraint, tasks are progressively returned to their previous servers. Every time a task
%is returned, the schedule is tested whether the task start
%time adjustment is able to meet the timing requirement. If
%so, tasks are returned continuously. Otherwise, the task is
%stopped from returning
if sch.makespan<=info.t
    sch2=sch;
else
    xij=sch.xij;
    minxij=xij;
    sch2=sch;
    %Find the solutions that make makespan smaller at each level
    numLevel=size(data.level,1);
    flag=0;
    for i=numLevel:-1:1
        ID_strat=data.level(i,1);
        ID_end=data.level(i,2);
        ID=ID_strat:1:ID_end;
        xij=sch.xij(ID);
        oldtime=gettime(info,data,i,sch,xij);
        mintime=oldtime;
        temp=['Proceed to',num2str(i),'Layer, which needs to be calculated',num2str(info.m^length(ID)),'Combinations'];
        disp(temp)
        %Get all the xij permutations and combinations
        xij=getxij(length(ID),info);
        sch2.history{i}=xij;
        for j=1:size(xij,1)
            xijInput = xij(j,:);
            [time, timePerTask]=gettime(info,data,i,sch,xijInput);
            if sch2.makespan+time-oldtime<=info.t
                sch2.xij(ID)=xij(j,:);
                sch2.e=0;
                for k=1:info.n
                    sch2.e=sch2.e+data.alpha(k,sch2.xij(k))*data.l(k)/data.lamda(k,sch2.xij(k));
                end
%                sch2.makespan=sch2.makespan+time-oldtime;
                flag=1;
                if time<mintime
                    mintime=time;
                    minxij(ID)=xij(j,:);
                    sch2.et(ID) = timePerTask(ID);
                end
                break
            end
            if time<mintime
                mintime=time;
                minxij(ID)=xij(j,:);
                sch2.et(ID) = timePerTask(ID);
            end
        end
        
        sch2.xij(ID)=minxij(ID);
        sch2.makespan=sch2.makespan+mintime-oldtime;
        if i < numLevel - 1e-3
            for j = i:1:numLevel-1
                for k = data.level(j+1,1):1:data.level(j+1,2)
                    sch2.st(k) = sch2.st(k) + mintime-oldtime;
                end
            end
        end
        if flag==1
            temp=['on',num2str(i),' layer,the conditions are satisfied '];
            disp('The solution that meets the requirement is found by reverse scheduling')
            disp(temp)
            break
        end
    end
end
if sch2.makespan>info.t
    disp('cant find the right solution')
end
