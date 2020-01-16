function schedule = updateScheduleFuc(info, data, schedule, taskID, taskLevel, serverFrom, serverTarget)
%Migrates tasks that need to be moved on the processor, updates completion time and processor placement
schedule.xij(taskID) = serverTarget;
timeBeforeChange = max(schedule.etMatrixServerLevel(:, taskLevel));

for levelIndex = taskLevel:1:size(data.level,1)
    for serverIndex = 1:info.m
        taskArray = schedule.ServerLevel{serverIndex}{levelIndex};
        if eq(levelIndex, taskLevel)
            if eq(serverFrom, serverIndex)
                %Initializes the task time matrix
                temp = [];
                Lt = data.l(taskID)/data.lamda(taskID, serverIndex);
                %New processor execution time, original processor time minus the execution time of the migration task on that processor
                timeNew = taskArray(2,1) - Lt*max(data.resConPara(serverIndex,:)./data.resCon(serverIndex,:));
                taskArray(2,:) = timeNew;
                for ii = 1:size(taskArray, 2)
                    taskIDtemp = taskArray(1,ii);
                    if ~eq(taskIDtemp, taskID)%
                        temp = [temp, taskArray(:, ii)];
                        schedule.et(taskIDtemp) = timeNew;
                    end
                end
                schedule.ServerLevel{serverIndex}{levelIndex} = temp;
                schedule.etMatrixServerLevel(serverFrom, taskLevel) = timeNew;
                %Calculates the execution time of the target processor after migration
            elseif eq(serverTarget, serverIndex)
                if ~isempty(taskArray)
                    Lt = data.l(taskID)/data.lamda(taskID, serverIndex);
                    timeNew = taskArray(2,1) + Lt*max(data.resConPara(serverIndex,:)./data.resCon(serverIndex,:));
                    taskArray(2,:) = timeNew;
                    temp = [taskArray, [taskID; timeNew]];
                else
                    Lt = data.l(taskID)/data.lamda(taskID, serverIndex);
                    timeNew = Lt*max(data.resConPara(serverIndex,:)./data.resCon(serverIndex,:));
                    temp = [taskID; timeNew];
                end
                for ii = 1:size(temp, 2)
                    taskIDtemp = temp(1,ii);                        
                    schedule.et(taskIDtemp) = timeNew;
                end
                schedule.ServerLevel{serverIndex}{levelIndex} = temp;
                schedule.etMatrixServerLevel(serverTarget, taskLevel) = timeNew;
            end
            timeAfterChange = max(schedule.etMatrixServerLevel(:, taskLevel));
            timeReduce = timeBeforeChange - timeAfterChange;
        else
            if ~isempty(taskArray)
                for ii = 1:size(taskArray, 2)
                    taskIDtemp = taskArray(1,ii);
                    schedule.st(taskIDtemp) = schedule.st(taskIDtemp) - timeReduce;
                end
            end
        end
    end    
end
