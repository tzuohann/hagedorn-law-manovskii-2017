function M = computeModel(C,P,S,varargin)
  % Computes the model.
  disp('computeModel')
  
  if ~isempty(varargin)
    Post = 1;
  else
    Post = 0;
  end
  
  % Set random seed
  if S.FixSeed(1) > 0
    RandStream.setGlobalStream(RandStream('mcg16807','Seed',S.FixSeed(1)));
  end
  
  %First fix all the initial conditions;
  Surp          = C.Surp0;
  MatDen        = C.MatDen0;
  SurpPrev      = Surp;
  MatDenPrev    = C.MatDen0;
  TolExit       = C.TolExit;
  MatchSize     = C.MatchSize;
  DensY         = C.DensY;
  DensX         = C.DensX;
  AgentSize     = C.AgentSize;
  LenGrid       = C.LenGrid;
  Kkappa        = P.Kkappa;
  NnuS          = P.NnuS;
  NnuV          = P.NnuV;
  MeetFn        = str2func(P.MeetFn);
  Ddelta        = P.Ddelta;
  Aalpha        = P.Aalpha;
  Bbeta         = P.Bbeta;
  HomeProd      = P.HomeProd;
  VacCost       = P.VacCost;
  Prod          = C.Prod;
  Pphi          = P.Pphi;
  MaxIter       = C.MaxIter;
  Pf            = P.Pf;
  LenGridZ      = C.LenGridZ;
  ZetaProb      = C.ZetaProb;
  IterInfoDisp  = S.IterInfoDisp;

  disp(['OJS PHI = ',num2str(Pphi)])
  TolDen        = 666;
  TolSurp       = 666;
  iter          = 0;
  while (~((TolDen < TolExit) && (TolSurp < TolExit)) && (iter < MaxIter))
    
    iter = iter + 1;
    
    %Update the pure strat acceptance set.
    [AccSetU,AccSetE] = updateAccSetDet(Surp,LenGrid,Pphi);
    
    if Post == 0
      %This only applies for calculations before interpolation.

      %Construct the values that are needed.
      [ME,MU,~,~,~,VacDen,UnEDen] = ...
        constructValues(MatDen,MatchSize,DensY,DensX,AgentSize,Pphi,Kkappa,NnuS,NnuV,MeetFn,Pf);
      
      %Update the match density.
      MatDen  =   updateMatDen(MatDen,AccSetE,AccSetU,ME,VacDen,Ddelta,UnEDen,AgentSize,MU,ZetaProb,Pphi,MatchSize);
    end
    %Construct the values that are needed.
    [ME,MU,MV,CE,CU,VacDen,UnEDen] = ...
      constructValues(MatDen,MatchSize,DensY,DensX,AgentSize,Pphi,Kkappa,NnuS,NnuV,MeetFn,Pf);
    
    %Update the surplus.
    if P.Pphi > 0
      [Surp] = updateSurplusESC(Surp,LenGrid,Aalpha,MV,MatDen,AccSetE,...
        UnEDen,AccSetU,ME,VacDen,Ddelta,Bbeta,HomeProd,VacCost,Prod,MU,CE,CU);
    else
      [Surp] = ...
        updateSurplusU(Surp,LenGrid,Aalpha,MV,MatDen,...
        UnEDen,AccSetU,ME,VacDen,Ddelta,Bbeta,HomeProd,VacCost,Prod,MU,CE,CU,...
        P,ZetaProb,LenGridZ);
    end
    
    %Check the convergence criteria.
    TolDen      = sum(abs(vec(MatDen - MatDenPrev)))/sum(MatDen(:));
    TolSurp     = sum(abs(vec(Surp(AccSetU > 0) - SurpPrev(AccSetU > 0))))/sum(Surp(AccSetU > 0));
    
    if isnan(TolSurp)
      error('Surplus is NAN!')
    end
    
    MatDenPrev  = MatDen;
    SurpPrev    = Surp;
    
    if mod(iter,IterInfoDisp) == 0 || ((TolDen < TolExit) && (TolSurp < TolExit)) && Post == 0
      disp(['Iter : ',num2str(iter),' TolDen : ',num2str(TolDen),' TolSurp : ',num2str(TolSurp)])
    end
    
    %This only applies for calculations after interpolation is done.
    if Post == 1
      break
    end
  end
  
  %Obtain wages, values etc.
  if P.Pphi > 0
    [Surp,M] = updateSurplusESC(Surp,LenGrid,Aalpha,MV,MatDen,AccSetE,...
      UnEDen,AccSetU,ME,VacDen,Ddelta,Bbeta,HomeProd,VacCost,Prod,MU,CE,CU,P);
  else
    [Surp,M] = ...
      updateSurplusU(Surp,LenGrid,Aalpha,MV,MatDen,...
    UnEDen,AccSetU,ME,VacDen,Ddelta,Bbeta,HomeProd,VacCost,Prod,MU,CE,CU,P,ZetaProb,LenGridZ);
  end
  
  if ((TolDen < TolExit) && (TolSurp < TolExit))
    M.Converged = 1;
  else
    M.Converged = 0;
  end
  M.Surp      = Surp;
  
  %This only applies for calculations after interpolation is done.
  if Post == 1
    return
  end
  
  
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [Surp,varargout] = ...
    updateSurplusESC(Surp,LenGrid,Aalpha,MV,MatDen,AccSetE,...
    UnEDen,AccSetU,ME,VacDen,Ddelta,Bbeta,HomeProd,VacCost,Prod,MU,CE,CU,P)
  %Equations are for the special case OJS model.
  
  VacDenCond              = VacDen/sum(VacDen);
  MatDenCond              = MatDen/sum(MatDen(:));
  
  %Vacancy who meets employed worker gets surplus of the match less surplus
  %of the match the poached worker was in.
  SurpVacHireEmp  = MV * CE * sum(reshape(bsxfun(@times,AccSetE,MatDenCond) .* bsxfun(@plus,-Surp,permute(Surp,[1 3 2])),[],LenGrid))';
  
  %Unemployed worker gets the entire match of his first match.
  SurpUnEmpGetJob = MU * sum(bsxfun(@times, Surp , VacDenCond' ) .* AccSetU,2);
  
  %Surplus is obtained by combining the value functions in paper.
  Surp                  	= VacCost - HomeProd + ...
    bsxfun(@minus , bsxfun(@minus, Prod + Bbeta * (1.0 - Ddelta) * Surp , ...
    Bbeta * (1.0 - Ddelta) * SurpVacHireEmp') ...
    ,Bbeta * (1.0 - Ddelta) * SurpUnEmpGetJob);
  
  if nargout > 1
    
    OTmp = struct;
    %Values of being unmatched.
    ValUnE            = 1.0/(1.0 - Bbeta) * ( HomeProd + Bbeta * (1.0 - Ddelta) * SurpUnEmpGetJob );
    ValVac            = 1.0/(1.0 - Bbeta) * ( -VacCost + Bbeta * (1.0 - Ddelta) * SurpVacHireEmp );
    
    %ValEmp and ValJob is going to depend on where the worker is coming from.
    %WageW and WageF also depend on where worker is coming from.
    %D1 = x, D2 is y, D3 is yOrigin, LenGrid + 1 is unemployment.
    ValEmp            = zeros(LenGrid,LenGrid,LenGrid + 1);
    ValJob            = zeros(LenGrid,LenGrid,LenGrid + 1);
    WageW             = zeros(LenGrid,LenGrid,LenGrid + 1);
    WageF             = zeros(LenGrid,LenGrid,LenGrid + 1);
    for iy = 1:LenGrid
      %Worker gets surplus of where they were from, and if from
      %unemployment, surplus of the match.
      WorkSurp        = [Surp,Surp(:,iy)];
      
      %Value of employment via surplus division.
      ValEmp(:,iy,:)  = bsxfun(@plus,WorkSurp,ValUnE);
      
      %Jobs get Surplus of current match less surplus of poached workers'
      %previous match, or if hiring from unemployment, get nothing.
      JobSurp         = bsxfun(@plus,-[Surp,Surp(:,iy)],Surp(:,iy));
      
      %Value of job via surplus division.
      ValJob(:,iy,:)  = ValVac(iy) + JobSurp;
      
      %Probability of staying is probability of not meeting better match.
      StayProb        = 1.0 - ME * sum(bsxfun(@times,AccSetE(:,iy,:), reshape(VacDenCond,1,1,LenGrid)),3);
      
      %Wages from ValEmp and ValJob
      WageW(:,iy,:)   = bsxfun(@minus,squeeze(ValEmp(:,iy,:)) - bsxfun(@times,WorkSurp,Bbeta*(1-Ddelta)*StayProb), Bbeta*ValUnE + Bbeta*(1-Ddelta)*(1-StayProb).*Surp(:,iy));
      WageF(:,iy,:)   = bsxfun(@plus,bsxfun(@times,JobSurp,Bbeta * (1.0 - Ddelta) * StayProb) - squeeze(ValJob(:,iy,:)),Prod(:,iy)  + Bbeta*ValVac(iy));
    end
    
    AccSetU(AccSetU == 0) = nan;
    AccSetE(AccSetE == 0) = nan;
    
    ValEmp = bsxfun(@times,ValEmp,AccSetU);
    ValJob = bsxfun(@times,ValJob,AccSetU);
    
    Tmp                   = permute(AccSetE,[1,3,2]);
    WageW(:,:,1:end-1)    = WageW(:,:,1:end-1).*Tmp;
    WageF(:,:,1:end-1)    = WageF(:,:,1:end-1).*Tmp;
    ValEmp(:,:,1:end-1)   = ValEmp(:,:,1:end-1).*Tmp;
    ValJob(:,:,1:end-1)   = ValJob(:,:,1:end-1).*Tmp;
    
    
    OTmp.ValUnE       = ValUnE;
    OTmp.ValVac       = ValVac;
    OTmp.ValEmp       = ValEmp;
    OTmp.ValJob       = ValJob;
    OTmp.WageW        = WageW;
    OTmp.WageF        = WageF;
    OTmp.MatDen       = MatDen;
    OTmp.AccSetU      = AccSetU;
    OTmp.AccSetE      = AccSetE;
    OTmp.ME           = ME;
    OTmp.MU           = MU;
    OTmp.MV           = MV;
    OTmp.CE           = CE;
    OTmp.CU           = CU;
    OTmp.Prod         = Prod.*AccSetU;
    varargout{1}      = OTmp;
    checkEqbm(AccSetU,ValVac,ValUnE,P)
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [Surp,varargout] = ...
    updateSurplusU(Surp,LenGrid,Aalpha,MV,MatDen,...
    UnEDen,AccSetU,ME,VacDen,Ddelta,Bbeta,HomeProd,VacCost,Prod,MU,CE,...
    CU,P,ZetaProb,LenGridZ)

  %Equations here are for the no commitments OJS model.
  UnEDenCond              = UnEDen/sum(UnEDen);
  VacDenCond              = VacDen/sum(VacDen);
  
  %A vacancy expects to get this surplus.
  SurpCond                = bsxfun(@times,Surp,permute(bsxfun(@times,UnEDenCond,ZetaProb),[1 3 2]));
  SurpVacHireUnEmp        = (1.0 - Aalpha) * MV * CU .* sum(sum(SurpCond .* AccSetU,3),1 )';
  SurpUnEmpGetJob         = Aalpha * MU * sum(sum(bsxfun(@times, Surp , permute(bsxfun(@times,VacDenCond',ZetaProb'),[3 2 1]) ) .* AccSetU,3),2);
  SurpMatch               = Surp;
  
  Surp                  	= Prod + VacCost - HomeProd + ...
    Bbeta * (1.0 - Ddelta) * ...
    (SurpMatch ...
    - repmat(SurpVacHireUnEmp',[LenGrid,1,LenGridZ]) ...
    - repmat(SurpUnEmpGetJob,[1,LenGrid,LenGridZ]));
  
  if nargout > 1
    ValUnE            = 1.0/(1.0 - Bbeta) * ( HomeProd + Bbeta * (1.0 - Ddelta) * SurpUnEmpGetJob );
    ValVac            = 1.0/(1.0 - Bbeta) * ( -VacCost + Bbeta * (1.0 - Ddelta) * SurpVacHireUnEmp );
    ValEmp            = Aalpha*Surp + repmat(ValUnE,[1,LenGrid,LenGridZ]);
    ValJob            = (1.0 - Aalpha)*Surp + repmat(ValVac',[LenGrid,1,LenGridZ]);
    WageW             = ValEmp - Bbeta*repmat(ValUnE,[1,LenGrid,LenGridZ])  - Bbeta * (1.0 - Ddelta) * (Aalpha * SurpMatch);
    WageF             = Prod + Bbeta*repmat(ValVac',[LenGrid,1,LenGridZ]) - ValJob + Bbeta * (1.0 - Ddelta) * ((1.0 - Aalpha) * SurpMatch);
    
    AccSetU(AccSetU == 0) = nan;
    ValEmp                = ValEmp.*AccSetU;
    ValJob                = ValJob.*AccSetU;
    
    OTmp.ValUnE       = ValUnE;
    OTmp.ValVac       = ValVac;
    OTmp.ValEmp       = ValEmp;
    OTmp.ValJob       = ValJob;
    OTmp.WageW        = WageW;
    OTmp.WageF        = WageF;
    OTmp.MatDen       = MatDen;
    OTmp.AccSetU      = AccSetU;
    OTmp.ME           = ME;
    OTmp.MU           = MU;
    OTmp.MV           = MV;
    OTmp.CE           = CE;
    OTmp.CU           = CU;
    OTmp.Prod         = Prod.*AccSetU;
    varargout{1}      = OTmp;
    checkEqbm(AccSetU,ValVac,ValUnE,P)
  end
  
  if all(vec(Surp < 0))
    disp('All of Surp is negative.')
    keyboard
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [ME,MU,MV,CE,CU,VacDen,UnEDen] = ...
    constructValues(MatDen,MatchSize,DensY,DensX,AgentSize,Pphi,Kkappa,NnuS,NnuV,MeetFn,Pf)
  
  Emp        = sum(MatDen(:))*MatchSize;                 %Employment is unchanged from before
  VacDen     = DensY - AgentSize*sum(sum(MatDen,3),1)';  %Vacancy density from match density
  UnEDen     = DensX - AgentSize*sum(sum(MatDen,3),2);   %Unemployment density from match density
  UnE        = 1 - Emp;                           %Unemployment mass
  Vacs       = Pf - Emp;                          %Vacancy mass
  EffSW      = UnE + Pphi*Emp;                    %Mass of efficient workers searching
  EffSF      = Vacs;                              %There is no OJS for firms
  
  if any(UnEDen < 0) || any(UnEDen > DensX)
    disp('UnEDen Error')
    keyboard
  end
  
  %--------------------------------------------------------------------------------------
  %Mass of Meets generated by the meeting function
  NumMeets   = MeetFn(EffSW,EffSF,Kkappa,NnuS,NnuV);
  
  ME        = Pphi*NumMeets/EffSW;     %Probability of a meeting for employed
  MU        = NumMeets/EffSW;          %Probability meeting for unemployed
  MV        = NumMeets/EffSF;          %Probability meeting for vacancy
  
  CE        = Pphi*Emp/EffSW;        %Cond prob of meeting employed
  CU        = UnE/EffSW;             %Cond prob of meeting unemployed
  
  if isnan(MV)
    disp('MV is nan')
    keyboard
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [AccSetU,AccSetE] = updateAccSetDet(Surp,LenGrid,Pphi)
  AccSetU = double(Surp > 0);
  AccSetE = nan(LenGrid,LenGrid,LenGrid);
  if Pphi > 0
    AccSetE = bsxfun(@times,double(bsxfun(@lt,Surp,permute(Surp,[1 3 2]))),AccSetU);
  end
  if all(AccSetU(:) == 0)
    disp('All AccSetU is Zero')
    keyboard
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function MatDen = updateMatDen(MatDen,AccSetE,AccSetU,ME,VacDen,Ddelta,UnEDen,AgentSize,MU,ZetaProb,Pphi,MatchSize)
  VacDenCond              = VacDen/sum(VacDen);
  MeetAndShock            = bsxfun(@times,bsxfun(@times, UnEDen , VacDenCond'),point(ZetaProb,3));
  UnEmp2Match             = (MU / AgentSize) .* bsxfun(@times,AccSetU , MeetAndShock) ;
  if Pphi > 0
    %Computational variable. Acceptance probability and also the prob of
    %obtaining the next shock.
    AccSetECond             = bsxfun(@times,AccSetE,point(VacDenCond,3));
    %Movement In
    Emp2Match               = ME .* squeeze(sum(bsxfun(@times,AccSetECond,MatDen),2));
    %Movement Out
    Match2OtherMatch        = ME .* sum(AccSetECond,3) .*  MatDen;
  else
    Emp2Match             = 0;
    Match2OtherMatch      = 0;
  end
  MatDen                  = (1.0 - Ddelta) .* (MatDen + UnEmp2Match + Emp2Match - Match2OtherMatch);
  MatDen(MatDen < 1e-10)  = 0;
  MatDen(AccSetU == 0)    = 0;
  if all(MatDen(:) == 0)
    disp('All MatDen is Zero')
    keyboard
  end
  if sum(MatDen(:))*MatchSize > 1
    disp('Too many matches')
    keyboard
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function checkEqbm(varargin)
  for i1 = 1:numel(varargin)
    eval([inputname(i1),'= varargin{i1};']);
  end

  if exist('AccSetU','var') == 1
    %%%%%Detect anomalies in the acceptance set
    %Null acceptance for workers or firms
    if any(nansum(nansum(AccSetU,1),3) == 0)
      disp('Parameterization')
      surf(nansum(AccSetU,3)')
      error('Null Acceptance Set for Firm ')
    elseif any(nansum(nansum(AccSetU,2),3) == 0)
      disp('Parameterization')
      P      
      error('Null Acceptance Set for Worker ')
    end
    if sum(vec(isnan(AccSetU))) == 0
      disp('Parameterization')
      P      
      error('Full acceptance set - all (x,y,z) accepted')
    end
    if all(vec(nansum(AccSetU,3))) > 0
      fprintf(2,'Full acceptance set - all (x,y) accepted for some (z)\n')
    end
  end
  if exist('ValVac','var') == 1
    if any(ValVac < 0)
      disp('Parameterization')
      P      
      error('Value of Vacancy is Negative')
    end
  end
  if exist('ValUnE','var') == 1
    if any(ValUnE < 0)
      disp('Parameterization')
      P      
      error('Value of Unemployment is Negative')
    end
  end
end

