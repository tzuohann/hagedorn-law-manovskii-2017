function [I] = simWageStats(Sim,L,C,SimO,I)
  %Compute statistics that are needed for rank aggregation and beyond
  %See user guide/data dictionary for more information.
  
  display('simWageStats')
  
  AWF               = full(L.iAvWageAtFirm);
  AWF(AWF == 0)     = NaN;
  
  %Expected wages for each worker.
  I.iWExpWage      = nanmean(Sim.SimWage,2);
  
  %Minimum observed wage for each worker.
  I.iWMinWage      = nanmin(AWF,[],2);
  
  %Minimum observed wage for each worker.
  I.iWMaxWage      = nanmax(AWF,[],2);
  
  %Calculate the adjusted average wage.
  FirstWage                       = double(Sim.SimJobName);
  FirstWage(Sim.SimJobName == 0)  = nan;
  for i1 = C.Periods:-1:2
    TempXX                = ~isnan(FirstWage(:,i1-1));
    FirstWage(TempXX,i1)  = nan;
  end
  %Do this so that while the sample is shorter than 20 years, it is not
  %biased. Otherwise, it becomes biased since the initial employment that
  %is out of unemployment has too much weight.
  FirstWage(:,1)                  = NaN;
  FirstWage(Sim.SimJobName == 0)  = 0;
  
  %Replace the job id with the firm (j) name.
  %Just use wages from L since those are out of unemployment wherever
  %Adjust average wages apply.
  FirstWage(FirstWage > 0)        = SimO.JobNamej(FirstWage(FirstWage > 0));
  
  [wN,pT,fN]   = find(max(FirstWage,0));
  FirstWage(sub2ind(size(FirstWage),wN,pT)) = L.iAvWageAtFirm(sub2ind(size(L.iAvWageAtFirm),wN,fN));
  [wN,pT]   = find(FirstWage == 0);
  FirstWage(sub2ind(size(FirstWage),wN,pT)) = I.iWMinWage(wN);
  
  %Replace the locations of exiting unemployment with the corresponding average wage the workers gets with the firm the worker exited unemployment with.
  I.iAdAvWage                     = nanmean(FirstWage,2);
  I.iAdAvWage(isnan(I.iAdAvWage)) = I.iWExpWage((isnan(I.iAdAvWage)));
  
  %These are the different rankings using different methods.
  I.iNRAdAv     = getRankBy(SimO.iNames,I.iAdAvWage);
  I.iNRMax      = getRankBy(SimO.iNames,I.iWMaxWage);
  I.iNRMin      = getRankBy(SimO.iNames,I.iWMinWage);
  I.iNRExpW     = getRankBy(SimO.iNames,I.iWExpWage);
end
