function [M] = postProcessOutput(C,P,M)
  %Get numbers that we want to use. This is everything theoretical.
  %First, interpolate everything.
  
  %Vacancy Densities and Unemployment Densities. This is the mass of vacancies
  %and unemployed workers for a given type.
  M.VacMass             = (C.DensY - vec(sum(sum(M.MatDen,3),1)*C.AgentSize))*C.AgentSize;
  M.UnEMass             = (C.DensX - sum(sum(M.MatDen,3),2)*C.AgentSize)*C.AgentSize;
  
  %Employment (Measure)
  M.Emp                 = sum(M.MatDen(:))*C.MatchSize;
  M.UnE                 = 1 - M.Emp;
  
  %Inflow from Unemployment and Vacancies - This is mass or measure that
  %successfully make the move (including surviving the delta shock)
  %Here, Delta of employed exit, so those who find jobs must equal that.
  M.EUMass              = P.Ddelta*M.Emp;
  
  %Inflow from Employment and Vacancies due to OJS - This is mass or measure
  VacDenCond              = M.VacMass./sum(M.VacMass);
  if P.Pphi > 0
    M.EEMass              = M.Emp*M.ME*(1 - P.Ddelta)*sum(vec(M.MatDen/sum(vec(M.MatDen)).*nansum(M.AccSetE.*repmat(point(M.VacMass./sum(M.VacMass),3),C.LenGrid,C.LenGrid),3)));
  else
    M.EEMass              = nan;
  end
  
  % Inflow due to OJS as a fraction of the reference population
  M.EERate              = M.EEMass/M.Emp;
  
  %Inflow from Employment and Vacancies due to OJS - This is mass or measure
  Temp                  = permute(bsxfun(@times,VacDenCond',C.ZetaProb'),[3,2,1]);
  M.UEMass              = sum(M.UnEMass.*M.MU*(1 - P.Ddelta).*nansum(nansum(bsxfun(@times,M.AccSetU,Temp),3),2));
  
  % Inflow due to hiring from unemployment as a fraction
  M.UERate              = M.UEMass/(1-M.Emp);
  
  %Restrict surplus to positive numbers
  M.SurpModel           = M.Surp;
  M.Surp(M.Surp<0)      = nan;
  
  %Taking average of wages computed in two ways
  M.Wage                = (M.WageF+M.WageW)/2;
  
  %Keep everything to check against WW.
  M.WageAll             = M.Wage;
  
  %Restricting wages to locations where density is strictly positive
  M.Wage(M.MatDen<=0)   = nan;
  
  %If there are locations where wages is slightly negative, make them the
  %smallest wage in the economy that is positive.
  M.Wage(M.Wage<0)      = min(vec(M.Wage(M.Wage > 0)));
  
  %Firm flow profits
  M.Profit              = bsxfun(@plus,-M.Wage,C.Prod);
  
  %Wage dynamics. See dataDictionary for definitions if unclear from names.
  M.MinWageOfWorker     = zeros(C.LenGrid,1);
  M.MaxWageOfWorker     = zeros(C.LenGrid,1);
  M.ResWageOfWorker     = zeros(C.LenGrid,1);
  M.WDiff               = zeros(size(M.Wage));
  M.WDiffRes            = zeros(size(M.Wage));
  for ixt = 1:C.LenGrid
    M.MinWageOfWorker(ixt,1)                        = nanmin(vec(M.Wage(ixt,:,:)));
    M.MaxWageOfWorker(ixt,1)                        = nanmax(vec(M.Wage(ixt,:,:)));
    M.ResWageOfWorker(ixt,1)                        = (1-P.Bbeta)*M.ValUnE(ixt);
    M.WDiff(ixt,:,:)                                = M.Wage(ixt,:,:) - M.MinWageOfWorker(ixt);
    M.WDiffRes(ixt,:,:)                             = M.Wage(ixt,:,:) - M.ResWageOfWorker(ixt);
  end
  
  M.EffSW           = P.Pphi*M.Emp + (1 - M.Emp);
  M.EffSF           = P.Pf - M.Emp;
  
  M.ProbUnEAccJob           = nansum(nansum(M.AccSetU.*bsxfun(@times,repmat((M.VacMass'./sum(M.VacMass)),[C.LenGrid,1,C.LenGridZ]),permute(C.ZetaProb,[1 3 2])),3),2);
  M.ProbVacAccUnE           = nansum(nansum(M.AccSetU.*bsxfun(@times,repmat((M.UnEMass./sum(M.UnEMass)),[1,C.LenGrid,C.LenGridZ]),permute(C.ZetaProb,[1 3 2])),3),1)';
  M.ProbVacHireUnE          = M.MV * M.CU .* (1-P.Ddelta) .* M.ProbVacAccUnE;
  M.ProbVacAccEmp           = nan(C.LenGrid,1);
  if P.Pphi > 0
    for i1 = 1:C.LenGrid
      M.ProbVacAccEmp(i1,1)   = nansum(vec(M.MatDen.*M.AccSetE(:,:,i1)))./sum(M.MatDen(:));
    end
  end
  M.ProbVacHireEmp          = M.ProbVacAccEmp.*(1-P.Ddelta);
  
  M.Prod                    = C.Prod;
  M.Prod(isnan(M.AccSetU))  = nan;
  
  if P.Pphi                 == 0
    M.yAveWDiff               = vec(nansum(nansum(M.MatDen.*M.WDiff,3),1)./sum(sum(M.MatDen,3),1));
    M.yAveWDiffRes            = vec(nansum(nansum(M.MatDen.*M.WDiffRes,3),1)./sum(sum(M.MatDen,3),1));
  else
    %True statistics
    yEEWageDiff  = zeros(C.LenGrid,1);
    for iy = 1:C.LenGrid
      yEEWageDiff(iy)  =   nansum(vec(M.MatDen.*M.AccSetE(:,:,iy).*(repmat(M.Wage(:,iy,end),1,C.LenGrid) - M.Wage(:,:,end))));
    end
    M.yEEWageDiff = yEEWageDiff./nansum(M.MatDen(:));
  end
  
  %Var log wages calculations.
  M.MatDenOrigin  = zeros(size(M.Wage));
  if P.Pphi == 0
    M.MatDenOrigin  = M.MatDen;
  else
    %This is approximate since we may or may not have a true eqbm from the
    %interpolation.
    VacMassCond     = M.VacMass./sum(M.VacMass);
    for ix = 1:C.LenGrid
      for iy = 1:C.LenGrid
        %This is the origin from unemployment
        MoveProb                    =   nansum(VacMassCond.*vec(M.AccSetE(ix,iy,:)));
        M.MatDenOrigin(ix,iy,end)   =  (1-P.Ddelta) * M.UnEMass(ix) * M.MU * VacMassCond(iy) * M.AccSetU(ix,iy) / (P.Ddelta + ( 1 - P.Ddelta ) * M.ME .* MoveProb) ./ C.MatchSize;
        if M.MatDenOrigin(ix,iy,end) < 0
          keyboard
        end
        for iyO = 1:C.LenGrid
          MoveInProb      =   VacMassCond(iy).*vec(M.AccSetE(ix,iyO,iy));
          MoveOutProb     =   nansum(VacMassCond.*vec(M.AccSetE(ix,iy,:)));
          M.MatDenOrigin(ix,iy,iyO)   =  (1-P.Ddelta) * M.MatDen(ix,iyO) * M.ME * MoveInProb / (P.Ddelta + ( 1 - P.Ddelta ) * M.ME .* MoveOutProb);
        end
      end
    end
  end
  M.MatDenOrigin(isnan(M.MatDenOrigin)) = 0;
  
  LogWage   = log(M.Wage);
  if P.Pphi > 0
    LogProd   = log(repmat(M.Prod,[1,1,size(M.Wage,3)]));
  else
    LogProd   = log(M.Prod);
  end
  %Overall var log wages
  M.VarLogWage = nanvar(vec(LogWage),vec(M.MatDenOrigin));
  M.VarLogProd = nanvar(vec(LogProd),vec(M.MatDenOrigin));
  
  %Overall var log wages U
  if P.Pphi == 0
    M.VarLogWageU = nanvar(vec(LogWage),vec(M.MatDenOrigin));
    M.VarLogProdU = nanvar(vec(LogProd),vec(M.MatDenOrigin));
  end
  if P.Pphi > 0
    M.VarLogWageU = nanvar(vec(LogWage(:,:,end)),vec(M.MatDenOrigin(:,:,end)));
    M.VarLogProdU = nanvar(vec(LogProd(:,:,end)),vec(M.MatDenOrigin(:,:,end)));
    M.VarLogWageE = nanvar(vec(LogWage(:,:,1:end-1)),vec(M.MatDenOrigin(:,:,1:end-1)));
    M.VarLogProdE = nanvar(vec(LogProd(:,:,1:end-1)),vec(M.MatDenOrigin(:,:,1:end-1)));
  else
    M.VarLogWageE = nan;
    M.VarLogProdE = nan;
  end
  
  %Cond X var log wages
  M.VarLogWageX     = zeros(C.LenGrid,1);
  M.VarLogWageUX    = zeros(C.LenGrid,1);
  M.VarLogWageY     = zeros(C.LenGrid,1);
  M.VarLogWageUY    = zeros(C.LenGrid,1);
  M.VarLogWageEX    = nan(C.LenGrid,1);
  M.VarLogWageEY    = nan(C.LenGrid,1);
  M.VarLogProdX     = zeros(C.LenGrid,1);
  M.VarLogProdUX    = zeros(C.LenGrid,1);
  M.VarLogProdY     = zeros(C.LenGrid,1);
  M.VarLogProdUY    = zeros(C.LenGrid,1);
  M.VarLogProdEX    = nan(C.LenGrid,1);
  M.VarLogProdEY    = nan(C.LenGrid,1);
  for i1 = 1:C.LenGrid
    if P.Pphi == 0
      M.VarLogWageUX(i1)   = nanvar(vec(LogWage(i1,:,:)),vec(M.MatDenOrigin(i1,:,:)));
      M.VarLogWageX(i1)    = nanvar(vec(LogWage(i1,:,:)),vec(M.MatDenOrigin(i1,:,:)));
      M.VarLogWageUY(i1)   = nanvar(vec(LogWage(:,i1,:)),vec(M.MatDenOrigin(:,i1,:)));
      M.VarLogWageY(i1)    = nanvar(vec(LogWage(:,i1,:)),vec(M.MatDenOrigin(:,i1,:)));
      M.VarLogProdUX(i1)   = nanvar(vec(LogProd(i1,:,:)),vec(M.MatDenOrigin(i1,:,:)));
      M.VarLogProdX(i1)    = nanvar(vec(LogProd(i1,:,:)),vec(M.MatDenOrigin(i1,:,:)));
      M.VarLogProdUY(i1)   = nanvar(vec(LogProd(:,i1,:)),vec(M.MatDenOrigin(:,i1,:)));
      M.VarLogProdY(i1)    = nanvar(vec(LogProd(:,i1,:)),vec(M.MatDenOrigin(:,i1,:)));
    elseif P.Pphi > 0
      M.VarLogWageUX(i1)   = nanvar(vec(LogWage(i1,:,end)),vec(M.MatDenOrigin(i1,:,end)));
      M.VarLogWageX(i1)    = nanvar(vec(LogWage(i1,:,:)),vec(M.MatDenOrigin(i1,:,:)));
      M.VarLogWageUY(i1)   = nanvar(vec(LogWage(:,i1,end)),vec(M.MatDenOrigin(:,i1,end)));
      M.VarLogWageY(i1)    = nanvar(vec(LogWage(:,i1,:)),vec(M.MatDenOrigin(:,i1,:)));
      M.VarLogProdUX(i1)   = nanvar(vec(LogProd(i1,:,end)),vec(M.MatDenOrigin(i1,:,end)));
      M.VarLogProdX(i1)    = nanvar(vec(LogProd(i1,:,:)),vec(M.MatDenOrigin(i1,:,:)));
      M.VarLogProdUY(i1)   = nanvar(vec(LogProd(:,i1,end)),vec(M.MatDenOrigin(:,i1,end)));
      M.VarLogProdY(i1)    = nanvar(vec(LogProd(:,i1,:)),vec(M.MatDenOrigin(:,i1,:)));
      M.VarLogWageEX(i1)   = nanvar(vec(LogWage(i1,:,1:end-1)),vec(M.MatDenOrigin(i1,:,1:end-1)));
      M.VarLogWageEY(i1)   = nanvar(vec(LogWage(:,i1,1:end-1)),vec(M.MatDenOrigin(:,i1,1:end-1)));
      M.VarLogProdEX(i1)   = nanvar(vec(LogProd(i1,:,1:end-1)),vec(M.MatDenOrigin(i1,:,1:end-1)));
      M.VarLogProdEY(i1)   = nanvar(vec(LogProd(:,i1,1:end-1)),vec(M.MatDenOrigin(:,i1,1:end-1)));
    end
  end
  M.VarLogWageFracX = wmean(M.VarLogWageX,sum(sum(M.MatDen,3),2))./M.VarLogWage;
  
  %Acceptance probability conditional on (x,y)
  M.ZAccProb    = nansum(bsxfun(@times,M.AccSetU,point(C.ZetaProb,3)),3);
  M.MinWageZ    = nanmin(M.Wage,[],3);
  M.WW          = M.WageAll(:,:,ceil(C.LenGridZ/2));
  M.TrueThreshold   = (M.MinWageZ - M.WW)/P.Aalpha;
  
  M.AverageProd = nansum(M.Prod.*M.MatDen,3)./nansum(M.MatDen,3);
  M.AverageWage = nansum(M.Wage.*M.MatDenOrigin,3)./nansum(M.MatDenOrigin,3);
end
