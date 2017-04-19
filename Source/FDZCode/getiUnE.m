function [iUnE,Ddelta] = getiUnE(SimO,C,Sim)
  %Gets the minimum unemployment rate or assigns the theoretical if needed.
  %See user guide/data dictionary for more information.
  %Author: Tzuo Hann Law (tzuohann@gmail.com)
  
  display('getiUnE')
  
  %Worker specific unemployment rate.
%   if C.PerfectiUnE == 1
%     iUnE          = M.UnEMass(SimO.iNameX(SimO.iNames))*C.LenGrid;
%   else
    Sim.SimWage(Sim.SimWage == 0) = nan;
    JobIs1        = double(Sim.SimWage > 0);
    JobIs1(Sim.SpellType == 3) = nan;

    iUnE                = nanmean(JobIs1,2);
    iUnE(isnan(iUnE))   = 0;
    iUnE                = 1 - iUnE;
    if any(iUnE >= 1)
      error('Some worker is always unemployed. Check simulation')
    end
    Spells = [vec(JobIs1(:,1:end-1)'),vec(JobIs1(:,2:end)')];
    Spells = Spells(sum(isnan(Spells),2) == 0,:);
    Spells = Spells(Spells(:,1) == 1,2);
    Ddelta = mean(Spells == 0);
%   end
end
