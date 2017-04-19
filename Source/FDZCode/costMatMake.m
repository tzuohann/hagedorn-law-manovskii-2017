
function CostMat = costMatMake(SWDist,SFDist,Prod)
  CostMat           = zeros(sum(SWDist),sum(SFDist));
  WIndex            = 0;
  for ix  = 1:size(SWDist,1)
    FIndex            = 0;
    for iy = 1:size(SFDist,1)
      for ixx = 1:SWDist(ix)
        CostMat(WIndex + ixx,(FIndex + 1):(FIndex + SFDist(iy))) = Prod(ix,iy);
      end
      FIndex = FIndex + SFDist(iy);
    end
    WIndex = WIndex + SWDist(ix);
  end
  CostMat(isnan(CostMat)) = 0;
end


