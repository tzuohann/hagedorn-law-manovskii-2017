function m4_2_WantedVars_ToRankW(StartYear,EndYear,Spec,Header,RootDir)
dbstop if error

fprintf('\n')
disp('-------------------------------------------------------------------')
disp('Running m4_2_WantedVars_ToRankW...')
disp(['StartYear    = ',num2str(StartYear)])
disp(['EndYear      = ',num2str(EndYear)])
disp(['Spec         = ',Spec])
disp(['Header       = ',Header])
disp(['RootDir      = ',RootDir])

fprintf('\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('-------------------------------------------------------------------')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Section 4.2.1: Load Data %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Loading .mat data from m4_1...')
fprintf('\n')

%Load the file produced by m4_1
load([RootDir,'\data\m4_1',Header,num2str(StartYear),num2str(EndYear),'_',Spec,'.mat'],'Sim')

SimU = Sim;
SimU.SimWage    = SimU.SimWage .* (SimU.SpellType == 1);
SimU.SimJName   = SimU.SimJName .* (SimU.SpellType == 1);
[ID,T,JName]    = find(SimU.SimJName);
[~,~,JName]     = unique(JName);
SimU.SimJName(sub2ind(size(SimU.SimJName),ID,T)) = JName;
[LU,RD.S.SigmaNoise_HatU] = doRegMat(SimU);
[~,~,LU.WFCA(:,2)] = unique(LU.WFCA(:,2));

Sim.SimJName    = abs(Sim.SimJName);
[L,~]           = doRegMat(Sim);

%Convert zeros to nan so that simWageStats works.
Sim.SimWage(Sim.SimWage == 0) = nan;
SimO.iNames     = vec(1:size(Sim.SimWage,1));
RD.I            = simWageStats(Sim,L,SimO);
mkdir('..\data\Output');
C.NumAgentsSim  = size(Sim.SimWage,1);
C.NITERMAX      = 100000;
C.DistMaxInGlo  = 100000;
C.OMPTHREADS    = 1;
C.ProbDistInc   = 0.9;
C.MovesToSave   = 5000;
C.DispCheck     = 10000;
C.DispMove      = 2000;
RD.I            = rankWorkers(RD,C,SimO,LU,Header,Spec);

fprintf('\n')
disp('m4_2_WantedVars_ToRankW.m completed successfully and log closed.')

% End logging or return to keyboard
fclose(fopen([RootDir,'\log\done.done'],'w+'));
exit
end