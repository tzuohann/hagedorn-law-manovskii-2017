function MatDen  = getMatDenEst(L,C,RD,NumjY,jYID)
  % jxMatDen  = getMatDenEst(L,C,RD,NumjY,jYID)
  % Get the number of wage observations at each worker firm pair.
  disp('getMatDenEst')
  MatDen  = zeros(C.LenGrid,NumjY);
  
  for ix = 1:C.LenGrid
    TotCounts   = full(L.iAvWageCount(RD.I.iBin == ix,:));
    for ij = 1:NumjY
      MatDen(ix,ij) = sum(vec(TotCounts(:,jYID == ij)));
    end
  end
  
end
