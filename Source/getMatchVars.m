function [MVCU,MVCE,MV,Pphi] = getMatchVars(M,P,C,SimO,Sim,NNHUFull,AccRateU,VacsFull,iBin,WageU)
  %To obtain the matching rate, which in our case, is exactly Kkappa, we just need the aggregate payroll size in the economy.
  %Note that in the context of this model, aggregate vacancies and aggregate unemployment is the same.
  %See user guide/data dictionary for more information.
  
  display('getMatchVars')
  
  if C.PerfectMatchVars == 1
    MVCE            = M.MV * M.CE;
    MVCU            = M.MV * M.CU;
    MV              = M.MV;
    Pphi            = P.Pphi;
  else
    MVCU    = sum(mean(NNHUFull,2)./AccRateU)/mean(VacsFull)/(1-P.Ddelta);
    
    ProbXUnE  = getProbXUnE(Sim,C,iBin);
    ProbXLowW = getProbXLowW(Sim,C,SimO,WageU,iBin);
    
    if P.Pphi > 0
      Pphi    = nansum(ProbXLowW(:,1)./ProbXUnE(:,1).*ProbXLowW(:,2))./nansum(ProbXLowW(:,2));
    else
      Pphi  = 0;
    end
    
    MV      = MVCU/((1 - mean(SimO.Emp))/((1 - mean(SimO.Emp)) + Pphi.*mean(SimO.Emp)));
    MVCE    = MV .* Pphi*mean(SimO.Emp)/(Pphi*mean(SimO.Emp) + (1 - mean(SimO.Emp)));
  end
end

function ProbXUnE = getProbXUnE(Sim,C,iBin)
  ProbXUnE = zeros(C.LenGrid,2);
  SJN      = double(Sim.SimJobName);
  for ix = 1:C.LenGrid
    Wt       = iBin == ix;
    ProbXUnE(ix,:) = [sum(vec(SJN(Wt,1:end-1) == 0  & SJN(Wt,2:end) > 0))./sum(vec(SJN(Wt,1:end-1) == 0)),sum(vec(SJN(Wt,1:end-1) == 0))];
  end
end

function ProbXLowW = getProbXLowW(Sim,C,SimO,WageU,iBin)
  ProbXLowW   = zeros(C.LenGrid,2);
  jName       = double(Sim.SimJobName);
  jName(jName > 0)  = SimO.JobNamej(jName(jName > 0));
  for ix = 1:C.LenGrid
    [~,jLowWage]   =  nanmin(WageU(ix,:));
    Wt       = iBin == ix;
    ProbXLowW(ix,:) = [sum(vec(jName(Wt,1:end-1) == jLowWage & jName(Wt,2:end) > 0 & jName(Wt,2:end) ~= jLowWage))./sum(vec(jName(Wt,1:end-1) == jLowWage)),sum(vec(jName(Wt,1:end-1) == jLowWage))];
  end
end
