function GatherA        = makeOptAllImg(TrueWDist,TrueFDist,LenGrid,OptE)
  OptT      = full(sparse(vec(1:numel(OptE)),vec(OptE),1));
  GatherW = [0;cumsum(TrueWDist)];
  GatherF = [0;cumsum(TrueFDist)];
  for i1 = 1:LenGrid
    for i2 = 1:LenGrid
      GatherA(i1,i2) = sum(vec(OptT(GatherW(i1) + 1 : GatherW(i1 + 1),GatherF(i2) + 1 : GatherF(i2 + 1))));
    end
  end
end
