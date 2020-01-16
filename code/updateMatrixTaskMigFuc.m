function matrixOutput = updateMatrixTaskMigFuc(info, data, schedule, matrixInput, taskLevel)
%Update the migration matrix according to formula 12
matrix = matrixInput;
levelNum = size(schedule.etMatrixServerLevel, 2);

for i = 1:levelNum
    if eq(i, taskLevel)
        [timeRef, coreIndex] = max(schedule.etMatrixServerLevel(:,i));
        taskMaxEtLevel = schedule.ServerLevel{coreIndex}{i}(1,:);
        timeEnergyCoeffFlag = inf;
        serverMigrationFrom = coreIndex;
        serverMigrationTo = coreIndex;
        for j = 1:size(taskMaxEtLevel, 2)
            taskID = taskMaxEtLevel(j);
            energyRef = data.alpha(taskID,coreIndex)*data.l(taskID)/data.lamda(taskID,coreIndex);
        Lt = data.l(taskID)/data.lamda(taskID, coreIndex);
        timeReduction = Lt*max(data.resConPara(coreIndex,:)./data.resCon(coreIndex,:));
        
        timeServerFrom = timeRef - timeReduction;
            for k = 1:info.m
                if ~eq(coreIndex, k)
                    energyNew = data.alpha(taskID,k)*data.l(taskID)/data.lamda(taskID,k);
                    Lt = data.l(taskID)/data.lamda(taskID, k);
                    timeIncrease = Lt*max(data.resConPara(k,:)./data.resCon(k,:));
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
        if timeEnergyCoeffFlag > 1e9
            matrix(i,:) = [taskID, serverMigrationFrom, serverMigrationTo, timeEnergyCoeffFlag];
        else
            matrix(i,:) = [taskChosenIndix, serverMigrationFrom, serverMigrationTo, timeEnergyCoeffFlag];
        end
    end
end
matrixOutput = matrix;