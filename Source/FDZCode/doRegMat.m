function [L,SigmaNoise_Hat]  = doRegMat(Sim,C)
  %Author: Tzuo Hann Law (tzuohann@gmail.com)
  
  display('doRegMat')
  
%Simulation specific code
%   %%%%%Get the names of workers and the amount they are paid grouped by jobs.
%   HiredWorkerName = zeros(C.NumJobsSim,C.Periods,'int32');
%   HiredWorkerWage = zeros(C.NumJobsSim,C.Periods);
%   for it = 1:C.Periods
%     %These are the worker names who are working.
%     Temp = SimO.iNames.*(Sim.SimJobName(:,it) > 0);
%     if any(Temp > 0)
%       %Assign the jobs to the worker names
%       HiredWorkerName(Sim.SimJobName(Temp>0,it),it) = Temp(Temp>0);
%       %Record the wages that the jobs pay to the workers.
%       HiredWorkerWage(Sim.SimJobName(Temp>0,it),it) = Sim.SimWage(Temp>0,it);
%     end
%   end
%   
%   %Worker names of each employment spell.
%   %Since firms do not search OJS, need to become vacancy first.
%   AllW =  HiredWorkerName;
%   CurrentW   = AllW(:,1);
%   for i1 = 2:C.Periods
%     NextW    = AllW(:,i1);
%     %For each period, set the next one to zero if the previous was not a zero
%     %and the next is the same.
%     AllW(AllW(:,i1) == CurrentW & CurrentW > 0,i1) = 0;
%     CurrentW = NextW;
%   end
%   
%   %Compute number of employment spells initiated at each firm.
%   Nj  = zeros(SimO.Numj,1);
%   for i1 = 1 : SimO.Numj
%     Nj(i1)      = sum(vec(AllW(SimO.JobNamej == i1,:) > 0));
%   end
%   
%   % Obtain average wages that each worker obtains at each firm. Save this as a sparse matrix.
%   % Also estimate the amount of noise put in. We only know it is normal and nothing else.
%   [iNameJWageLong,SigmaNoise_Hat]   = getxyWageCount(Sim.SimWage,SimO.jNames',HiredWorkerName,HiredWorkerWage,SimO.JobNamej,C,SimO,P);
  
  %%%%%Convert to sparse and return.
  [ID,T,Wages]        = find(Sim.SimWage);
  [ID,T,JName]        = find(Sim.SimJName);
  %Sum up wages and get WFCA
  WageSum              = sparse(ID,JName,Wages);
  L.iAvWageCount       = sparse(ID,JName,ones(numel(JName),1),size(Sim.SimWage,1),max(JName));
  [ID,IDNum,WageSum]   = find(WageSum);
  [ID,IDNum,WageCnt]   = find(L.iAvWageCount);
  L.iAvWageAtFirm      = sparse(ID,IDNum,WageSum./WageCnt,size(Sim.SimWage,1),max(JName));
  L.WFCA               = getWFCA(L);
  %Calculate the stardard dev of the error process
  [ID,T,Wages]         = find(Sim.SimWage);
  [ID,T,JName]         = find(Sim.SimJName);
  SigmaNoise_Hat       = Wages - L.iAvWageAtFirm(sub2ind(size(L.iAvWageAtFirm),ID,abs(JName)));
  SigmaNoise_Hat       = std(SigmaNoise_Hat);
  SimO.iNames          = vec(1:size(Sim.SimWage,1));
  SimO.Numj            = max(JName);
  C.NumAgentsSim       = size(Sim.SimWage,1);
  L                    = getIEmps(L,C,SimO);
  
end
