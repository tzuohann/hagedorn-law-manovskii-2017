function ProdY = getProdXYE(C,P,NumjY,jYxWageU,jYValVac)
  %Get the production function at the firm level.
  disp('getProdXYE')
  ProdY = zeros(C.LenGrid,NumjY);
  for iy = 1:NumjY
    for ix = 1:C.LenGrid
      ProdY(ix,iy)  =  jYxWageU(ix,iy,end) + jYValVac(iy)*(1-P.Bbeta);
    end
  end
end
