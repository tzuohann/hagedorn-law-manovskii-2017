function L = getIEmps(L,C,SimO)
  %Obtain L.WFCA which we will use later.
  MaxEmps       = tabulate(L.WFCA(:,1));
  L.MaxEmps     = int32(max(MaxEmps(:,2)));
  
  %Ranking algorithm requires all workers to have some employment, so,
  %for unrankable workers, we simply generate some unique firm where they
  %are observed to be the only worker for 1 period. This does not affect
  %the ranking algorithm.
  Empty         = nonzeros(SimO.iNames.*double(full(sum(L.iAvWageCount,2)) == 0));
  Empty         = [Empty,SimO.Numj + Empty,ones(size(Empty)),zeros(size(Empty))];
  L.WFCA        = sortrows([L.WFCA;Empty],[1 2]);
  
  %This tells us where to compare the firms of workers
  [~,I,~]           = unique(L.WFCA(:,1));
  
  %We want I to read the number of firms.
  Iuniq                 = int32([0;I]);
  
  NiEmps = nan(C.NumAgentsSim,1);
  JiEmps = nan(C.NumAgentsSim,L.MaxEmps);
  for i1 = 1:C.NumAgentsSim
    NiEmps(i1,1)              = Iuniq(i1+1)-Iuniq(i1);
    JiEmps(i1,1:NiEmps(i1,1)) = L.WFCA(Iuniq(i1)+1:Iuniq(i1+1),2);
  end
  
  %Set the workers who don't actually work back to zero.
  NiEmps(Empty(:,1))          = 0;
  JiEmps(Empty(:,1),:)        = nan;
  
  WFCA = sortrows(L.WFCA(:,1:2),[2,1]);
  [~,I,~] = unique(WFCA(:,2));
  if numel(I) < SimO.Numj
    error('Some firm never hires')
  end
  I = [0;I];
  NjWorkers = nan(SimO.Numj,1);
  for i1 = 1:SimO.Numj
    NjWorkers(i1,1)                 = I(i1+1) - I(i1);
  end
  L.NiEmps    = NiEmps;
  L.JiEmps    = JiEmps;
  L.NjWorkers = NjWorkers; 
end
