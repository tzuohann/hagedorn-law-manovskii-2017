function UnEBin = xBinUnEmp(C,iUnE,iBin)
  %xUnEBin = BinUnEmp(RD,C)
  %Compute the average unemployment rate of each worker bin.
  %See user guide/data dictionary for more information.
  %Author: Tzuo Hann Law (tzuohann@gmail.com)
  disp('xBinUnEmp')
  UnEBin = zeros(C.NumXBins,1);
%   if C.PerfectiUnE == 1
%     UnEBin = M.UnEMass*C.LenGrid;
%   else %I.iBin is the Bin that the worker with name at that position belongs tM.
    for i1 = 1:C.NumXBins
      UnEBin(i1)    = nanmean(iUnE(iBin == i1));
    end
%   end
end
