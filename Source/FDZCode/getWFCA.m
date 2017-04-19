function WFCA   = getWFCA(LU)
  [W,F,Count]          = find(LU.iAvWageCount);
  [~,~,Ave]            = find(LU.iAvWageAtFirm);
  WFCA              = sortrows([W,F,1./Count,Ave],[1 2]);
end
