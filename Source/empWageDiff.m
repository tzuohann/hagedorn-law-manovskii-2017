function jEEWageDiff = empWageDiff(NumjY,jYxMatDen,jYxWageU,jYxAccSetE,L,P,C,jyToTrueY,M)
  % jEEWageDiff = empWageDiff(NumjY,jYxMatDen,jYxWageU,jYxAccSetE,L,P,C,jyToTrueY)
  % Compute the average wage difference for firms.
  disp('empWageDiff')
  
  %For each firm, look at wages out of unemployment of workers who are
  %currently employed with the firm less their wage when they were working
  %elsewhere (again out of unemployment)
  jEEWageDiff    = nan(NumjY,1);
  if P.Pphi > 0
    if C.PerfectEEWageDiff == 1
      jEEWageDiff  = M.yEEWageDiff(round(jyToTrueY));
    else
      for ix = 1:C.LenGrid
        for ijO = 1:NumjY
          DENEMP = jYxMatDen(ix,ijO);
          if DENEMP > 0
            Tmp           = max(vec((jYxWageU(ix,:) - jYxWageU(ix,ijO))),0);
            jEEWageDiff  = nansum([jEEWageDiff,Tmp.*vec(jYxAccSetE(ix,ijO,:)).*DENEMP],2);
          end
        end
      end
      jEEWageDiff     = jEEWageDiff./full(sum(L.iAvWageCount(:)));
    end
  end
end
