function ValVac = getFirmVals(P,Omega)
  %The value of a vacancy follows readily from omage computed earlier.
  %See user guide/data dictionary for more information.
  
  display('getFirmVals')
 
  AA = P.Bbeta/((1-P.Bbeta)*(1-P.Bbeta*(1-P.Ddelta)));

  ValVac     = AA*Omega;
  
end
