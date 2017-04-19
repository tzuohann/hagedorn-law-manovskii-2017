%This function takes CardYearly output from m3_2 and estimates
%person, firm and match fixed effects and shows the variance decomposition.

function m4_1_makeSimFromReal(StartYear,EndYear,Spec,Header,RootDir)
dbstop if error

fprintf('\n')
disp('-------------------------------------------------------------------')
disp('Running m4_1_makeSimFromReal...')
disp(['StartYear    = ',num2str(StartYear)])
disp(['EndYear      = ',num2str(EndYear)])
disp(['Spec         = ',Spec])
disp(['Header       = ',Header])
disp(['RootDir      = ',RootDir])

fprintf('\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('-------------------------------------------------------------------')

disp('Loading .mat data from m3_2...')
fprintf('\n')

%Load the file produced by m3_2
load([RootDir,'\data\m3_2',num2str(StartYear),num2str(EndYear),'_',Spec,'.mat'],'O')
load([RootDir,'\data\m3_3men',num2str(StartYear),num2str(EndYear),'_',Spec,'.mat'],'R')

%Ensure that the IDs are contiguous.
[~,~,O.idcont]      = unique(O.id);

%Construct the matrix with 1 = 1993 and 15*12 = 2007;
Sim.SimWage     = zeros(max(O.id),12*(EndYear - StartYear + 1));
Sim.SimJName    = zeros(max(O.id),12*(EndYear - StartYear + 1));
Sim.Age         = zeros(max(O.id),12*(EndYear - StartYear + 1));
Sim.OutOfU      = zeros(max(O.id),12*(EndYear - StartYear + 1));

O.idnum(O.betr_st == 0)         = -O.idnum(O.betr_st == 0);

for i1 = 1:size(O.id,1)
    StartDate   = (O.start_year(i1) - 1993)*12 + O.start_month(i1);
    EndDate     = (O.end_year(i1) - 1993)*12 + O.end_month(i1);
    Sim.SimWage(O.id(i1),StartDate:EndDate) = exp(R.notAKMStats.pe(i1) + R.notAKMStats.r(i1));
    Sim.SimJName(O.id(i1),StartDate:EndDate) = O.idnum(i1);
    Sim.Age(O.id(i1),StartDate:EndDate) = O.start_year(i1) - O.gebjahr(i1);
end

%Previous spell. Known Out of U is 1. Known JJ is 2. Otherwise, 3.
Sim.SpellType  = 3*(Sim.SimJName~=0);
for it = 2:size(Sim.SimJName,2)
    Temp = Sim.SpellType(:,it - 1);
    %Out of unemployment.
    Sim.SpellType(Temp == 0 & Sim.SimJName(:,it) ~= 0,it) = 1;
    %Same firm, maintain the previous status
    SameFirm           = Temp > 0  & (Sim.SimJName(:,it) == Sim.SimJName(:,it-1));
    Sim.SpellType(SameFirm,it) = Sim.SpellType(SameFirm,it-1);
    %Different firm, flag as JJ
    DiffFirm           = Temp > 0  & (Sim.SimJName(:,it) ~= Sim.SimJName(:,it-1)) & Sim.SimJName(:,it) ~= 0;
    Sim.SpellType(DiffFirm,it) = 2;
end

%For each person, if the first time SpellType 3 shows up, they are
%less than age 26, it is Out of Unemployment. Else JJ.
for i1 = 1:size(Sim.SimJName,1)
    FirstObs = Sim.SpellType(i1,:) == 3;
    minAge = min(Sim.Age(i1,FirstObs));
    if minAge <= 26
        Sim.SpellType(i1,FirstObs) = 1;
    else
        Sim.SpellType(i1,FirstObs) = 2;
    end
end
save([RootDir,'\data\m4_1',Header,num2str(StartYear),num2str(EndYear),'_',Spec,'.mat'],'Sim','-v7.3');

fprintf('\n')
disp('m4_1_makeSimFromReal.m completed successfully and log closed.')

% End logging or return to keyboard
fclose(fopen([RootDir,'\log\done.done'],'w+'));
exit
end