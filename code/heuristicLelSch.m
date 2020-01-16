function schOutput = heuristicLelSch(info, data, schInput)
%This function shows the task adjustment strategy, 
%first of all, find the task with the actual maximum completion time for
%each layer,then  according to the definition 2,
%Generate the task migration matrix, according to the ratio of the energy
%increase to the processing time decrease when the bottleneck task migrating
% update the migration matrix, when meet the time requirements and end  the algorithm.
schedule = schInput;
matrixTaskMig = taskServerMigFuc(info, data, schedule);

while 1
    [value, taskLevel] = min(matrixTaskMig(:,end));
    %When no task exists that can be migrated, algorithm 3 is used to further reduce the completion time
    if value > 1e9
        figure
        gantt(schedule,info)
        makespanBeforeAdj = schedule.st(end) + schedule.et(end);
        schedule = taskMoveFuc(info, data, schedule);% algorithm 3
        schedule.e = 0;
        for i=1:info.n
            schedule.e=schedule.e+data.alpha(i,schedule.xij(i))*data.l(i)/data.lamda(i,schedule.xij(i));%Formula3
        end
        schedule.makespan = schedule.st(end) + schedule.et(end);
        if schedule.makespan > info.t
            display('failure!');
        else
            display('successType2!');
        end
        break
    end
    taskID = matrixTaskMig(taskLevel, 1);
    serverFrom = matrixTaskMig(taskLevel, 2);
    serverTarget = matrixTaskMig(taskLevel, 3);
    %Migrates tasks that need to be moved on the processor, updates completion time and processor placement
    schedule = updateScheduleFuc(info, data, schedule, taskID, taskLevel, serverFrom, serverTarget);
    if schedule.st(end) + schedule.et(end) < info.t
        schedule.e = 0;
        %Calculate the total energy consumed
        for i=1:info.n
            schedule.e=schedule.e+data.alpha(i,schedule.xij(i))*data.l(i)/data.lamda(i,schedule.xij(i));
        end
        schedule.makespan = schedule.st(end) + schedule.et(end);
        display('successType1!');
        break
    end
    %update bottlencck task matrix
    matrixTaskMig = updateMatrixTaskMigFuc(info, data, schedule, matrixTaskMig, taskLevel)
end
schOutput = schedule;
