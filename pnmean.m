% This code is written by Ankur Kumar, DD Imaging Lab, Physics, IIT Roorkee
% Code to average only positive or negative values in an array.
% Set type=1 for positive data mean and 0 for negative data mean.
function pnmean=pnmean(data,type)
length_data=length(data);
m=1;n=1;pos_data=[];
for i=1:length_data
    if data(i)>=0
        pos_data(m)=data(i);
        m=m+1;
    else
        neg_data(n)=data(i);
        n=n+1;
    end
end
if type==1
    pnmean=mean(pos_data);
else
    pnmean=mean(neg_data);
end
end