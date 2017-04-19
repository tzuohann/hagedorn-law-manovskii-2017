function [RD] = WantedVars(C,M,P,Sim,SimO,S)
  
  [LU,RD.S.SigmaNoise_HatU] = doRegMatU(Sim,SimO,C,P);
  
  [L,RD.S.SigmaNoise_Hat] = ...
    doRegMat(Sim,SimO,C,P,LU,RD);
  
  RD.I.iUnE = ...
    getiUnE(SimO,C,Sim,M);
  
  RD.I = ...
    simWageStats(Sim,L,C,SimO,RD.I);
  
  RD.I = ...
    rankWorkers(M,RD,C,SimO,LU,S,P);
  
  RD.X.UnEBin = ...
    xBinUnEmp(C,M,RD.I.iUnE,RD.I.iBin);
  
  RD.J = ...
    getWMob(C,SimO,RD,L,Sim,M,P);
  
  [RD.J.AccSetU,RD.I.iDroppedj] = ...
    markDropU(RD,C,SimO,M,LU,SimO.Numj,SimO.jNameY,SimO.JobNamej,SimO.jNames,zeros(C.NumAgentsSim,1));
  
  RD.J.MatDen                 = getMatDenEst(L,C,RD,SimO.Numj,SimO.jNames);

  RD.J.MatDenU                = getMatDenEst(LU,C,RD,SimO.Numj,SimO.jNames);
  
  RD.J.Wage                     = ...
    getWageJYX(SimO.Numj,L,SimO.jNames,RD,C,RD.I.iDroppedj,SimO.jNameY,M.Wage,M.MatDen);
  
  RD.J.WageU                    = ...
    getWageJYX(SimO.Numj,LU,SimO.jNames,RD,C,RD.I.iDroppedj,SimO.jNameY,M.Wage,M.MatDen);
  
  [RD.J.AccSetE,RD.J.Cutoff]    = getAccSetE(RD,C,SimO,M,Sim,P,SimO.Numj,SimO.JobNamej,RD.I.iDroppedj);
  
  if C.UseVacs == 1 && P.Pphi == 0
    RD.J.AccRateU = ...
      getAccRateWithVacs(RD.J.NNHUFull,SimO.Numj,C.jSizeDist.*ones(SimO.Numj,1),RD.J.FirmSize,M.MV,P.Ddelta);
    RD.J.AccRateE = zeros(SimO.Numj,1);
  else
    [RD.J.AccRateU,RD.J.AccRateE] = ...
      getAccRate(SimO.Numj,C,RD,M,RD.J.AccSetU,RD.J.AccSetE,RD.J.MatDen,SimO.jNameY);
  end
  
  [RD.S.MVCU,RD.S.MVCE,RD.S.MV,RD.S.Pphi] = ...
    getMatchVars(M,P,C,SimO,Sim,RD.J.NNHUFull,RD.J.AccRateU,RD.J.VacsFull,RD.I.iBin,RD.J.WageU);
  
  RD.J.MaxjSize                   = getMaxjSize(C,SimO,P,RD.J.AccRateU,RD.J.AccRateE,RD.S.MVCU,RD.S.MVCE,RD.J.FirmSize,RD.J.NLWEFull);
  RD.X.MinWBin                    = getMinWage(RD,C,M,repmat(vec(SimO.jNames)',C.LenGrid,1));
  
  RD.I.MinWBin                    = RD.X.MinWBin(RD.I.iBin);
  RD.J.EEWageDiff                 = empWageDiff(SimO.Numj,RD.J.MatDen,RD.J.WageU,RD.J.AccSetE,L,P,C,SimO.jNameY,M);
  RD.J.AveWDiff                   = firmAvWageDiff(SimO.Numj,LU,SimO.JobNamej,RD,SimO.jNameY,C,RD.I.iDroppedj,M);
  RD.J.Omega                      = RD.S.MV*(1-P.Ddelta)*RD.J.AveWDiff.*RD.J.AccRateU;
  
  if P.Pphi == 0
    RD.J.NROmega                    = getRankBy(SimO.jNames,RD.J.Omega);
  else
    RD.J.NROmega                    = getRankBy(SimO.jNames,RD.J.EEWageDiff);
  end
  
  RD.J.NRUse                        = RD.J.NROmega;
  if C.PerfectjRank   == 1
    RD.J.jBin                       = SimO.jNameY;
  else
    RD.J.jBin                       = binAgents(RD.J.NRUse,SimO.jNameY);
  end
  
  RD.Y = [];
  
  RD.Y.Wage = ...
    getWageJYX(C.LenGrid,L,RD.J.jBin,RD,C,RD.I.iDroppedj,SimO.jNameY,M.Wage,M.MatDen);
  
  RD.Y.WageU = ...
    getWageJYX(C.LenGrid,LU,RD.J.jBin,RD,C,RD.I.iDroppedj,SimO.jNameY,M.Wage,M.MatDen);
  
  RD.Y.MatDen                     = getMatDenEst(L,C,RD,C.LenGrid,RD.J.jBin);
  RD.Y.MatDenU                    = getMatDenEst(LU,C,RD,C.LenGrid,RD.J.jBin);
  
  JSize   = mean(RD.J.FirmSize,2);
  for i1 = 1:C.LenGrid
    JJJ                    = RD.J.jBin == i1;
    RD.Y.Omega(i1,1)       = wmean(RD.J.Omega(JJJ),JSize(JJJ));
    RD.Y.EmpShare(i1,1)    = sum(RD.J.EmpShare(RD.J.jBin == i1));
  end
  
  RD.S.HomeProdEst                = 0;
  if P.Pphi == 0
    RD                            = getWorkerEVals(C,RD,L,P,M,Sim,SimO); %Clean this up after getting the
    RD.Y.ValVac                   = getFirmVals(P,RD.Y.Omega);
    RD.Y.Prod                     = getProfProfits(P,RD.X.ValUnE,RD.Y.ValVac,RD.Y.WageU,C.LenGrid,C.LenGrid);
  else
    [RD.Y.AccSetU,~] = ...
      markDropU(RD,C,SimO,M,LU,SimO.Numj,SimO.typeNames,RD.J.jBin(SimO.JobNamej),RD.J.jBin,zeros(C.NumAgentsSim,1));
    [RD.Y.AccSetE,~]                = getAccSetE(RD,C,SimO,M,Sim,P,C.LenGrid,SimO.jNameY(SimO.JobNamej),RD.I.iDroppedj);
    [RD.Y.AccRateU,RD.Y.AccRateE]   = getAccRate(C.LenGrid,C,RD,M,RD.Y.AccSetU,RD.Y.AccSetE,RD.Y.MatDen,SimO.typeNames);
    RD.Y.EEWageDiff                 = empWageDiff(C.LenGrid,RD.Y.MatDen,RD.Y.WageU,RD.Y.AccSetE,L,P,C,SimO.typeNames,M);
    RD.Y.ValVac                     = getValVac(RD,P,RD.Y.EEWageDiff);
    RD.Y.Prod                       = getProdXYE(C,P,C.LenGrid,RD.Y.WageU,RD.Y.ValVac);
  end
  
  %% Compute stuff
  RD.Y                          = evalProdGoodness(Sim,SimO,M,RD,RD.J.jBin(SimO.JobNamej),RD.Y.Prod,C);
  RD.FS                         = finalStats(SimO,C,RD,Sim);
  RD.SP                         = diagonalOutput(M,C,RD,P,SimO);
  RD.SP                         = socialPlanner(C,M,SimO,RD,S,P,Sim);
  
  RD.AKM                        = getACKM_PCG(Sim,C,SimO);
  
end

