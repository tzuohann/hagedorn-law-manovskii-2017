function [xyWageCount,SigmaNoise_Hat] = getxyWageCount(SimWage,yBy,HiredWorkerName,HiredWorkerWage,yID,C,SimO,P)
  %Get wages and counts in 4 columns. x,y,Wage,Counts. y can be manually
  %picked.
  xyWageCount                   = zeros(sum(vec(~isnan(SimWage))),4);
  Vector                        = zeros(sum(vec(~isnan(SimWage))),1);
  icnt                          = 0;
  icntV                         = 0;
  for ij = yBy
    Temp                      = yID == ij;
    IW                        = HiredWorkerName(Temp,:);
    WW                        = HiredWorkerWage(Temp,:);
    %WageCount                is [AverageWage,Counts]
    %VecTemp                  is [Wage - AverageWage]
    [WageCount,VecTemp,NumM]  = wageStats(IW,WW,int32(C.NumAgentsSim));
    Temp                      = WageCount(:,2) > 0;
    NumW                      = sum(Temp);
    xyWageCount(icnt + 1 : icnt + NumW,1) = SimO.iNames(Temp);
    xyWageCount(icnt + 1 : icnt + NumW,2) = ij;
    xyWageCount(icnt + 1 : icnt + NumW,3) = WageCount(Temp,1);
    xyWageCount(icnt + 1 : icnt + NumW,4) = WageCount(Temp,2);
    Vector(icntV + 1: icntV + NumM)       = VecTemp(1:NumM);
    icnt    = icnt + NumW;
    icntV   = icntV + NumM;
  end
  xyWageCount         = xyWageCount(1:icnt,:);
  SigmaNoise_Hat      = var(Vector);
  if numel(C.GridZeta)  > 1
    SigmaNoise_Hat      = sqrt(SigmaNoise_Hat + var(vec(P.Aalpha.*C.GridZeta),vec(C.ZetaProb)));
  else
    SigmaNoise_Hat      = sqrt(SigmaNoise_Hat);
  end
end
