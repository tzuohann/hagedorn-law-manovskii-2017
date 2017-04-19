function [OptimalDen] = getOptimalMatches(Diag,MatDen,C,Group,P)
  %In the case of the off diagonal, we take the best measure of firms equal
  %to the measure of workers.
  switch lower(Group)
    case {'emp'}
      WLeft = sum(sum(MatDen,3),2)*C.AgentSize;
      FLeft = sum(sum(MatDen,3),1)'*C.AgentSize;
    case {'all'}
      %Make all workers full employment.
      %Firm distribution is not affected
      FullEmp = 1/size(MatDen,1);
      MatDen  = bsxfun(@times,MatDen,FullEmp./sum(MatDen,2));
      WLeft = sum(sum(MatDen,3),2)*C.AgentSize;
      FLeft = sum(sum(MatDen,3),1)'*C.AgentSize;
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
