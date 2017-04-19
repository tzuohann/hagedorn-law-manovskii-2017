function J = getWMob(C,SimO,RD,L,Sim,M,P)

  display('getWMob')
  
  %Workers that a firm hires from the complete history.
  HWN = L.HiredWorkerName;
  
  Start             = 2;
  Inc               = 1;
  PeriodsObs        = Start:Inc:C.Periods;
  FirmSize          = nan(SimO.Numj,C.Periods - 1);
  NNHUFull          = zeros(SimO.Numj,C.Periods - 1);
  NNHEFull          = zeros(SimO.Numj,C.Periods - 1);
  NLWEFull          = zeros(SimO.Numj,C.Periods - 1);
  AccSetEMob        = zeros(C.LenGrid,SimO.Numj,SimO.Numj);
  % Total number of vacancies in economy. May not be used.
  VacsFull          = sum(HWN(:,PeriodsObs) == 0)';
  
  if C.PerfectWMob == 1
    J.EmpShare     = (1./C.LenGrid - M.VacMass(SimO.jNameY))/sum(1./C.LenGrid - M.VacMass(SimO.jNameY));
    Temp           = vec(sum(sum(M.MatDen,3))/(C.LenGrid'*P.Pf));
    FirmSize       = SimO.FirmSize.*Temp(SimO.jNameY);
    NNHUFull       = (SimO.FirmSize - FirmSize)*M.MV*M.CU*(1-P.Ddelta).*M.ProbVacAccUnE(SimO.jNameY);
    NNHEFull       = (SimO.FirmSize - FirmSize)*M.MV*M.CE*(1-P.Ddelta).*M.ProbVacAccEmp(SimO.jNameY);
    VacsFull       = (SimO.FirmSize - FirmSize);
    NLWEFull       = NNHUFull + NNHEFull - P.Ddelta*FirmSize;
    if P.Pphi > 0
      for ij = 1 : SimO.Numj
        AccSetEMob(:,:,ij)  = M.AccSetE(:,SimO.jNameY,SimO.jNameY(ij));
      end
    end
  else
    
    SimjName          = recodeAs(Sim.SimJobName,SimO.JobNamej);
    for iy = 1:SimO.Numj
      % Jobs belonging to a firm.
      Temp                 = SimO.JobNamej == iy;
      % Size of firm once per year.
      FirmSize(iy,:)       = sum(HWN(Temp,PeriodsObs)>0);
      % Workers who are at firm now and previously unemployed.
      Workers              = HWN(Temp,:);
      it = 0;
      for iY = 2:C.Periods
        it = it + 1;
        for ij = 1:size(Workers,1)
          if Workers(ij,iY) > 0
            %There is a worker. Check if he was at same firm in previous
            %period
            if Workers(ij,iY-1) == Workers(ij,iY)
              %Worker was at same firm.
            elseif SimjName(Workers(ij,iY),iY-1) == 0
              %Worker was unemployed.
              NNHUFull(iy,it)   = NNHUFull(iy,it) + 1;
            elseif SimjName(Workers(ij,iY),iY-1) ~= SimjName(Workers(ij,iY),iY)
              %Worker was at a different firm.
              %Counts as job to job hire for this firm.
              NNHEFull(iy,it)   = NNHEFull(iy,it) + 1;
              %And record the acceptance set.
              if P.Pphi > 0
                AccSetEMob(RD.I.iBin(Workers(ij,iY)),SimjName(Workers(ij,iY),iY-1),SimjName(Workers(ij,iY),iY)) = ...
                  AccSetEMob(RD.I.iBin(Workers(ij,iY)),SimjName(Workers(ij,iY),iY-1),SimjName(Workers(ij,iY),iY)) + 1;
              end
              %And record as a loss for the previous firm.
              NLWEFull(SimjName(Workers(ij,iY),iY-1),it)   = NLWEFull(SimjName(Workers(ij,iY),iY-1),it) + 1;
            else
              error('Something is wrong.')
            end
          end
        end
      end
      J.EmpShare   = sum(FirmSize,2)/sum(vec(FirmSize));
    end
  end
  
  J.FirmSize        = FirmSize;
  J.jVacs           = bsxfun(@minus,SimO.FirmSize,FirmSize);
  J.NNHUFull        = NNHUFull;
  J.NNHEFull        = NNHEFull;
  J.VacsFull        = VacsFull;
  J.AccSetEMob      = AccSetEMob;
  J.NLWEFull        = NLWEFull;
  
end
