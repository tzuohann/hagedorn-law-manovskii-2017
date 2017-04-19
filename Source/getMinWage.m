function xMinWBin = getMinWage(RD,C,M,MinWageOrder)
  %For each bin, identify all firms that have the bin in their acceptance set.
  %Each firm will have an average wage paid to workers in this bin.
  %Pick the lowest number of firms forming a bin that delivers lowest average wages above the previous minimum.
  %Workers who are ranked inconsistently are not used. Refer to Paper.
  %See user guide/data dictionary for more information.
    
  display('getMinWage')
  
  try X = RD.X; end
  
  if C.PerfectMinWage == 1
    xMinWBin    = M.MinWageOfWorker;
  elseif C.PerfectMinWage == 2
    xMinWBin    = M.ResWageOfWorker;
  else
    
    xMinWBin            = zeros(C.NumXBins,1);
    PrevMin             = -888888;
    for i1 = 1:C.NumXBins
      
      %Go through every firm
      WC    = sortrows([RD.J.WageU(i1,MinWageOrder(i1,:))',RD.J.MaxjSize(MinWageOrder(i1,:))],1);
      WC    = WC(~isnan(WC(:,1)),:);
      
      %Go over firms, add up to exceeding 600, then compare that to without
      %adding the last firm, and go close to 600.
      %If having to drop, drop the lowest, and repeat with remaining firms.
      Done = 0;
      while Done == 0
        NumJobsInBin = 0;
        ib = 0;
        while NumJobsInBin < C.NumAgentsSimMult;
          ib = ib + 1;
          NumJobsInBin = NumJobsInBin + WC(ib,2);
          if ib == size(WC,1)
            break
          end
        end
        if abs(C.NumAgentsSimMult - NumJobsInBin) < abs(C.NumAgentsSimMult - NumJobsInBin - WC(ib,2))
        else
          ib = ib - 1;
        end
        if ib == 0
          error
        end
        MinWage = wmean(WC(1:ib,1),WC(1:ib,2));
        if MinWage > PrevMin
          Done = 1;
          PrevMin = MinWage;
        else
          %Remove the lowest, and start over
          WC = WC(2:end,:);
        end
      end
      
      xMinWBin(i1) = PrevMin;
    end
  end
end
