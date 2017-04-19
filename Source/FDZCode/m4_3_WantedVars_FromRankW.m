function m4_3_WantedVars_FromRankW(StartYear,EndYear,Spec,Header,RootDir,drop)
dbstop if error

fprintf('\n')
disp('-------------------------------------------------------------------')
disp(['StartYear    = ',num2str(StartYear)])
disp(['EndYear      = ',num2str(EndYear)])
disp(['Spec         = ',Spec])
disp(['Header       = ',Header])
disp(['RootDir      = ',RootDir])

fprintf('\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('-------------------------------------------------------------------')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Section 4.3.1: Load Ranking %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RD.I.iNRRankAgg = loadWorkerRanking(Header,Spec);
RD.I.iNRUse     = RD.I.iNRRankAgg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Section 4.3.2: Merge with Data From m4_1 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Loading .mat data from m4_1...')
fprintf('\n')
%Load the file produced by m4_1
load([RootDir,'\data\m4_1',Header,'1993','2007','_',Spec,'.mat'],'Sim')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Section 4.3.3: Form the subsample %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mark the end of observation for the worker
for i1 = 1:size(Sim.SpellType,1)
        [~,maxAge] = find(Sim.SpellType(i1,:),1,'last');
        if maxAge < size(Sim.SpellType,2)
            Sim.SpellType(i1,maxAge + 1:end) = 3;
        end
end
%Select the sample of data
Sim.SimWage         = Sim.SimWage(:,StartYear - 1993 + 1 : EndYear - 1993 + 1);
Sim.SimJName        = Sim.SimJName(:,StartYear - 1993 + 1 : EndYear - 1993 + 1);
Sim.Age             = Sim.Age(:,StartYear - 1993 + 1 : EndYear - 1993 + 1);
Sim.OutOfU          = Sim.OutOfU(:,StartYear - 1993 + 1 : EndYear - 1993 + 1);
Sim.SpellType       = Sim.SpellType(:,StartYear - 1993 + 1 : EndYear - 1993 + 1);

%Mark small firms as firms that are not in LIAB data
[WID,~,FID]     = find(Sim.SimJName);
WID             = WID(FID > 0);
FID             = FID(FID > 0);
WFUniq          = unique([WID,FID],'rows');
numUniqW        = tabulate(WFUniq(:,2));
smallFirms      = numUniqW(numUniqW(:,2) < 25,1);
Sim.SimJName(ismember(Sim.SimJName,smallFirms)) = -Sim.SimJName(ismember(Sim.SimJName,smallFirms));

%Renumber the firms so that positive are LIAB and negatives are not
[Row,Col]       = find(Sim.SimJName > 0);
JTemp           = Sim.SimJName(sub2ind(size(Sim.SimJName),Row,Col));
[~,~,JTemp]     = unique(JTemp);
Sim.SimJName(sub2ind(size(Sim.SimJName),Row,Col)) = JTemp;
[Row,Col]       = find(Sim.SimJName < 0);
JTemp           = Sim.SimJName(sub2ind(size(Sim.SimJName),Row,Col));
[~,~,JTemp]     = unique(JTemp);
JTemp           = JTemp + max(vec(Sim.SimJName));
Sim.SimJName(sub2ind(size(Sim.SimJName),Row,Col)) = -JTemp;

%Remove workers who have no employment spells in that time period, and
%reform the rankings.
NoEmpW                  = all(Sim.SpellType == 3 | Sim.SpellType == 0,2);
C.NumAgentsSim          = sum(NoEmpW == 0);
RD.I.iNRRankAgg         = RD.I.iNRRankAgg(NoEmpW == 0,:);
RD.I.iNRUse             = RD.I.iNRUse(NoEmpW == 0,:);
RD.I.iNRRankAgg(:,1)    = 1:size(RD.I.iNRRankAgg,1);
RD.I.iNRUse(:,1)        = 1:size(RD.I.iNRUse,1);
RD.I.iNRRankAgg         = sortrows(RD.I.iNRRankAgg,2);
RD.I.iNRRankAgg(:,2)    = 1:size(RD.I.iNRRankAgg,1);
RD.I.iNRRankAgg         = sortrows(RD.I.iNRRankAgg,1);
RD.I.iNRUse             = sortrows(RD.I.iNRUse,2);
RD.I.iNRUse(:,2)        = 1:size(RD.I.iNRUse,1);
RD.I.iNRUse             = sortrows(RD.I.iNRUse,1);

%Keep the rows where there is employment
Sim.SimWage         = Sim.SimWage(NoEmpW == 0,:);
Sim.SimJName        = Sim.SimJName(NoEmpW == 0,:);
Sim.Age             = Sim.Age(NoEmpW == 0,:);
Sim.OutOfU          = Sim.OutOfU(NoEmpW == 0,:);
Sim.SpellType       = Sim.SpellType(NoEmpW == 0,:);

%Bin the workers, counting variables.
%Use 20 bins for ranking firms to overcome memory restrictions
C.NumBins       = 20;
SimO.iNameX     = vec(ceil(linspace(eps,1,C.NumAgentsSim).*C.NumBins));
SimO.iNames     = vec(1:C.NumAgentsSim);
RD.I.iBin       = binAgents(RD.I.iNRUse,SimO.iNameX);
C.NumXBins      = max(RD.I.iBin);
C.Periods       = size(Sim.SimJName,2);
C.LenGrid       = C.NumBins;
C.DropExt       = drop;
SimO.Numj       = max(Sim.SimJName(:));
SimO.jNames     = vec(1:SimO.Numj);
C.LIABMaxNum    = max(Sim.SimJName(:));

%Proceed with recovering production function on this half of the data
[RD.I.iUnE,P.Ddelta]       = getiUnE(SimO,C,Sim);
RD.X.UnEBin                = xBinUnEmp(C,RD.I.iUnE,RD.I.iBin);
RD.J                       = getWMob(C,SimO,RD,Sim);

%Out of unemployment data for dropping algo
SimU = Sim;
LIABOUTU        = Sim.SimJName > 0 & SimU.SpellType == 1;
SimU.SimWage    = SimU.SimWage .* (LIABOUTU);
SimU.SimJName   = SimU.SimJName .* (LIABOUTU);
SimU.SpellType  = SimU.SpellType .* (LIABOUTU);
[LLU,~]         = doRegMat(SimU);

[RD.J.AccSetU,RD.I.iDroppedj] = ...
    markDropU(RD,C,SimO,LLU,SimO.Numj,SimO.jNames,zeros(C.NumAgentsSim,1),SimU);

%Just treat these firms as non-LIAB firms
RejectAll       = find(sum(RD.J.AccSetU) == 0);
NoRejectAll     = find(sum(RD.J.AccSetU) ~= 0);
Sim.SimJName(ismember(Sim.SimJName,RejectAll)) = -Sim.SimJName(ismember(Sim.SimJName,RejectAll));
[Row,Col]       = find(Sim.SimJName > 0);
JTemp           = Sim.SimJName(sub2ind(size(Sim.SimJName),Row,Col));
[~,~,JTemp]     = unique(JTemp);
Sim.SimJName(sub2ind(size(Sim.SimJName),Row,Col)) = JTemp;
[Row,Col]       = find(Sim.SimJName < 0);
JTemp           = Sim.SimJName(sub2ind(size(Sim.SimJName),Row,Col));
[~,~,JTemp]     = unique(JTemp);
JTemp           = JTemp + max(vec(Sim.SimJName));
Sim.SimJName(sub2ind(size(Sim.SimJName),Row,Col)) = -JTemp;

%Redo firm numbering
RD.J.EmpShare       = RD.J.EmpShare(NoRejectAll);
RD.J.FirmSize       = RD.J.FirmSize(NoRejectAll,:);
RD.J.NNHUFull       = RD.J.NNHUFull(NoRejectAll,:);
RD.J.NNHEFull       = RD.J.NNHEFull(NoRejectAll,:);
RD.J.NLWEFull       = RD.J.NLWEFull(NoRejectAll,:);
RD.J.AccSetEMob     = RD.J.AccSetEMob(:,NoRejectAll,NoRejectAll);
RD.J.AccSetU        = RD.J.AccSetU(:,NoRejectAll);
SimO.Numj           = max(Sim.SimJName(:));
SimO.jNames         = vec(1:SimO.Numj);
C.LIABMaxNum        = max(Sim.SimJName(:));

SimLU = Sim;
LIABOUTU            = Sim.SimJName > 0 & Sim.SpellType == 1 ;
SimLU.SimWage       = SimLU.SimWage .* (LIABOUTU);
SimLU.SimJName      = SimLU.SimJName .* (LIABOUTU);
SimLU.SpellType     = SimLU.SpellType .* (LIABOUTU);
[LLU,~]             = doRegMat(SimLU);

SimL = Sim;
LIABOUTU            = Sim.SimJName > 0;
SimL.SimWage        = SimL.SimWage .* (LIABOUTU);
SimL.SimJName       = SimL.SimJName .* (LIABOUTU);
SimL.SpellType      = SimL.SpellType .* (LIABOUTU);
[LL,~]              = doRegMat(SimL);

%Obtain match density and the average wages at the firm level
RD.J.MatDenU        = getMatDenEst(LLU,C,RD,SimO.Numj,SimO.jNames);
RD.J.MatDen         = getMatDenEst(LL,C,RD,SimO.Numj,SimO.jNames);
RD.J.Wage           = getWageJYX(SimO.Numj,LL,SimO.jNames,RD,C,RD.I.iDroppedj,C.LIABMaxNum);
RD.J.WageU          = getWageJYX(SimO.Numj,LLU,SimO.jNames,RD,C,RD.I.iDroppedj,C.LIABMaxNum);

%Obtain acceptance sets for employment moves and job acceptance rates
[RD.J.AccSetE,RD.J.Cutoff]    = getAccSetE(RD,C,SimU,SimO.Numj,RD.I.iDroppedj);
[RD.J.AccRateU,RD.J.AccRateE] = getAccRate(SimO.Numj,RD,RD.J.AccSetU,RD.J.AccSetE,RD.J.MatDen);

%Number of jobs equals number of workers. So VacsFull is just
%the average unemployment times the number of workers.
VacsFull                      = mean(RD.I.iUnE)*C.NumAgentsSim;

%Obtain matching function parameters
[RD.S.MVCU,RD.S.MVCE,RD.S.MV,RD.S.Pphi] = ...
    getMatchVars(C,SimO,Sim,RD.J.NNHUFull,RD.J.AccRateU,RD.I.iBin,RD.J.WageU,P.Ddelta,VacsFull,RD);

%Obtain firm ranking statistics
RD.J.EEWageDiff                 = empWageDiff(SimO.Numj,RD.J.MatDen,RD.J.WageU,RD.J.AccSetE,LL,P,C);
RD.J.NROmega                    = getRankBy(SimO.jNames,RD.J.EEWageDiff);
RD.J.jBin                       = binAgents(RD.J.NROmega,vec(ceil(linspace(eps,1,C.LIABMaxNum).*C.NumBins)));

%Acceptance sets for unemployment and job to job
[RD.Y.AccSetU] = ...
    markDropUY(RD,C,SimO,LLU,C.NumBins,RD.J.jBin,zeros(C.NumAgentsSim,1),SimLU);
[RD.Y.AccSetE,~]                = getAccSetEY(RD,C,SimU,C.LenGrid,RD.I.iDroppedj);

%AdjustLL and LLU to reflect dropping
[dBinW,dBinF]                   = find(RD.Y.AccSetU == 0);
[WID,FID,Counts]                = find(LL.iAvWageCount);
ToKeep                          = ~ismember([RD.I.iBin(WID),RD.J.jBin(FID)],[dBinW,dBinF],'rows');
LL.iAvWageCount                 = sparse(WID(ToKeep),FID(ToKeep),Counts(ToKeep));
[WID,FID,Wage]                  = find(LL.iAvWageAtFirm);
ToKeep                          = ~ismember([RD.I.iBin(WID),RD.J.jBin(FID)],[dBinW,dBinF],'rows');
LL.iAvWageAtFirm                = sparse(WID(ToKeep),FID(ToKeep),Wage(ToKeep));
[WID,FID,Counts]                = find(LLU.iAvWageCount);
ToKeep                          = ~ismember([RD.I.iBin(WID),RD.J.jBin(FID)],[dBinW,dBinF],'rows');
LLU.iAvWageCount                = sparse(WID(ToKeep),FID(ToKeep),Counts(ToKeep));
[WID,FID,Wage]                  = find(LLU.iAvWageAtFirm);
ToKeep                          = ~ismember([RD.I.iBin(WID),RD.J.jBin(FID)],[dBinW,dBinF],'rows');
LLU.iAvWageAtFirm               = sparse(WID(ToKeep),FID(ToKeep),Wage(ToKeep));

%Revert back to 50 grid points. Remaining code is not memory intensive
C.LenGrid                       = 50;
C.NumBins                       = 50;
C.NumXBins                      = 50;
RD.J.jBin                       = binAgents(RD.J.NROmega,vec(ceil(linspace(eps,1,C.LIABMaxNum).*C.NumBins)));

SimO.iNameX                     = vec(ceil(linspace(eps,1,C.NumAgentsSim).*C.NumBins));
RD.I.iBin                       = binAgents(RD.I.iNRUse,SimO.iNameX);
RD.X.UnEBin                     = xBinUnEmp(C,RD.I.iUnE,RD.I.iBin);

%Match densities
RD.Y.MatDen                     = getMatDenEstY(LL,C,RD,C.LenGrid,RD.J.jBin);
RD.Y.MatDenU                    = getMatDenEstY(LLU,C,RD,C.LenGrid,RD.J.jBin);

RD.Y.AccSetU                    = RD.Y.MatDen > 0;
[RD.Y.AccSetE,~]                = getAccSetEY(RD,C,SimU,C.LenGrid,RD.I.iDroppedj);
[RD.Y.AccRateU,RD.Y.AccRateE]   = getAccRate(C.LenGrid,RD,RD.Y.AccSetU,RD.Y.AccSetE,RD.Y.MatDen);
RD.Y.Wage                       = getWageJYXY(C.LenGrid,LL,RD,C,RD.I.iDroppedj,C.LIABMaxNum,RD.J.jBin);
RD.Y.WageU                      = getWageJYXY(C.LenGrid,LLU,RD,C,RD.I.iDroppedj,C.LIABMaxNum,RD.J.jBin);
RD.Y.EEWageDiff                 = grpstats(RD.J.EEWageDiff,RD.J.jBin,'mean');
P.Bbeta                         = 0.996;
RD.Y.ValVac                     = getValVac(RD,P,RD.Y.EEWageDiff);
RD.Y.Prod                       = getProdXYE(C,P,C.LenGrid,RD.Y.WageU,RD.Y.ValVac);

save([RootDir,'\data\m4_3',Header,num2str(StartYear),num2str(EndYear),'_',Spec,'_',num2str(round(drop * 100)),'.mat'],'-v7.3');

fprintf('\n')
disp('m4_3_WantedVars_FromRankW.m completed successfully and log closed.')

% End logging or return to keyboard
fclose(fopen([RootDir,'\log\done.done'],'w+'));

exit
end