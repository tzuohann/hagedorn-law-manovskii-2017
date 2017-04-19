function MatDen  = getMatDenEstY(L,C,RD,NumjY,jBin)
  % jxMatDen  = getMatDenEst(L,C,RD,NumjY,jYID)
  % Get the number of wage observations at each worker firm pair.
  disp('getMatDenEst')
  MatDen  = zeros(C.LenGrid,NumjY);
  
  [IW,IJ,Counts]   = find(L.iAvWageCount);
  IW               = RD.I.iBin(IW);
  IJ               = jBin(IJ);
  MatDen           = full(sparse(IW,IJ,Counts));
  
end
