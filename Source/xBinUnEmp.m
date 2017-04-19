function UnEBin = xBinUnEmp(C,M,iUnE,iBin)
  disp('xBinUnEmp')
  UnEBin = zeros(C.NumXBins,1);
  if C.PerfectiUnE == 1
    UnEBin = M.UnEMass*C.LenGrid;
  else %I.iBin is the Bin that the worker with name at that position belongs tM.
    for i1 = 1:C.NumXBins
      UnEBin(i1)    = nanmean(iUnE(iBin == i1));
    end
  end
end
