function xij=getxij(l,info)

xij=zeros((info.m)^l,l);
for i=1:l
    for j=1:info.m
        xij((j-1)*(info.m)^(l-i)+1:j*(info.m)^(l-i),i)=j;
    end
end
for i=2:l
    xij(:,i)=repmat(xij(1:info.m^(l-i+1),i)',1,info.m^(i-1))';
end