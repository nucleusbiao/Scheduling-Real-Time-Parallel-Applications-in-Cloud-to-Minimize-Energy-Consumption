function data=setupDataExample(numServer)
%Set up the DAG model example data,
%The number of layers in the DAG is 4, and the total number of tasks is 10.
level = 4; %Number of levels of tasks
taskLevelArray = [0, 1]; %
preAftTaskMax = 6; % Maximum number of tasks per layer
%-------------------Generate the level layer DAG, and find out the task with the constraint of each task successively,start----------------------------------%
%Four rows and two columns, with the number of rows representing the task layer, the first column representing the starting task number of the layer, and the second column representing the number of tasks of the layer
taskLevelArray = [0 1; 1 5; 6 3; 9 1];
%Number of jobs
numTask = taskLevelArray(end,1) + 1;
%Represents the transfer time between tasks
DAG_Matrix = zeros(numTask, numTask) - 1;

% Set the task dependency. DAG_Matrix(i,j) = 1 denotes that task 
DAG_Matrix(1,2) = 1;
DAG_Matrix(1,3) = 1;
DAG_Matrix(1,4) = 1;
DAG_Matrix(1,5) = 1;
DAG_Matrix(1,6) = 1;
DAG_Matrix(2,8) = 1;
DAG_Matrix(2,9) = 1;
DAG_Matrix(3,7) = 1;
DAG_Matrix(4,8) = 1;
DAG_Matrix(4,9) = 1;
DAG_Matrix(5,9) = 1;
DAG_Matrix(6,8) = 1;
DAG_Matrix(7,10) = 1;
DAG_Matrix(8,10) = 1;
DAG_Matrix(9,10) = 1;
%Represents the sequential constraint relationship of tasks
aftArray = zeros(numTask,preAftTaskMax+1);
preArray = zeros(numTask,preAftTaskMax+1);
for i = 1:size(DAG_Matrix, 1)
    count = 1;
    for j = 1:size(DAG_Matrix, 1)
        if DAG_Matrix(i,j) > 0
            aftArray(i,count) = j;
            count = count + 1;
        end
    end
end

for i = 1:size(DAG_Matrix, 2)
    count = 1;
    for j = 1:size(DAG_Matrix, 1)
        if DAG_Matrix(j,i) > 0
            preArray(i,count) = j;
            count = count + 1;
        end
    end
end
data.pre = preArray;
data.aft = aftArray;
%-------------------Generate the level layer DAG, and find out the tasks with the sequentially constrained tasks of each task£¬finish----------------------------------%
% data.lamda=randi([5 10],numTask,numServer)/10;
% data.alpha=randi([5 10],numTask,numServer)/10;
 data.l=randi([2 5],numTask,1)*100;
data.c=randi([2 5],numServer,1)*100;
%lamda,The smaller the lamda, the less efficient the process
data.lamda=[0.9 0.8 0.7;
           0.9 0.6 0.5; 
            0.5 0.6 0.5; 
           0.8 0.9 0.5; 
           0.7 0.6 0.9; 
           1.0 0.7 0.8; 
          0.5 0.9 0.7;
            0.6 0.6 0.9; 
         0.6 0.9 0.6; 
            0.5 1.0 1.0; ];
  %alpha,The smaller the alpha, the lower the power consumption
        data.alpha=[0.7 0.7 0.6;
           0.5 1.0 0.7; 
           0.6 0.9 0.6; 
           1.0  1.0 1.0; 
           0.5 0.5 0.7; 
          1.0 0.7 0.8;
            0.5 0.7 0.8;
            0.5 0.7 1.0;
          0.7 0.5 1.0; 
            0.8 0.5 0.7; ];
        %Task load
        data.l=[200 300 400 200 300 500 200 400 500 500];
for i=1:level
    data.level(i,:)=[taskLevelArray(i,1)+1 taskLevelArray(i,1)+taskLevelArray(i,2)];
end
% resource constraints
%Number of resource types
data.resType = 7;
%data.resCon = randi([2 5],numServer, data.resType)*100;
%Bj,k
data.resCon=[200 300 300 300 500 300 300;
    200 300 300 500 500 300 500;
    400 300 200 400 300 200 200];
%data.resConPara = randi(10, numServer, data.resType)/10;
%Aj,k
data.resConPara=[0.2 0.8 0.8 1.0 0.3 0.7 0.2;
    0.9 0.8 0.1 0.5 0.9 0.6 1.0;
    0.4 0.7 0.4 0.9 0.5 0.3 1.0];
    