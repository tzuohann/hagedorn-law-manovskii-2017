function jxWage = getWageJYX(NumjY,LL,BinID,RD,C,iDropped,maptoTrueY,WageTrue,MatDen)
  % jxWage = getWageJYX(NumjY,LL,BinID,RD,C,iDropped,maptoTrueY)
  % Compute the average wage each firms. Use only workers that are not
  % dropped.
  disp('getWageJYX')
  jxWage          = nan(C.LenGrid,NumjY);
  if C.PerfectAverageWages == 1;
    jxWage        = nansum(WageTrue(:,round(maptoTrueY),:).*MatDen(:,round(maptoTrueY),:),3)./nansum(MatDen(:,round(maptoTrueY),:),3);
  else
    for ix = 1:C.LenGrid
      WageIXAll     = full(LL.iAvWageAtFirm(RD.I.iBin == ix & iDropped == 0,:));
      CntsIXAll     = full(LL.iAvWageCount(RD.I.iBin == ix & iDropped == 0,:));
      Valid         = WageIXAll ~= 0;
      CntsIXAll(~Valid) = nan;
      WageIXAll(~Valid) = nan;
      for ijO = 1:NumjY
        Counts = nansum(vec(CntsIXAll(:,BinID == ijO)));
        if Counts > 0
          jxWage(ix,ijO)     = nansum(vec(WageIXAll(:,BinID == ijO).*CntsIXAll(:,BinID == ijO)))./Counts;
        end
      end
    end
  end
end
