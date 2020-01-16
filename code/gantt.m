function gantt(sch,info)

if length(inputname(1))==3
    ylim([0 inf])
    xlabel('ct')
else
    ylim([0 inf])
    xlabel('ct')
end

for i=1:info.n
    rec(1) = sch.st(i);%The abscissa of the rectangle
    rec(2) = sch.xij(i)-.3;  %The vertical of the rectangle
    rec(3) = sch.et(i);  %The X-axis length of the rectangle
    rec(4) = 0.6;
    if info.m<=7
        rectangle('Position',rec,'LineWidth',0.5,'LineStyle','-','FaceColor','w');%draw every rectangle
    else
        rectangle('Position',rec,'LineWidth',0.5,'LineStyle','-','FaceColor','w');
    end
    hold on
end

for i=1:info.n
    txt=sprintf('(T%d)',i);
    text(sch.st(i),sch.xij(i),txt,'FontWeight','Bold','FontSize',11);
    hold on
end
hold off