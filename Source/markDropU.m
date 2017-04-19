function [AccSetU,iDropped]     = markDropU(RD,C,SimO,M,LL,NumjY,jYNameY,JobNamejY,jID,iDropped)
  % [AccSetUTrue,ToMoveU,AccSetUNoDrop,AccSetU,iDropped]     = markDropU(RD,C,SimO,M,LL,NumjY,jYNameY,JobNamejY,jID)
  %Determine the matches where workers are likely to be misranked.
  %See user guide/data dictionary for more information.
  disp('markDropU')
  
  AllW                          = LL.HiredWorkerSpells;
  AllWBins                      = AllW;
  AllWBins(AllW > 0)            = RD.I.iBin(AllW(AllW > 0));
%   p                             = getP(C.LenGrid,SimO.Numj,RD.I.iBin,AllW,JobNamejY,zeros(C.NumAgentsSim,1));
  p                             = getP(C.LenGrid,SimO.Numj,JobNamejY,AllWBins);
  ProbAccZ    = double(p > 0);
  
  if C.DropExt == 0
    iDropped = zeros(C.NumAgentsSim,1);
    AccSetU  = double(p > 0);
    return
  end

  AccSetUTrue                 = zeros(C.LenGrid,NumjY);
  for i1 = 1:NumjY
    AccSetUTrue(:,jYNameY == i1)         = max(M.AccSetU(:,jYNameY(jYNameY == i1),:),[],3);
  end
  
  Pi_xj                         = getPi(p,RD.X.UnEBin,ProbAccZ);
  BinoCDF                       = zeros(size(p));
  for i1 = 1:size(p,2)
    Nj                          = sum(LL.Nj(jID == i1));
    BinoCDF(:,i1)               = binocdf(p(:,i1),ones(C.LenGrid,1).*Nj,Pi_xj(:,i1));
  end
  
  BinoCDF(p == 0)               = 0;
  AccSetUNoDrop                 = p > 0;
  
  [ToMoveU, AccSetU, iDropped] = getAccMove(BinoCDF,C,p,AllW,SimO,AllWBins,NumjY,JobNamejY,iDropped);
end

function Pi_xj = getPi(p,UnEBin,ProbAccZ)
  %Get conditional distribution of workers across matching sets for all firms.
  %See user guide/data dictionary for more information.
  %Author: Tzuo Hann Law (tzuohann@gmail.com)
  AccSetT  = p > 0;
  %RD.X.xUnEBin is 50 by 1. Transpose it. Uj is 1 by 50;
  Uj     = nansum(bsxfun(@times,(AccSetT.*ProbAccZ),UnEBin));
  %diag(X) puts X on a diagonal.
  Pi_xj  = bsxfun(@times,AccSetT.*ProbAccZ,UnEBin);
  %Divide so that along the cols, it sums to 1.
  Pi_xj  = bsxfun(@times,1./Uj,Pi_xj);
end

function [ToMove, AccSet, iDropped] = getAccMove(BinoCDF,C,p,AllW,SimO,AllWBins,NumjY,JobNamejY,iDropped)
  %[ToMove, AccSet, iDropped] = getAccMove(BinoCDF,C,p,AllW,SimO,AllWBins,NumjY,JobNamejY)
  %Here we determine which matches between firms and worker bins are inconsistent with the observed unemployment rates.
  %See user guide/data dictionary for more information.
  %Author: Tzuo Hann Law (tzuohann@gmail.com)
  AccSet        = p > 0;
  ToMove        = zeros(size(p));
  %Identify the people who are supposed to be moved according to cutoff criteria
  DroppedAnything = ones(1,NumjY);
  while any(DroppedAnything == 1)
    for i1 = 1:NumjY
      if DroppedAnything(i1) == 1
        DroppedAnything(i1) = 0;
        OffBin = false(C.LenGrid,1);
        %Get all the offending bins
        %First the two sides.
        if BinoCDF(1,i1) < C.DropExt && AccSet(1,i1) == 1
          OffBin(1)      = true;
          DroppedAnything(i1) = 1;
        end
        if BinoCDF(end,i1) < C.DropExt && AccSet(end,i1) == 1
          OffBin(end)      = 1;
          DroppedAnything(i1) = 1;
        end
        %Then all the interiors.
        %First the flagged part
        for i2 = 2:C.LenGrid - 1
          if ~(AccSet(i2+1,i1) > 0 && AccSet(i2-1,i1) > 0) && BinoCDF(i2,i1) < C.DropExt && AccSet(i2,i1) == 1
            OffBin(i2)      = true;
            DroppedAnything(i1) = 1;
          end
        end
        %If the guys should be 'dropped', mark them.
        if any(OffBin)
          ToMove(OffBin,i1) = 1;
          AccSet(OffBin,i1) = 0;
          OffBin              = double(OffBin).*(1:C.LenGrid)';
          %These are the workers who have to be moved.
          WB                  = [nonzeros(AllW(JobNamejY == i1,:)),nonzeros(AllWBins(JobNamejY == i1,:))];
          TempLoc             = unique(WB(ismember(WB(:,2),OffBin)));
          iDropped(TempLoc)   = 1;
        end
      end
    end
  end
  AccSet                = double(AccSet);
  if any(sum(AccSet) == 0)
    warning('Some firm rejects all workers.')
  end
end
