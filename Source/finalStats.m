function FS = finalStats(SimO,C,RD,Sim)
  %Here we compute some correlations to evaluation how well we rank workers and firms, and how well we recover sorting.
  %See user guide/data dictionary for more information.
  
  display('finalStats')
  FS = struct;

  %Workers rank correlation
  FS.WCorrUse           = corr(double(RD.I.iBin),SimO.iNameX,'type','spearman');
  
  %Workers rank correlation MIN
  FS.WCorrMin           = corr(binAgents(RD.I.iNRMin,SimO.iNameX),SimO.iNameX,'type','spearman');
  
  %Workers rank correlation MAX
  FS.WCorrMax           = corr(binAgents(RD.I.iNRMax,SimO.iNameX),SimO.iNameX,'type','spearman');
  
  %Workers rank correlation AdAV
  FS.WCorrAdAv          = corr(binAgents(RD.I.iNRAdAv,SimO.iNameX),SimO.iNameX,'type','spearman');
  
  %Workers rank correlation ExpW
  FS.WCorrExpW          = corr(binAgents(RD.I.iNRExpW,SimO.iNameX),SimO.iNameX,'type','spearman');
  
  %Firms rank correlation
  FS.FCorr              = corr(RD.J.jBin,SimO.jNameY,'type','spearman');
  
  %Worker-firm true rank correlation
  Temp                = Sim.SimJobName > 0;
  iNames              = repmat((1:C.NumAgentsSim)',1,C.Periods);
  iNames              = iNames(Temp);
  SimJobName          = Sim.SimJobName(Temp);
  FS.WFTrueCorr       = corr(SimO.iNameX(iNames),SimO.JobNameY(SimJobName),'type','spearman','rows','complete');
  
  %Worker-firm estimated rank correlation
  SimFirmName         = SimO.JobNamej(SimJobName);
  SimFirmBin          = RD.J.jBin(SimFirmName);
  WorkerBin           = RD.I.iBin(iNames);
  FS.WFEstCorr        = corr(double(WorkerBin),SimFirmBin,'type','spearman','rows','complete');

end
