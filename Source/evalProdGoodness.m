function [Y]  = evalProdGoodness(Sim,SimO,M,RD,JobNameToBin,Prod,C)
  %Evaluate how well the estimated production functions tracks the original.
  %We computed correlations, variance and percent deviation. (not all are reported)
  %See user guide/data dictionary for more information.

  display('evalProdGoodness')
  Y = RD.Y;
  %Take simulation, and compute what the true output is.
  SimWName              = bsxfun(@times,double(Sim.SimJobName > 0),SimO.iNames);
  SimWName(RD.I.iDroppedj == 1,:) = 0;
  SimFBin               = Sim.SimJobName.*int32(SimWName > 0);
  SimShock              = Sim.SimShock;
  SimWName              = SimWName(SimWName > 0);
  SimShock              = SimShock(SimFBin > 0);
  SimFBin               = SimFBin(SimFBin > 0);
  SimWBin               = RD.I.iBin(SimWName(:));
  SimFBin               = JobNameToBin(SimFBin);
  
  %Averaging the production function conditional on acceptance across the different shocks.
%   TrueOutputVec        = M.Prod(sub2ind(size(M.Prod),int32(SimWBin),int32(SimFBin),int32(SimShock)));
  TrueOutputVec         = M.AverageProd(sub2ind(size(M.AverageProd),int32(SimWBin),int32(SimFBin)));
  EstProdVec            = Prod(sub2ind(size(Prod),int32(SimWBin),int32(SimFBin)));

  LevelDiff             = nanmean(TrueOutputVec - EstProdVec);
  Prod                  = Prod + LevelDiff;
  Prod(Prod < 0 )       = 0; %If production is negative, set production to the lower possible quantity, zero.
  EstProdVec            = Prod(sub2ind(size(Prod),int32(SimWBin),int32(SimFBin)));
  Y.Prod                = Prod;
  
 
  %Compute what we need. Just take correlation on complete rows and record how
  %many are dropped. There are workers who are in bins that do not end up being
  %computed.
  Y.OCorrMZ         = corr(EstProdVec,TrueOutputVec,'rows','complete','type','spearman');

end
