function scheduleO = taskMoveFuc(info, data, scheduleI)
%function acording algorithm 3, keeps the processor in place and determines the earliest start time
%of each task according to the priority relationship of the task and the available time of the processor
levelNum = size(scheduleI.etMatrixServerLevel, 2);
etMatrix = zeros(info.m, levelNum);
for levelIndex = 1:levelNum
    %calculate task complete time based level
    for serverIndex = 1:info.m
        taskArray = scheduleI.ServerLevel{serverIndex}{levelIndex};        
        if isempty(taskArray) && levelIndex > 1
            etMatrix(serverIndex, levelIndex) = etMatrix(serverIndex, levelIndex-1); 
        elseif ~isempty(taskArray)
            taskID = taskArray(1,1);            
            etMatrix(serverIndex, levelIndex) = scheduleI.st(taskID) + scheduleI.et(taskID);
        end
    end
end

for levelIndex = 2:levelNum
    for serverIndex = 1:info.m
        taskArray = scheduleI.ServerLevel{serverIndex}{levelIndex};
        if ~isempty(taskArray)
            taskIDst = [];
            for iTask = 1:size(taskArray, 2)
                taskID = taskArray(1, iTask);
                preTaskArray = data.pre(taskID, :);
                taskIDstTemp = 0;
                %calculate the earliest start time for a task to satisfy a sequence constraint
                for iPre = 1:size(preTaskArray, 2)
                    if eq(preTaskArray(iPre), 0)
                        break
                    else
                        taskPreID = preTaskArray(iPre);
                        timeTemp = scheduleI.st(taskPreID) + scheduleI.et(taskPreID);
                        taskIDstTemp = max(taskIDstTemp, timeTemp);
                    end
                end
                taskIDst = [taskIDst, [taskID; taskIDstTemp]];
            end
            [value, sortAscendTask] = sort(taskIDst(2,:), 'ascend');
            availTime = etMatrix(serverIndex, levelIndex-1);
            for indexSort = 1:size(sortAscendTask, 2)
                indexSortID = sortAscendTask(indexSort);
                taskID = taskIDst(1, indexSortID);
                availTimeTask = taskIDst(2, indexSortID);
                Lt = data.l(taskID)/data.lamda(taskID, serverIndex);
                %Allocate the computing resource to Ti according to (14)
                taskIDet = Lt*max(data.resConPara(serverIndex,:)./data.resCon(serverIndex,:));                
                availTime = max(availTime, availTimeTask);
                scheduleI.st(taskID) = availTime;
                scheduleI.et(taskID) = taskIDet;
                %Processor allowed schedul time
                availTime = availTime + taskIDet;
            end
            etFlag = etMatrix(serverIndex, levelIndex);
            for lel = levelIndex:levelNum
                %If no tasks are placed at this layer on the processor, the available time of the processor is the same as at the previous layer
                if eq(etFlag, etMatrix(serverIndex, lel))
                    etMatrix(serverIndex, lel) = availTime;
                else
                    break
                end
            end
        end
    end
end
scheduleO = scheduleI;