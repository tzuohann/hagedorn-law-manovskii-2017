function SP = diagonalOutput(M,C,RD,P,SimO)
  %Compute the exact frictional output under PAM and NAM
  disp('diagonalOutput')
  try SP = RD.SP; end;

  TrueOutput          = nansum(vec(nansum(M.MatDen,3).*M.AverageProd))./nansum(vec(nansum(M.MatDen,3)))*mean(M.Emp);

  [OptimalDen]        = getOptimalMatches('main',SimO.MatDenSim,C,'emp',P);
  SP.OMainDiagEmp     = nansum(vec(M.AverageProd.*(OptimalDen)))./sum(vec(OptimalDen))*mean(SimO.Emp);
  SP.MainDiagEmpOpt   = OptimalDen;
  
  [OptimalDen]        = getOptimalMatches('off',SimO.MatDenSim,C,'emp',P);
  SP.OOffDiagEmp      = nansum(vec(M.AverageProd.*(OptimalDen)))./sum(vec(OptimalDen))*mean(SimO.Emp);
  SP.OffDiagEmpOpt    = OptimalDen;
  
  [OptimalDen]        = getOptimalMatches('main',SimO.MatDenSim,C,'all',P);
  SP.OMainDiagAll     = nansum(vec(M.AverageProd.*(OptimalDen)))./sum(vec(OptimalDen));
  SP.MainDiagAllOpt   = OptimalDen;
  
  [OptimalDen]        = getOptimalMatches('off',SimO.MatDenSim,C,'all',P);
  SP.OOffDiagAll      = nansum(vec(M.AverageProd.*(OptimalDen)))./sum(vec(OptimalDen));
  SP.OffDiagAllOpt    = OptimalDen;
  
  SP.MainDiagGainEmp  = (SP.OMainDiagEmp - TrueOutput)/TrueOutput;
  SP.MainDiagGainAll  = (SP.OMainDiagAll - TrueOutput)/TrueOutput;
  SP.OffDiagGainEmp   = (SP.OOffDiagEmp - TrueOutput)/TrueOutput;
  SP.OffDiagGainAll   = (SP.OOffDiagAll - TrueOutput)/TrueOutput;
  SP.TrueOutput       = TrueOutput;
  SP.OTrueSim         = nansum(vec(SimO.MatDenSim.*M.Prod))./nansum(vec(SimO.MatDenSim)).*mean(SimO.Emp);
end
