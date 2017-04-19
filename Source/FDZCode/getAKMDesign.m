%Construct design matrix with worker and firm dummies variables
function [X,D,F] = getAKMDesign(data)

y=data(:,1);
id=data(:,2);
firmid=data(:,3);

%relabel the workers
[~,~,id]=unique(id);

%relabel firms
[~,~,firmid]=unique(firmid);

%ESTIMATE AKM
disp('Building design matrix...')
NT=length(y);

D=sparse(1:NT,id',1);
F=sparse(1:NT,firmid',1);
F(:,end) = [];

X=[D,F];

end

