function jAveWDiff = firmAvWageDiff(NumYj,LU,JobBin,RD,jYNameToTrueY,C,iDropped,M)
  % jAveWDiff = firmAvWageDiff(NumYj,LU,JobBin,RD,jYNameToTrueY,C,iDropped)
  %Compute the average wage difference which is the bin specific wage difference
  %weighted by the xBin specific unemployment rates. When a worker's acceptance set is full, we use
  %the implied reservation wage from the value of unemployment.
  %See user guide/data dictionary for more information.
  
  display('firmAvWageDiff')
  
  %This computes the average wage difference of each bin
  HWN                                         = double(LU.HiredWorkerName);

  %Only working with the selected workers. Might want to remove this.
  RD.I.MinWBin(iDropped == 1)                 = nan;
  HWN(HWN~=0)                                 = RD.I.MinWBin(HWN(HWN~=0));
  LU.HiredWorkerWage(LU.HiredWorkerName == 0) = nan;
  WageDiffHat                                 = LU.HiredWorkerWage - HWN;
  
  %Obtain the firm mean of wages - minimum wages.
  if C.PerfectjWageDiff == 1 && C.PerfectMinWage == 2;
    jAveWDiff        = M.yAveWDiffRes(round(jYNameToTrueY));
  elseif C.PerfectjWageDiff == 1 && C.PerfectMinWage < 2;
    jAveWDiff        = M.yAveWDiff(round(jYNameToTrueY));
  else
    jAveWDiff          = zeros(NumYj,1);

    for iy = 1:NumYj
      HW              = LU.HiredWorkerName(JobBin == iy,:);
      HW(HW > 0)      = RD.I.iBin(HW(HW > 0));
      WDHall          = WageDiffHat(JobBin == iy,:);
      WDH             = zeros(C.LenGrid,1);

      for ix = 1:C.LenGrid
        WDH(ix)       = nanmean(WDHall(HW == ix));
      end
%       jAveWDiff(iy)   = wmean(WDH(~isnan(WDH)),RD.J.MatDen(~isnan(WDH),iy));
      jAveWDiff(iy)   = wmean(WDH(~isnan(WDH)),RD.X.UnEBin(~isnan(WDH)));
   
    end
  end
end
