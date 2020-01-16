% Author: Biao Hu
% Date: 2020-01-16

clear
clc
close all

numServer = 3;
data=setupDataExample(numServer);
info.n = size(data.l,2);%Number of jobs
info.m = numServer;%Number of servers

%%%Algorithm 1 Partition Scheduling
sch=forwardlelSch(info,data);
energy1 = sch.e;
makespan1 = sch.makespan;
figure
gantt(sch,info)
%%
%estimated the biggest makespan
info.t=sch.makespan*0.7;
% when schedule  not meet real-time requirement
sch2=heuristicLelSch(info,data,sch);
energy2 = sch2.e;
makespan2 = sch2.makespan;

figure
hold on
gantt(sch2,info)

%%
if sch.makespan<info.t
    disp('Complete the scheduling')
else
    sch3=backwardlelSch(info,data,sch); % schedule adjustment in a backward way.
    energy3 = sch3.e;
    makespan3 = sch3.makespan;
    figure
    hold on
    gantt(sch3, info)
end