function [MVCU,MVCE,MV,Pphi] = getMatchVars(C,SimO,Sim,NNHUFull,AccRateU,iBin,WageU,Ddelta,VacsFull,RD)
%To obtain the matching rate, which in our case, is exactly Kkappa, we just need the aggregate payroll size in the economy.
%Note that in the context of this model, aggregate vacancies and aggregate unemployment is the same.
%See user guide/data dictionary for more information.
%Author: Tzuo Hann Law (tzuohann@gmail.com)

display('getMatchVars')

%   if C.PerfectMatchVars == 1
%     MVCE            = M.MV * M.CE;
%     MVCU            = M.MV * M.CU;
%     MV              = M.MV;
%     Pphi            = P.Pphi;
%   else

%Use only the larger firms in calculation of MVCU
FirmSize = tabulate(vec(Sim.SimJName));
FirmSize = FirmSize(FirmSize(:,1) > 0,1:2);
prctileSize = prctile(FirmSize(:,2),30);
NNHUFull = NNHUFull(FirmSize(:,2) > prctileSize,:);
AccRateU = AccRateU(FirmSize(:,2) > prctileSize,:);
Hires    = mean(NNHUFull,2);
GotHires = Hires > 0;
NNHUFull = NNHUFull(GotHires,:);
AccRateU = AccRateU(GotHires,:);
MVCU    = sum(mean(NNHUFull,2)./AccRateU)/mean(VacsFull)/(1-Ddelta);

ProbXUnE  = getProbXUnE(Sim,C,iBin);
ProbXLowW = getProbXLowW(Sim,C,SimO,WageU,iBin);

Pphi        = nansum(ProbXLowW(:,1)./ProbXUnE(:,1).*ProbXLowW(:,2))./nansum(ProbXLowW(:,2));
SimO.Emp    = 1 - mean(RD.I.iUnE);
MV          = MVCU/((1 - mean(SimO.Emp))/((1 - mean(SimO.Emp)) + Pphi.*mean(SimO.Emp)));
MVCE        = MV .* Pphi*mean(SimO.Emp)/(Pphi*mean(SimO.Emp) + (1 - mean(SimO.Emp)));

%   end
end

function ProbXUnE = getProbXUnE(Sim,C,iBin)
%Probability of exiting unemployment by Bin
Sim.SimWage(Sim.SimWage == 0) = nan;
JobIs1        = double(Sim.SimWage > 0);
JobIs1(Sim.SpellType == 3) = nan;
for i1 = 1:size(JobIs1,1)
    [~,maxAge] = find(Sim.Age(i1,:),1,'last');
    if maxAge < size(Sim.Age,2)
        JobIs1(i1,maxAge + 1:end) = nan;
    end
end

Spells = [vec(iBin(repmat(vec(1:C.NumAgentsSim),1,size(Sim.SimWage,2) - 1))'),vec(JobIs1(:,1:end-1)'),vec(JobIs1(:,2:end)')];
Spells = Spells(sum(isnan(Spells),2) == 0,:);

ProbXUnE = zeros(C.LenGrid,2);
for ix = 1:C.LenGrid
    Wt             = sum(Spells(:,1) == ix);
    ExitU          = sum(Spells(:,1) == ix & Spells(:,2) == 0 & Spells(:,3) == 1);
    ProbXUnE(ix,:) = [ExitU/Wt,Wt];
end
end

function ProbXLowW = getProbXLowW(Sim,C,SimO,WageU,iBin)
ProbXLowW   = zeros(C.LenGrid,2);
jName       = Sim.SimJName;
for ix = 1:C.LenGrid
    prctileWage                     = prctile(nonnan(WageU(ix,:)),40);
    [~,jLowWage]                    = find(WageU(ix,:) <= prctileWage);
    Wt                              = iBin == ix;
    NumSpells                       = sum(vec(ismember(jName(Wt,1:end-1),jLowWage)));
    NumMoves                        = sum(vec(ismember(jName(Wt,1:end-1),jLowWage) & jName(Wt,2:end) > 0 & ~ismember(jName(Wt,2:end),jLowWage)));
    ProbXLowW(ix,:)                 = [NumMoves./NumSpells,NumSpells];
end
end
