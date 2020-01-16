function matrix = taskServerMigFuc(info, data, schedule)
%this function find bottlencck task matrix by Formula 12,13
levelNum = size(schedule.etMatrixServerLevel, 2);%level numbers
%Initializes the migration matrix
matrix = zeros(levelNum, 4);
for i = 1:levelNum
    %calculate by Formula 12
    [timeRef, coreIndex] = max(schedule.etMatrixServerLevel(:,i));
    taskMaxEtLevel = schedule.ServerLevel{coreIndex}{i}(1,:);
    timeEnergyCoeffFlag = inf;
    serverMigrationFrom = coreIndex;
    serverMigrationTo = coreIndex;  
    for j = 1:size(taskMaxEtLevel, 2)
        %Calculates the execution time of the original processor after the bottleneck task is moved out
        taskID = taskMaxEtLevel(j);
        energyRef = data.alpha(taskID,coreIndex)*data.l(taskID)/data.lamda(taskID,coreIndex);
        Lt(taskID) = data.l(taskID)/data.lamda(taskID, coreIndex);
        timeReduction = Lt(taskID)*max(data.resConPara(coreIndex,:)./data.resCon(coreIndex,:));
        timeServerFrom = timeRef - timeReduction;
        for k = 1:info.m
            %The execution time of the target processor is calculated separately 
            %when the task is migrated to a different processor than the original processor
            if ~eq(coreIndex, k)
                energyNew = data.alpha(taskID,k)*data.l(taskID)/data.lamda(taskID,k);
                Lt(taskID) = data.l(taskID)/data.lamda(taskID, k);
                timeIncrease = Lt(taskID)*max(data.resConPara(k,:)./data.resCon(k,:));
                timeNewTemp = schedule.etMatrixServerLevel(k, i) + timeIncrease;    
                timeNew = max(timeServerFrom, timeNewTemp);
                for kk = 1:info.m
                    if ~eq(kk, k) && ~eq(kk, coreIndex)
                        timeArray = schedule.ServerLevel{kk}{i};
                        if ~isempty(timeArray)
                            timeNew = max(timeNew, timeArray(2,1));
                        end
                    end
                end
                %Formula 12,Calculate the ratio of energy increase to time decrease after migration
                if timeRef > timeNew
                    timeEnergyCoeff = (energyNew - energyRef)/(timeRef - timeNew);
                    if timeEnergyCoeff < timeEnergyCoeffFlag
                        timeEnergyCoeffFlag = timeEnergyCoeff;
                        taskChosenIndix= taskID;
                        serverMigrationFrom = coreIndex;
                        serverMigrationTo = k;
                    end
                else
                    timeEnergyCoeff = -1;
                end
            end
        end
    end
    %Generate the migration matrix, formula 13
    if timeEnergyCoeffFlag > 1e9
        matrix(i,:) = [taskID, serverMigrationFrom, serverMigrationTo, timeEnergyCoeffFlag];
    else
        matrix(i,:) = [taskChosenIndix, serverMigrationFrom, serverMigrationTo, timeEnergyCoeffFlag];
    end
end