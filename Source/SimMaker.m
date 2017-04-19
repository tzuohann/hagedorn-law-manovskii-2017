function [SimO,Sim] = SimMaker(M,C,P,S)
  
  %Generate some utility variables
  [SimO]                                = firmSpecificUtilityVariables(C);
  
  display('SimMaker')
  
  RandStream.setGlobalStream(RandStream('mcg16807','Seed',S.FixSeed(2)));
  
  %Initialize transitions and employment.
  SimO.Emp					  = zeros(C.Periods + C.BurnIn -1,1);
  
  %Initialize the economy to steady state.
  [SimO,SimJobName,VacancyLine,SimShock]         = Initialize(SimO,M,C,P);
  
  %Some variable that is used many times.
  TTemp					= [vec(1:C.NumAgentsSim),ones(C.NumAgentsSim,1)];
  
  display(strcat(['Target employment : ',num2str(M.Emp,'%7.5f')]))
  %Number of meets to be dished SimJobName in each period is here
  tempfn					= str2func(P.MeetFn);
  
  for i1 = 1:C.Periods + C.BurnIn - 1
    
    %Employed people are those who are at firm with ID < NumJobsSim + 1.
    SimO.Emp(i1)  = sum(SimJobName(:,i1) < C.NumJobsSim + 1)./C.NumAgentsSim;
    
    % Efficient firms searching are excess of workers.
    EffSF         = P.Pf - SimO.Emp(i1);
    
    % Workers sum to 1
    EffSW         = 1 - SimO.Emp(i1) + P.Pphi*SimO.Emp(i1);
    
    % Generate number of meets
    NumMeets = floor(C.NumAgentsSim*tempfn(EffSF,EffSW,P.Kkappa,P.NnuS,P.NnuV));
    
    % Update from this period to next
    [SimJobName(:,i1+1),VacancyLine,SimO,SimShock(:,i1+1)] = Updater(TTemp,SimJobName(:,i1),SimO,P,VacancyLine,C,i1,NumMeets,M,SimShock(:,i1));
    
  end
  
  %Replace nan for non matched entries.
  SimJobName(SimJobName == C.NumJobsSim + 1) = nan;
  SimShock(SimJobName == C.NumJobsSim + 1)   = nan;
  
  %Compute the job mobility rates in fractions. (Mass/Reference)
  %All numbers at t involving levels is for t, if it is a fraction, the
  %reference mass is fromt t-1.
  [Emp2UnE,UnE2Emp,Emp2Emp] = getSimMobRates(SimJobName,C);
  
  SimO.Emp2UnE    = Emp2UnE(C.BurnIn:C.BurnIn + C.Periods-1);
  SimO.UnE2Emp    = UnE2Emp(C.BurnIn:C.BurnIn + C.Periods-1);
  SimO.Emp2Emp    = Emp2Emp(C.BurnIn:C.BurnIn + C.Periods-1);
  SimO.Emp        = SimO.Emp(C.BurnIn:C.BurnIn + C.Periods-1);
  
  %Select simulation after BurnIn period.
  Sim.SimJobName  = SimJobName(:,C.BurnIn + 1 : C.BurnIn + C.Periods);
  Sim.SimShock    = SimShock(:,C.BurnIn + 1 : C.BurnIn + C.Periods);
  
  %Remove the last one which proxied for unemployment.
  SimO.JobNameY   = SimO.JobNameY(1:end-1);
  SimJobName(isnan(SimJobName)) = 0;
  
  %Obtain initial jobs of each employment. For NOOJS, it is just 0.
  Sim.SimInitJob       = getSimInitJob(Sim,C,SimJobName);
  
  %Prep stuff. Add noise.
  SimO.MatDenSim	= MakeSimMatDen(Sim,C,SimO);
  [Sim,SimO]      = RegressionPrep(Sim,SimO,C,M,P);
  if any(sum(Sim.SimJobName,2) == 0)
    error('Some Worker Never Works')
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function SimInitJob = getSimInitJob(Sim,C,SimJobName)
  %Fix the initial job
  %nan means not applicable. 0 is from unemployment, +Num is the firm name.
  SimInitJob           = nan(size(Sim.SimJobName));
  Init                 = nan(C.NumAgentsSim,1);
  Init(isnan(Sim.SimJobName(:,1))) = 0;
  %Move back to find unemployment or some previous job.
  for it = C.BurnIn : -1 : 1;
    Init(isnan(Init) & SimJobName(:,it) ~= SimJobName(:,it+1)) = SimJobName(isnan(Init) & SimJobName(:,it) ~= SimJobName(:,it+1),it);
  end
  
  %If going far back doesn't find anything, assume unemployment.
  Init(isnan(Init)) = 0;
  SimInitJob(:,1) = Init;
  for it = 2:C.Periods
    Tmp = SimJobName(:,C.BurnIn + it) == SimJobName(:,C.BurnIn + it - 1);
    SimInitJob(Tmp,it) = SimInitJob(Tmp,it-1);
    SimInitJob(~Tmp,it) = SimJobName(~Tmp,C.BurnIn + it - 1);
  end
  SimInitJob(isnan(Sim.SimJobName)) = nan;
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [Emp2UnE,UnE2Emp,Emp2Emp] = getSimMobRates(SimJobName,C)
  NumEmpPrev    = sum(~isnan(SimJobName(:,1)));
  NumUnEmpPrev  = C.NumAgentsSim - NumEmpPrev;
  Emp2UnE       = zeros(C.Periods + C.BurnIn - 1,1);
  UnE2Emp       = zeros(C.Periods + C.BurnIn - 1,1);
  Emp2Emp       = zeros(C.Periods + C.BurnIn - 1,1);
  for i1 = 2:size(SimJobName,2)
    NumEmpNow         = sum(~isnan(SimJobName(:,i1)));
    NumUnEmpNow       = C.NumAgentsSim - NumEmpNow;
    Emp2UnE(i1)       = sum(isnan(SimJobName(:,i1)) & ~isnan(SimJobName(:,i1-1)))/NumEmpPrev;
    UnE2Emp(i1)       = sum(~isnan(SimJobName(:,i1)) & isnan(SimJobName(:,i1-1)))/NumUnEmpPrev;
    Emp2Emp(i1)       = sum(~isnan(SimJobName(:,i1-1)) & ~isnan(SimJobName(:,i1)) & SimJobName(:,i1-1) ~= SimJobName(:,i1))/NumEmpPrev;
    NumEmpPrev        = NumEmpNow;
    NumUnEmpPrev      = NumUnEmpNow;
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [SimO,SimJobName,VacancyLine,SimShock] = Initialize(SimO,M,C,P)
  %Construct the initial population distribution.
  [InitNum,SimO]			= InitNumMake(SimO,M,C,P);
  
  %Firms and workers are recorded in their own cells. These are workers and
  %firms who are not in matches.
  Firms           = cell(C.LenGrid,1);
  Workers					= cell(C.LenGrid,1);
  
  %This is the conversion between names and types
  SimO.JobNameY			= zeros(C.NumJobsSim,1);
  SimO.iNameX			  = zeros(C.NumAgentsSim,1);
  
  %Here, we are assigning a name from 1:NumAgentsSim or 1:NumJobsSim to each
  %type. Also populating the Firms and Workers cells. Not idea for what just
  %yet.
  for i1 = 1:C.LenGrid
    Firms{i1}			  = (i1-1)*C.NumJobsSimMult +  randperm(C.NumJobsSimMult);
    Workers{i1}			= (i1-1)*C.NumAgentsSimMult +  randperm(C.NumAgentsSimMult);
    
    SimO.JobNameY((i1-1)*C.NumJobsSimMult + 1 : i1*C.NumJobsSimMult) = i1;
    SimO.iNameX((i1-1)*C.NumAgentsSimMult + 1 : i1*C.NumAgentsSimMult) = i1;
  end
  
  %Number of firms can be larger than number of workers. This is coded for
  %unemployment.
  SimO.JobNameY(C.NumJobsSim+1) = C.LenGrid+1;
  
  VacancyLine = SimO.jobNames;
  
  %This is the match between workers and firms. Initialize everyone to unemployment
  %Recall from previous line that employed at NumJobsSim+1 is unemployment. The
  %shock grid index number is coded into the imaginary portion of SimJobName.
  SimJobName    = ones(C.NumAgentsSim,C.Periods+C.BurnIn).*(C.NumJobsSim + 1);
  SimShock      = zeros(C.NumAgentsSim,C.Periods+C.BurnIn);
  YCount        = zeros(C.LenGrid);
  XCount        = zeros(C.LenGrid);
  for ix = 1:C.LenGrid
    for iy = 1:C.LenGrid
      for iz = 1:C.LenGridZ
        if InitNum(ix,iy,iz) > 0 %If there are agents that we have to include...
          SimJobName(Workers{ix}(XCount(ix) + 1 : XCount(ix) + InitNum(ix,iy,iz)),1)    = Firms{iy}(YCount(iy) + 1 : YCount(iy) + InitNum(ix,iy,iz));
          VacancyLine(Firms{iy}(YCount(iy) + 1 : YCount(iy) + InitNum(ix,iy,iz)))       = 0;
          SimShock(Workers{ix}(XCount(ix) + 1 : XCount(ix) + InitNum(ix,iy,iz)),1)      = iz;
          XCount(ix) = XCount(ix) + InitNum(ix,iy,iz);
          YCount(iy) = YCount(iy) + InitNum(ix,iy,iz);
        end
      end
    end
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [NowF,VacancyLine,SimO,NowS] = Updater(TTemp,NowF,SimO,P,VacancyLine,C,inow,NumMeets,M,NowS)
  
  DensZetaCumSum = cumsum(C.ZetaProb');
  DensZetaCumSum = [0;DensZetaCumSum(1:end-1)];
  
  %Those who are working get lower search intensity
  TTemp(NowF < C.NumJobsSim + 1 > 0,2) = P.Pphi;
  
  %Just randomize the order of vacant firms names giving weight 1 to vacant firms
  TempFirms = WhoGetsMeets(VacancyLine,VacancyLine > 0,P,'f');
  
  %Now order the workers prioritizing by OJS efficiency
  TempWorkers = WhoGetsMeets(TTemp(:,1),TTemp(:,2),P,'w');
  
  %WName | WType | Type of current firm | New-Firm-Name | New-Firm-Type | Shock
  MatchCddt = zeros(NumMeets,6);
  
  %Select NumMeets of workers who come in first after randomizing.
  MatchCddt(:,1) = TempWorkers(1:NumMeets);
  
  %Convert names to types so we can use the acceptance sets later.
  MatchCddt(:,2) = SimO.iNameX(MatchCddt(:,1));
  
  %Find SimJobName the current partners of the workers (firm type)
  MatchCddt(:,3) = SimO.JobNameY(NowF(MatchCddt(:,1)));
  
  %Put the firms there in their line
  MatchCddt(:,4) = TempFirms(1:NumMeets);
  
  %And get the type of the firms as well (including if they are currently unemployed)
  MatchCddt(:,5) = SimO.JobNameY(MatchCddt(:,4));
  
  %What draw do they get. This is so that we can make their acceptance based on
  %the productivity draw. %If draw is 1, it will update to 1.
  TempRand = rand(NumMeets,1);
  for iz = 1:C.LenGridZ
    MatchCddt(TempRand>DensZetaCumSum(iz),6) = iz;
  end
  
  %Then the accept or reject via acceptance sets for unemployed workers and
  %those searching on the job.
  Chg         = zeros(NumMeets,1);
  UnEmp       = (MatchCddt(:,3) == C.LenGrid + 1);
  if P.Pphi > 0
    Chg(UnEmp)  = M.AccSetU(sub2ind(size(M.AccSetU),MatchCddt(UnEmp,2),MatchCddt(UnEmp,5)));
  else
    Chg(UnEmp)  = M.AccSetU(sub2ind(size(M.AccSetU),MatchCddt(UnEmp,2),MatchCddt(UnEmp,5),MatchCddt(UnEmp,6)));
  end
  
  Emp = ~UnEmp;
  if P.Pphi > 0
    Chg(Emp)     = M.AccSetE(sub2ind(size(M.AccSetE),MatchCddt(Emp,2),MatchCddt(Emp,3),MatchCddt(Emp,5)));
  end
  
  %To allow for mixed strategies, set back to zero Chg if its not big enough.
  Chg          = Chg > rand(NumMeets,1);
  
  %Move all successful matches to Now. This already accounts for employment to
  %employment change. We are just changing the match of those already matched.
  NowF(MatchCddt(Chg,1)) = MatchCddt(Chg,4);
  NowS(MatchCddt(Chg,1)) = MatchCddt(Chg,6);
  
  %Destruction.
  %Take all the matches, and destroy delta of them
  Temp = [find(NowF < C.NumJobsSim + 1),rand(sum(NowF < C.NumJobsSim + 1),1)];
  Temp = Temp(Temp(:,2) < P.Ddelta,1);
  
  %These matches are broken
  NowF(Temp) = C.NumJobsSim + 1;
  NowS(Temp) = 0;
  
  %Rebuild the vacancy line
  VacancyLine = (1:C.NumJobsSim)';
  
  VacancyLine(NowF(NowF < C.NumJobsSim+1,1)) = 0;
  
  if mod(inow,100) == 0;
    display(strcat(['    Emp is :',num2str(SimO.Emp(inow),'%7.5f'),' at period:',num2str(inow)]));
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function LineUp = WhoGetsMeets(Candidates,Weights,P,SW)
  Len = size(Candidates,1);
  LineUp = zeros(Len,1);
  %The number of people who have phi \in (0,1)
  temp = Weights<1&Weights>0;
  if any(temp)
    Weights(temp) = rand(sum(temp),1)<P.Pphi;
    %number of people who are not getting a meet
    nNoGo = sum(Weights==0);
    %now the idea is to sort them two times
    %number of poeple not getting a meet go bottom also randomized
    NoGo = Candidates(~Weights);
    LineUp(end-nNoGo+1:end) = NoGo(randperm(nNoGo));
    %number of people getting meets go up top randomized
    Go = Candidates(Weights==1);
    LineUp(1:end-nNoGo)		= Go(randperm(Len-nNoGo));
  else
    nNoGo = sum(Weights==0);
    Go = Candidates(Weights == 1);
    if isempty(Go) == 0
      LineUp(1:end-nNoGo)		= Go(randperm(Len-nNoGo));
    end
    switch lower(SW)
      case {'w'}
        NoGo = Candidates(~Weights);
        if isempty(NoGo) == 0
          LineUp(end-nNoGo+1:end) = NoGo(randperm(nNoGo));
        end
      case {'f'}
    end
  end
  
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [InitNum,SimO] = InitNumMake(SimO,M,C,P)
  %This function gives the initial number of agents who are employed.
  SimO.TargetE = round(C.NumAgentsSim*M.Emp);
  InitNum = zeros(C.LenGrid,C.LenGrid,C.LenGridZ);
  if SimO.TargetE <= 0
    error('Resulting employment is zero')
  else
    [InitNum] = Distributor(InitNum,SimO.TargetE,C,M,P);
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [InitNum] = Distributor(InitNum,TargetE,C,M,P)
  %This function takes the number of agents per typeh and matches them up.
  %Order all the locations with a single index.
  len = C.LenGrid^2*C.LenGridZ;
  %Want to give every match a fair shot at getting filled
  Temp = zeros(len,2);
  Temp(:,1) = vec(M.MatDen);
  Temp(:,2) = 1:len;
  Temp = Temp(randperm(len),:);
  Temp(:,1) = cumsum(Temp(:,1));
  %ILoc keeps track of the match location 1:len
  ILoc = 1;
  %We want to locate the location of the first lucky match
  
  vi = rem(Temp(1,2)-1, C.LenGrid^2) + 1;
  ndx = vi;
  vi = rem(ndx-1, C.LenGrid) + 1;
  J = (ndx - vi)/C.LenGrid + 1;
  ndx = vi;
  vi = rem(ndx-1, 1) + 1;
  I = (ndx - vi)/1 + 1;
  DensW = ones(C.LenGrid,1) * C.NumAgentsSimMult;
  DensF = ones(C.LenGrid,1) * C.NumJobsSimMult;
  
  %Generate as many numbers of initial matches we need, then distribute them
  Random = sort(rand(TargetE,1)*sum(M.MatDen(:)));
  M.AccSetU(isnan(M.AccSetU)) = 0;
  for i1 = 1:TargetE
    %The acceptance probability is built into the initialization if there are
    %mixed strategies.
    while Random(i1) > Temp(ILoc,1) || DensW(I)==0 || DensF(J)==0 || rand(1) > M.AccSetU(Temp(ILoc,2));
      ILoc = ILoc + 1;
      
      vi = rem(Temp(ILoc,2)-1, C.LenGrid^2) + 1;
      ndx = vi;
      vi = rem(ndx-1, C.LenGrid) + 1;
      J = (ndx - vi)/C.LenGrid + 1;
      ndx = vi;
      vi = rem(ndx-1, 1) + 1;
      I = (ndx - vi)/1 + 1;
      
      if ILoc == len
        return
      end
    end
    InitNum(Temp(ILoc,2)) = InitNum(Temp(ILoc,2)) + 1;
    DensW(I)         = DensW(I) - 1;
    DensF(J)         = DensF(J) - 1;
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [Sim,SimO] = RegressionPrep(Sim,SimO,C,M,P)
  warning off
  %Add in noise to wages so that we get roughly 20% of var(log wage) is due to measurement error.
  M.Wage                        = max(M.Wage,eps);
  SimInitJob                    = Sim.SimInitJob;
  SimInitJob(SimInitJob>0)      = SimO.JobNameY(SimInitJob(SimInitJob > 0));
  SimShock                      = max(Sim.SimShock,1);
  if P.Pphi > 0
    SimInitJob(SimInitJob==0)     = C.LenGrid + 1;
    SimInitJob(isnan(SimInitJob)) = C.LenGrid + 1;
    
  else
    SimInitJob(SimInitJob==0)     = 1;
    SimInitJob(isnan(SimInitJob)) = 1;
  end
  
  SimJobName          = Sim.SimJobName;
  SimJobName(isnan(SimJobName)) = 1;
  SimJobName          = SimO.JobNameY(SimJobName);
  %Wages depend on where the worker is coming out from.
  Sim.SimWage         = nan(size(Sim.SimJobName));
  SimMeanWage         = nan(size(Sim.SimJobName));
  SimNumShocks        = nan(size(Sim.SimJobName));
  MeanWage            = M.AverageWage;
  NumAccShocks        = sum(SimO.MatDenSim > 0,3);
  SizeTmp             = size(M.Wage);
  SizeTmp2            = size(MeanWage);
  if P.Pphi > 0
    %This is OJSSC with commitment,
    for i1 = 1:size(Sim.SimJobName,2)
      Sim.SimWage(:,i1) = M.Wage(sub2ind(SizeTmp,SimO.iNameX,SimJobName(:,i1),SimInitJob(:,i1)));
    end
  else
    %This is XOJSZ
    for i1 = 1:size(Sim.SimJobName,2)
      Sim.SimWage(:,i1)     = M.Wage(sub2ind(SizeTmp,SimO.iNameX,SimJobName(:,i1),SimShock(:,i1)));
      SimMeanWage(:,i1)     = MeanWage(sub2ind(SizeTmp2,SimO.iNameX,SimJobName(:,i1)));
      SimNumShocks(:,i1)    = NumAccShocks(sub2ind(SizeTmp2,SimO.iNameX,SimJobName(:,i1)));
    end
  end
  Sim.SimWage(isnan(Sim.SimJobName)) = nan;
  SimMeanWage(isnan(Sim.SimJobName)) = nan;
  
  PrevVar             = nanvar(vec(log(Sim.SimWage)));
  display(['    Prev variance in logs is  :',num2str(PrevVar)])
  if P.VarDueNoise > 0
    %Generate normal(0,1)
    Noise                 = randn(floor(1.1*numel(Sim.SimWage)),1);
    Noise                 = Noise(abs(Noise) < C.Std2Truncate);
    Noise                 = Noise(1:C.Periods*C.NumAgentsSim);
    Noise                 = reshape(Noise,C.NumAgentsSim,C.Periods);
    
    %Find the noise to add so that this is within 5% of the error.
    IterTry               = 0;
    Low                   = 0;
    Hi                    = nanmin(vec(Sim.SimWage))/3 - 0.000001;
    SimWage               = Sim.SimWage + Hi*Noise;
    NowVar                = nanvar(vec(log(SimWage)));
    if (NowVar - PrevVar)/NowVar < P.VarDueNoise
      P.VarDueNoise = (NowVar - PrevVar)/NowVar;
      Mid                 = Hi;
      SimO.SigmaNoise_True    = std(vec(Mid*Noise));
      Mid                     = 0;
      R2                      = log(SimMeanWage);
      Sim.SimWage             = SimWage;
    else
      while IterTry <= 20
        if IterTry == 20
          error('Can''t find measurement error to put in/')
        end
        Mid                   = (Hi + Low)/2;
        IterTry = IterTry + 1;
        SimWage               = Sim.SimWage +Mid*Noise;
        NowVar                = nanvar(vec(log(SimWage)));
        disp(['Measurement error contribution: ',num2str(abs((NowVar - PrevVar)/NowVar))])
        if any(nonnan(SimWage) < 0)
          error('NEGATIVE WAGES DUE TO MEASUREMENT ERROR')
        elseif abs((NowVar - PrevVar)/NowVar - P.VarDueNoise) <= 0.001;
          SimO.SigmaNoise_True    = std(vec(Mid*Noise));
          Sim.SimWage             = SimWage;
          break
        elseif (NowVar - PrevVar)/NowVar > P.VarDueNoise
          Hi  = Mid;
        elseif (NowVar - PrevVar)/NowVar < P.VarDueNoise
          Low = Mid;
        end
      end
    end
    R2      = log(SimMeanWage + Mid*Noise);
  else
    SimO.SigmaNoise_True    = 0;
    Mid                     = 0;
    R2                      = log(SimMeanWage);
  end
  
  
  %Run Regression
  %log(w) = alpha_xy  +  k1 log(ww_xy+z) + k2 log(ww_xy+e)
  %Subtract the mean of log wage. Should be very close to the true.
  %Regression is
  %Wage = k1 log(SimMeanWage+z) + k2 log(SimMeanWage+e)
  R1      = log(SimMeanWage + C.GridZeta(SimShock));
  
  %SimJobName is overloaded. See above.
  MatchSpe= (repmat(SimO.iNameX,1,C.Periods) - 1)*(C.LenGrid) + SimJobName;
  
  YXX     = [log(vec(Sim.SimWage')),vec(R1'),vec(R2'),vec(SimNumShocks'),vec(MatchSpe')];
  YXX     = YXX(~isnan(sum(YXX,2)),:);
  %Number of accepted shocks is 1, get rid of match dummy because R1 and
  %Match Dummy is collinear.
  
  Types   = false(1,max(YXX(:,5)));
  Types(unique(YXX(:,5))) = 1;
  
  Temp    = sparse(1:length(YXX),YXX(:,5),ones(length(YXX),1));
  Temp    = Temp(:,Types);
  YXX     = [YXX(:,1:3),Temp];
  
  if nanmax(vec(NumAccShocks)) > 1
    %     log(w) = k1*log(wbar + z) + k2*log(wbar + e) + beta2*M(x,y)
    k1k2    = YXX(:,2:end)\YXX(:,1);
  elseif nanmax(vec(NumAccShocks)) == 1
    %     log(w) = k1*log(wbar + z) + k2*log(wbar + e)
    k1k2    = YXX(:,2:3)\YXX(:,1);
  end
  
  
  k1k2    = full(k1k2(1:2));
  
  VarZ    = zeros(C.LenGrid,C.LenGrid);
  VarE    = zeros(C.LenGrid,C.LenGrid);
  for ix = 1:C.LenGrid
    for iy = 1:C.LenGrid
      VarZ(ix,iy) = nanvar(vec(k1k2(1) * log(MeanWage(ix,iy) + C.GridZeta)),vec(C.ZetaProb));
      VarE(ix,iy) = nanvar(vec(k1k2(2) * log(MeanWage(ix,iy) + Mid*randn(C.LenGrid,1))));
    end
  end
  SimO.SigmaZ             = nanmean(sqrt(VarZ(:)));
  SimO.SigmaE             = nanmean(sqrt(VarE(:)));
  disp(['Stdev of Z : ',num2str(SimO.SigmaZ)])
  disp(['Stdev of E : ',num2str(SimO.SigmaE)])
  
  NewVarLog               = nanvar(vec(log(Sim.SimWage)));
  Wts                     = nansum(SimO.MatDenSim,3);
  SimO.FracVarZ           = nanwmean(vec(VarZ),vec(Wts))/NewVarLog;
  SimO.FracVarE           = nanwmean(vec(VarE),vec(Wts))/NewVarLog;
  disp(['Var(ZOffer)/Var(LogWage) : ',num2str(SimO.FracVarZ)])
  disp(['Var(Error)/Var(LogWage)  : ',num2str(SimO.FracVarE)])
  
  display(['    Now variance in logs is   :',num2str(NewVarLog)])
  SimO.VarDueToNoise      = (NewVarLog - PrevVar)./NewVarLog;
  display(['    Percent noise due to ME   :',num2str(SimO.VarDueToNoise)])
  
  SimO.PrevVarLog         = PrevVar;
  SimO.NewVarLog          = NewVarLog;
  Sim.SimJobName          = int32(Sim.SimJobName);
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [SimO,C] = firmSpecificUtilityVariables(C)
  %Simulate the firm sizes so each bin add up to 600 in Simulation.
  

  SimO.Numj           = C.NumJobsSim./C.jSizeDist;
  FirmSize            = ones(SimO.Numj,1).*C.jSizeDist;
  SimO.jNameY         = vec(repmat(1:C.LenGrid,C.NumJobsSimMult/C.jSizeDist,1));

  SimO.FirmSize     = FirmSize;
  FirmSize          = [0;cumsum(FirmSize)];
  SimO.JobNamej  = zeros(C.NumAgentsSim,1);
  for i1 = 1:SimO.Numj
    SimO.JobNamej(FirmSize(i1) + 1 : FirmSize(i1 + 1)) = i1;
  end
  
  SimO.xBinGrid        = linspace(0,1,C.NumXBins);
  SimO.YBinGrid        = linspace(0,1,C.NumYBins);
  SimO.jNameGrid       = linspace(0,1,SimO.Numj);
  SimO.iNameGrid       = linspace(0,1,C.NumAgentsSim);
  SimO.iNames          = vec(1:C.NumAgentsSim);
  SimO.jobNames        = vec(1:C.NumJobsSim);
  SimO.jNames          = vec(1:SimO.Numj);
  SimO.typeNames       = vec(1:C.LenGrid);
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
