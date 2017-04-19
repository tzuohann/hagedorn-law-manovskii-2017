function iBin = binAgents(iNR,Bins)
  %Takes worker rankings and gives bins.
  %See user guide/data dictionary for more information.
  iNR     = sortrows(iNR,1);
  iBin    = double(Bins(iNR(:,2)));
end
