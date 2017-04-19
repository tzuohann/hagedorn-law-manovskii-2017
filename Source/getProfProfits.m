function Prod = getProfProfits(P,ValUnEIn,ValVacIn,WageU,NumYBins,NumXBins)
  %With the value of vacancy, profits the production function and profits(if needed but not computed here) can easily be computed.
  %See user guide/data dictionary for more information.
  
  display('getProfProfits')
  
  ValUnE              = repmat(ValUnEIn,1,NumYBins);
  ValVac              = repmat(vec(ValVacIn)',NumXBins,1);
  Prod                = (WageU - P.Aalpha*(P.Bbeta-1)*ValVac - (1-P.Aalpha)*(1-P.Bbeta)*ValUnE)/P.Aalpha;
end
