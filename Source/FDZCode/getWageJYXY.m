function jxWage = getWageJYXY(NumjY,LL,RD,C,iDropped,LIABMaxNum,jBin)
% jxWage = getWageJYX(NumjY,LL,BinID,RD,C,iDropped,maptoTrueY)
% Compute the average wage each firms. Use only workers that are not
% dropped.
disp('getWageJYX')
jxWage          = nan(C.LenGrid,NumjY);

LL.WFCA(:,3)    = 1./LL.WFCA(:,3);
LL.WFCA         = LL.WFCA(iDropped(LL.WFCA(:,1)) == 0,:);
LL.WFCA         = LL.WFCA(LL.WFCA(:,2) <= LIABMaxNum,:);
LL.WFCA(:,2)    = jBin(LL.WFCA(:,2));
LL.WFCA(:,1)    = RD.I.iBin(LL.WFCA(:,1));
WagesCount      = full(sparse(LL.WFCA(:,1),LL.WFCA(:,2),LL.WFCA(:,3).*LL.WFCA(:,4)));
Count           = full(sparse(LL.WFCA(:,1),LL.WFCA(:,2),LL.WFCA(:,3)));
jxWage          = WagesCount./Count;

end
