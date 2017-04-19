function jValVac  = getValVac(RD,P,jEEWageDiff)
  % jValVac  = getValVac(RD,P,jEEWageDiff)
  % getValue of Vacancy firm by firm.
  disp('getValVac')
  jValVac   = jEEWageDiff/(1-P.Bbeta*(1-P.Ddelta)).*P.Bbeta.*(1-P.Ddelta).*RD.S.MVCE/(1 - P.Bbeta);
end
