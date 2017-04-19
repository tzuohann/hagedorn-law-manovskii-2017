function [SWDist,SFDist] = DistCorr(SWDist,SFDist,TargetA,Pf)
  %Do the workers
  while sum(SWDist) ~= TargetA
    RN = rand(numel(SWDist),1);
    if sum(SWDist) > TargetA
      RN(SWDist == 0) = 0;
      SWDist(RN == max(RN)) = SWDist(RN == max(RN)) - 1;
    else
      SWDist(RN == max(RN)) = SWDist(RN == max(RN)) + 1;
    end
  end
  %Do the firms
  while sum(SFDist) ~= Pf*TargetA
    RN = rand(numel(SFDist),1);
    if sum(SFDist) > Pf*TargetA
      RN(SFDist == 0) = 0;
      SFDist(RN == max(RN)) = SFDist(RN == max(RN)) - 1;
    else
      SFDist(RN == max(RN)) = SFDist(RN == max(RN)) + 1;
    end
  end
end
