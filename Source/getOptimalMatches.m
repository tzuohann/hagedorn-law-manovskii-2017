function [OptimalDen] = getOptimalMatches(Diag,MatDen,C,Group,P)
  %In the case of the off diagonal, we take the best measure of firms equal
  %to the measure of workers.
  switch lower(Group)
    case {'emp'}
      WLeft = sum(sum(MatDen,3),2)*C.AgentSize;
      FLeft = sum(sum(MatDen,3),1)'*C.AgentSize;
    case {'all'}
      WLeft = ones(C.LenGrid,1);
      FLeft = zeros(C.LenGrid,1);
      FNeeded = C.LenGrid;
      for i1 = C.LenGrid : -1 : 1
        if FNeeded - P.Pf >= 0
          FLeft(i1) = P.Pf;
          FNeeded = FNeeded - FLeft(i1);
        else
          FLeft(i1) = FNeeded;
          break
        end
      end
  end
  OptimalDen = zeros(C.LenGrid);
  while sum(WLeft) > 0
    UnFilledW = find(WLeft > 0,1,'last');
    switch lower(Diag)
      case{'main'}
        UnFilledF = find(FLeft > 0,1,'last');
      case{'off'}
        UnFilledF = find(FLeft > 0,1,'first');
    end
    if WLeft(UnFilledW) >= FLeft(UnFilledF)
      OptimalDen(UnFilledW,UnFilledF) = FLeft(UnFilledF);
      WLeft(UnFilledW) = WLeft(UnFilledW) - FLeft(UnFilledF);
      FLeft(UnFilledF) = 0;
    else
      OptimalDen(UnFilledW,UnFilledF) = WLeft(UnFilledW);
      FLeft(UnFilledF) = FLeft(UnFilledF) - WLeft(UnFilledW);
      WLeft(UnFilledW) = 0;
    end
  end
end
