function RD = getWorkerEVals(C,RD,L,P,M,Sim,SimO)
  %Get worker value functions when employed. For this, we get the average wages firms (bin, individual or by matching sets) pay to
  %workers, and utilitize the continuation payoff for unemployment computed earlier.
  %The average wages are also used later for computing the production function.
  %See user guide/data dictionary for more information.
    
  display('getWorkerVals')
  
  I  = RD.I;
  Y  = RD.Y;
  J  = RD.J;
  X  = RD.X;
  
  C2 = (1 - P.Bbeta + P.Bbeta*(1-P.Ddelta)*RD.S.MV - RD.S.MV*P.Bbeta*P.Ddelta*P.Bbeta*(1-P.Ddelta)/(1-P.Bbeta*(1-P.Ddelta)));
  C3 = 1/C2;
  C4 = (P.Bbeta * (1-P.Ddelta) * RD.S.MV/(1-P.Bbeta * (1-P.Ddelta)))/C2;
  
  %For the worker's value of unemployment, we just do it by bin.
  V_u_Hat     = zeros(C.NumXBins,1);
  FullAccSet  = zeros(C.NumXBins,1);
  
  %Vacancies
  VacDenCond  = zeros(C.LenGrid,1);
  for iy = 1:C.LenGrid
    VacDenCond(iy)  = sum(J.MaxjSize(J.jBin == iy)) - sum(mean(J.FirmSize(J.jBin == iy,:),2));
  end
  VacDenCond  = VacDenCond./sum(VacDenCond);
  
  for i1 = 1:C.NumXBins
    %If worker bin acceptance set is full. Consider only undropped workers.
    %Use the average wages formula.
    A = unique(RD.J.jBin(SimO.JobNamej(nonzeros(Sim.SimJobName(RD.I.iBin == i1,:)))));
    if size(A,1) == C.LenGrid
      FullAccSet(i1) = 1;
      AvgWage = nanmean(vec(Sim.SimWage(RD.I.iBin == i1 & RD.I.iDroppedj == 0,:)));
      if isnan(AvgWage)
        error('Should not be nan here')
      end
      V_u_Hat(i1) = C3*RD.S.HomeProdEst + C4*AvgWage;
    else
      %If worker acceptance set is NOT full
      V_u_Hat(i1)          = X.MinWBin(i1)/(1-P.Bbeta);
    end
  end
  X.ValUnE       = V_u_Hat;
  
  Y.ValEmp_yHat  = (Y.WageU + P.Bbeta*P.Ddelta*repmat(V_u_Hat,1,C.NumYBins))./(1-(1-P.Ddelta)*P.Bbeta);
  J.ValEmp_jHat  = (J.WageU  + P.Bbeta*P.Ddelta*repmat(V_u_Hat,1,SimO.Numj))./(1-(1-P.Ddelta)*P.Bbeta);
  
  RD.I = I;
  RD.J = J;
  RD.Y = Y;
  RD.X = X;
  
end


