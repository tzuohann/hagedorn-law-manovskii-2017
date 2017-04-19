function [L,SigmaNoise_Hat]  = doRegMat(Sim,SimO,C,P,LU,RD)
  %Transforms simulated data into forms that are more useful for some functions.
  %See user guide/data dictionary for more information.
  
  display('doRegMat')
  
  if P.Pphi == 0
    L               = LU;
    SigmaNoise_Hat  = RD.S.SigmaNoise_HatU;
    return
  end
  
  %%%%%Get the names of workers and the amount they are paid grouped by jobs.
  HiredWorkerName = zeros(C.NumJobsSim,C.Periods,'int32');
  HiredWorkerWage = zeros(C.NumJobsSim,C.Periods);
  for it = 1:C.Periods
    %These are the worker names who are working.
    Temp = SimO.iNames.*(Sim.SimJobName(:,it) > 0);
    if any(Temp > 0)
      %Assign the jobs to the worker names
      HiredWorkerName(Sim.SimJobName(Temp>0,it),it) = Temp(Temp>0);
      %Record the wages that the jobs pay to the workers.
      HiredWorkerWage(Sim.SimJobName(Temp>0,it),it) = Sim.SimWage(Temp>0,it);
    end
  end
  
  %Worker names of each employment spell.
  %Since firms do not search OJS, need to become vacancy first.
  AllW =  HiredWorkerName;
  CurrentW   = AllW(:,1);
  for i1 = 2:C.Periods
    NextW    = AllW(:,i1);
    %For each period, set the next one to zero if the previous was not a zero
    %and the next is the same.
    AllW(AllW(:,i1) == CurrentW & CurrentW > 0,i1) = 0;
    CurrentW = NextW;
  end
  
  %Compute number of employment spells initiated at each firm.
  Nj  = zeros(SimO.Numj,1);
  for i1 = 1 : SimO.Numj
    Nj(i1)      = sum(vec(AllW(SimO.JobNamej == i1,:) > 0));
  end
  
  % Obtain average wages that each worker obtains at each firm. Save this as a sparse matrix.
  % Also estimate the amount of noise put in. We only know it is normal and nothing else.
  [iNameJWageLong,SigmaNoise_Hat]   = getxyWageCount(Sim.SimWage,SimO.jNames',HiredWorkerName,HiredWorkerWage,SimO.JobNamej,C,SimO,P);
  
  %%%%%Convert to sparse and return.
  L.iAvWageAtFirm     = sparse(iNameJWageLong(:,1),iNameJWageLong(:,2),iNameJWageLong(:,3),C.NumAgentsSim,SimO.Numj);
  L.iAvWageCount      = sparse(iNameJWageLong(:,1),iNameJWageLong(:,2),iNameJWageLong(:,4),C.NumAgentsSim,SimO.Numj);
  L.HiredWorkerName   = HiredWorkerName;
  L.HiredWorkerWage   = HiredWorkerWage;
  L.Nj                = Nj;
  L.HiredWorkerSpells = AllW;
  L.WFCA              = getWFCA(L);
  L                   = getIEmps(L,C,SimO);
  
end
