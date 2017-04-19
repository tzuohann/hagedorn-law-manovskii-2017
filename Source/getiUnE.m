function iUnE = getiUnE(SimO,C,Sim,M)
  %Gets the minimum unemployment rate or assigns the theoretical if needed.
  %See user guide/data dictionary for more information.
  
  display('getiUnE')
  
  %Worker specific unemployment rate.
  if C.PerfectiUnE == 1
    iUnE          = M.UnEMass(SimO.iNameX(SimO.iNames))*C.LenGrid;
  else
    JobIs1        = double(~isnan(Sim.SimWage));
    iUnE          = mean(~JobIs1,2);
    if any(iUnE >= 1)
      error('Some worker is always unemployed. Check simulation')
    end
  end
end
