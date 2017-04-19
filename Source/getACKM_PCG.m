function [AKM]        = getACKM_PCG(Sim,C,SimO)
 
  addpath('Source\matlab_bgl\');
  
  %This assumes connectedness is not an issue
  Wage                 = log(Sim.SimWage);
  Wage(isnan(Wage))    = 0;
  [WID,FID,Wage]       = find(Wage);
  FID                  = Sim.SimJobName(sub2ind(size(Sim.SimJobName),WID,FID));
  FID                  = SimO.JobNamej(FID);
 
  WFW             = sortrows([WID,FID,Wage],1);
  WID             = WFW(:,1);
  Wage            = WFW(:,3);
  FID             = WFW(:,2);
  WIDlead         = [WID(2:end);nan];
  FIDlead         = [FID(2:end);nan];
  FIDlead(WIDlead ~= WID) = nan;
  FIDlead         = [FID,FIDlead];
  FIDlead         = FIDlead(sum(~isnan(FIDlead),2) == 2,:);
  FIDCon          = unique(FIDlead(FIDlead(:,1) ~= FIDlead(:,2),:),'rows');
  
  %FIND CONNECTED SET
  maxsize     = max(max(WID),max(FID));
  disp('Finding connected set...')
  A = logical(sparse(FIDCon(:,1),FIDCon(:,2),1,maxsize,maxsize)); %adjacency matrix
  A = (A+A') > 0; %connections are undirected
  
  %Largest connected set 
  [sindex, sz]  = components(A); %get connected sets
  idx           = find(sz==max(sz)); %find largest set
  firmlst       = find(sindex==idx); %firms in connected set
  WFW           = WFW(ismember(WFW(:,2),firmlst),:);
  WID           = WFW(:,1);
  FID           = WFW(:,2);
  Wage          = WFW(:,3);
  
  %ESTIMATE AKM
  NT=length(WID);
  N=max(WID);
  J=max(FID);
  D=sparse(vec(1:NT),WID,1);
  F=sparse(vec(1:NT),FID,1);
  
  S=speye(J-1);
  S=[S;sparse(-zeros(1,J-1))];  %N+JxN+J-1 restriction matrix
  X=[D,F*S];
  
  xx=X'*X;
  xy=X'*Wage;
  L=ichol(xx,struct('type','ict','droptol',1e-2,'diagcomp',.1));
  b=pcg(xx,xy,1e-10,1000,L,L');
  
  %ANALYZE RESULTS
  xb=X*b;
  r=Wage-xb;
  
  ahat=b(1:N);
  ghat=b(N+1:N+J-1);
  
  pe=D*ahat;
  fe=F*S*ghat;
  
  AKM.RankCorr  = corr(pe,fe,'type','spearman');
  AKM.Corr      = corr(pe,fe,'type','pearson');
end
