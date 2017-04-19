function [jxAccRateU,jxAccRateE] = getAccRate(NumjY,RD,AccSetU,AccSetE,MatDen)
  % [jxAccRateU,jxAccRateE] = getAccRate(NumjY,C,RD,M,AccSetU,AccSetE,MatDen,jYToTrueY)
  % Get acc rate conditional on surviving delta and meeting for JJ
  disp('getAccRate')
  
%   if C.PerfectAccRate == 1
%     jxAccRateU     = M.ProbVacAccUnE(round(jYToTrueY));
%     jxAccRateE     = M.ProbVacAccEmp(round(jYToTrueY));
%   else
    jxAccRateU        = nan(NumjY,1);
    jxAccRateE        = nan(NumjY,1);
    
    Temp2             = RD.X.UnEBin;
    Temp2             = Temp2/sum(Temp2);
    for i1 = 1:NumjY
      Temp3           = Temp2.*double(AccSetU(:,i1) > 0);
      jxAccRateU(i1)  = nansum(Temp3(AccSetU(:,i1) == 1));
    end
    
    for ij = 1:NumjY
      jxAccRateE(ij)  = nansum(vec(AccSetE(:,:,ij) .*MatDen));
    end
    jxAccRateE        = jxAccRateE./nansum(vec(MatDen));
%   end
end
