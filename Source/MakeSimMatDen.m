% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function MatDenSim = MakeSimMatDen(Sim,C,SimO)
  
  All = [vec(repmat((1:C.NumAgentsSim)',1,C.Periods)),vec(Sim.SimJobName),vec(Sim.SimShock)];
  All = All(All(:,2)~=0 & ~isnan(All(:,2)),:);
  All(:,1) = SimO.iNameX(All(:,1));
  All(:,2) = SimO.JobNameY(All(:,2));
  All = sortrows(All,[1 2 3]);
  [~,IdxS] = unique(All,'rows','first');
  [~,IdxE] = unique(All,'rows','last');
  Nums     = IdxE - IdxS + 1;
  MatDenSim = zeros(C.LenGrid,C.LenGrid,C.LenGridZ,'double');
  MatDenSim(sub2ind(size(MatDenSim),All(IdxE,1),All(IdxE,2),All(IdxE,3))) = Nums;
  
end
