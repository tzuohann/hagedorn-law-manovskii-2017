function AccRateUVacs           = getAccRateWithVacs(NNHUFull,Numj,jSizeDist,FirmSize,MV,Ddelta)
  % Obtain the acceptance rate using vacancy information.
  AccRateUVacs = min(1,max(0,sum(NNHUFull,2)./sum(bsxfun(@minus,jSizeDist,FirmSize),2)/(MV*(1-Ddelta))));
end
