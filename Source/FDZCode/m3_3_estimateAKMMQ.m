%This function takes CardYearly output from m3_2 and estimates
%person, firm and match fixed effects and shows the variance decomposition.

function m3_3_estimateAKMMQ(StartYear,EndYear,Spec,Header,RootDir)
    dbstop if error

    fprintf('\n')
    disp('-------------------------------------------------------------------')
    disp('Running m3_3_estimateAKMMQ...')
    disp(['StartYear    = ',num2str(StartYear)])
    disp(['EndYear      = ',num2str(EndYear)])
    disp(['Spec         = ',Spec])
    disp(['Header       = ',Header])
    disp(['RootDir      = ',RootDir])

    fprintf('\n')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('-------------------------------------------------------------------')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Section 3.3.1: Load Data %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Section 3.3.1: Load Data')
    disp('Loading .mat data from m3_2...')
    fprintf('\n')

    %Load the file produced by m3_2
    load([RootDir,'\data\m3_2',num2str(StartYear),num2str(EndYear),'_',Spec,'.mat'],'O')

    P.Header    = Header;
    P.StartYear = StartYear;
    P.EndYear   = EndYear;
    P.Spec      = Spec;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('-------------------------------------------------------------------')

    fprintf('\n')

    %% Select Observables
    switch lower(P.Spec)
        case {'card'}
            T.XBTemp      = [O.start_year,O.gebjahr,O.edgroup];
            T.XBTemp      = getCardXB(T.XBTemp);
    end

    %% Estimate worker effects only regression
    T.DataTemp      = [O.logwage_1p2,O.id,O.idnum];
    [T.X,T.D,T.F]   = getAKMDesign(T.DataTemp);
    T.X             = [T.D,T.XBTemp];

    disp('Running AKM...')
    T.xx=T.X'*T.X;
    T.xy=T.X'*(O.logwage_1p2);

    L=ichol(T.xx,struct('type','ict','droptol',1e-2,'diagcomp',0.1));
    b=pcg(T.xx,T.xy,1e-10,1000,L,L');

    %% Worker and Firm Fixed Effects
    R.notAKMStats.pe = T.D*b(1:size(T.D,2));
    R.notAKMStats.xb = T.XBTemp*b(size(T.D,2)+1 : end);
    R.notAKMStats.r  = O.logwage_1p2 - R.notAKMStats.xb - R.notAKMStats.pe;

    %% AKM Rank correlation
    T.X=[T.D,T.F,T.XBTemp];

    disp('Running AKM ...')
    T.xx=T.X'*T.X;
    T.xy=T.X'*(O.logwage_1p2);

    L=ichol(T.xx,struct('type','ict','droptol',1e-2,'diagcomp',0.1));
    b=pcg(T.xx,T.xy,1e-10,1000,L,L');    

    R.AKMStats.pe = T.D*b(1:size(T.D,2));
    R.AKMStats.fe = T.F*b((size(T.D,2)+1) : (size(T.D,2)+size(T.F,2)));
    R.AKMStats.xb = T.XBTemp*b((size(T.D,2)+size(T.F,2))+1:end);
    R.AKMStats.r  = O.logwage_1p2 - R.AKMStats.pe - R.AKMStats.fe - R.AKMStats.xb;
    
    disp('Number of observations:')
    disp(['Number of spells: ',num2str(numel(O.logwage_1p2))])
    disp(['Number of workers: ',num2str(numel(unique(O.id)))])
    disp(['Number of estabs: ',num2str(numel(unique(O.idnum)))])
    
    disp('AKM Reg (all) - Correlation (All)')
    corr(R.AKMStats.pe,R.AKMStats.fe,'type','spearman')
    
    disp('AKM Reg (all) - Decompostion (All)')
    disp('      Y        XB        PE        FE        R')
    disp(cov([O.logwage_1p2,R.AKMStats.xb,R.AKMStats.pe,R.AKMStats.fe,R.AKMStats.r]))
    disp(cov([O.logwage_1p2,R.AKMStats.xb,R.AKMStats.pe,R.AKMStats.fe,R.AKMStats.r])./var(O.logwage_1p2))
    
    S = O.betr_st <= 2;
    
    disp('Number of observations:')
    disp(['Number of spells: ',num2str(numel(O.logwage_1p2(S)))])
    disp(['Number of workers: ',num2str(numel(unique(O.id(S))))])
    disp(['Number of estabs: ',num2str(numel(unique(O.idnum(S))))])    
    
    disp('AKM Reg (all) - Corr (LIAB)')
    corr(R.AKMStats.pe(S),R.AKMStats.fe(S),'type','spearman')
    
    disp('AKM Reg (all) - Decomposition (LIAB)')
    disp('      Y        XB        PE        FE        R')
    disp(cov([O.logwage_1p2(S),R.AKMStats.xb(S),R.AKMStats.pe(S),R.AKMStats.fe(S),R.AKMStats.r(S)]))
    disp(cov([O.logwage_1p2(S),R.AKMStats.xb(S),R.AKMStats.pe(S),R.AKMStats.fe(S),R.AKMStats.r(S)])./var(O.logwage_1p2(S)))
    
    S = O.ind_u  == 1;

    disp('Number of observations:')
    disp(['Number of spells: ',num2str(numel(O.logwage_1p2(S)))])
    disp(['Number of workers: ',num2str(numel(unique(O.id(S))))])
    disp(['Number of estabs: ',num2str(numel(unique(O.idnum(S))))])    
    
    disp('AKM Reg (all) - Correlation (Out of Unemployment)')
    corr(R.AKMStats.pe(S),R.AKMStats.fe(S),'type','spearman')
    
    disp('AKM Reg (all) - Decomposition (Out of Unemployment)')
    disp('      Y        XB        PE        FE        R')
    disp(cov([O.logwage_1p2(S),R.AKMStats.xb(S),R.AKMStats.pe(S),R.AKMStats.fe(S),R.AKMStats.r(S)]))
    disp(cov([O.logwage_1p2(S),R.AKMStats.xb(S),R.AKMStats.pe(S),R.AKMStats.fe(S),R.AKMStats.r(S)])./var(O.logwage_1p2(S)))
    
    %% AKM Rank Correlation - Out of Unemployment Only
    disp('Limiting sample to out of unemployment ...')
    OU       = O;
    T.Sample = OU.ind_u  == 1; %#ok<NODEF>
    for ifield = fieldnames(OU)'
        eval(['OU.',ifield{1},'=','OU.',ifield{1},'(T.Sample);']);
    end
    [~,~,OU.id]         = unique(OU.id);
    [~,~,OU.idnum]      = unique(OU.idnum);
    T.DataTemp          = [OU.logwage_1p2,OU.id,OU.idnum];
    [T.X,T.D,T.F]       = getAKMDesign(T.DataTemp);
    T.X                 =[T.D,T.F,T.XBTemp(T.Sample == 1,:)];

    disp('Running AKM ...')
    T.xx=T.X'*T.X;
    T.xy=T.X'*(OU.logwage_1p2);

    L=ichol(T.xx,struct('type','ict','droptol',1e-2,'diagcomp',0.1));
    b=pcg(T.xx,T.xy,1e-10,1000,L,L');    
       
    R.AKMStatsU.pe = T.D*b(1:size(T.D,2));
    R.AKMStatsU.fe = T.F*b((size(T.D,2)+1) : (size(T.D,2)+size(T.F,2)));
    Temp           = T.XBTemp(T.Sample == 1,:);
    R.AKMStatsU.xb = Temp*b((size(T.D,2)+size(T.F,2))+1:end);
    R.AKMStatsU.r  = OU.logwage_1p2 - R.AKMStatsU.pe - R.AKMStatsU.fe - R.AKMStatsU.xb;    
    
    disp('Number of observations:')
    disp(['Number of spells: ',num2str(numel(OU.logwage_1p2))])
    disp(['Number of workers: ',num2str(numel(unique(OU.id)))])
    disp(['Number of estabs: ',num2str(numel(unique(OU.idnum)))])
    
    disp('AKM Reg (U) - Correlation (U)')
    corr(R.AKMStatsU.pe,R.AKMStatsU.fe,'type','spearman')
    
    disp('AKM Reg (U) - Decompostion (U)')
    disp('      Y        XB        PE        FE        R')
    disp(cov([OU.logwage_1p2,R.AKMStatsU.xb,R.AKMStatsU.pe,R.AKMStatsU.fe,R.AKMStatsU.r]))
    disp(cov([OU.logwage_1p2,R.AKMStatsU.xb,R.AKMStatsU.pe,R.AKMStatsU.fe,R.AKMStatsU.r])./var(OU.logwage_1p2))
    
    S = OU.betr_st <= 2;
    disp('Number of observations:')
    disp(['Number of spells: ',num2str(numel(OU.logwage_1p2(S)))])
    disp(['Number of workers: ',num2str(numel(unique(OU.id(S))))])
    disp(['Number of estabs: ',num2str(numel(unique(OU.idnum(S))))])    
    disp('AKM Reg (U) - Corr (LIAB)')
    corr(R.AKMStatsU.pe(S),R.AKMStatsU.fe(S),'type','spearman')
    
    disp('AKM Reg (U) - Decomposition (LIAB)')
    disp('      Y        XB        PE        FE        R')
    disp(cov([OU.logwage_1p2(S),R.AKMStatsU.xb(S),R.AKMStatsU.pe(S),R.AKMStatsU.fe(S),R.AKMStatsU.r(S)]))
    disp(cov([OU.logwage_1p2(S),R.AKMStatsU.xb(S),R.AKMStatsU.pe(S),R.AKMStatsU.fe(S),R.AKMStatsU.r(S)])./var(OU.logwage_1p2(S)))
    
    %% AKM Rank Correlation - LIAB
    disp('Limiting sample to LIAB Only ...')
    OU       = O;
    T.Sample = OU.betr_st <= 2; %#ok<NODEF>
    for ifield = fieldnames(OU)'
        eval(['OU.',ifield{1},'=','OU.',ifield{1},'(T.Sample);']);
    end
    [~,~,OU.id]         = unique(OU.id);
    [~,~,OU.idnum]      = unique(OU.idnum);
    T.DataTemp          = [OU.logwage_1p2,OU.id,OU.idnum];
    [T.X,T.D,T.F]       = getAKMDesign(T.DataTemp);
    T.X                 =[T.D,T.F,T.XBTemp(T.Sample == 1,:)];

    disp('Running AKM ...')
    T.xx=T.X'*T.X;
    T.xy=T.X'*(OU.logwage_1p2);

    L=ichol(T.xx,struct('type','ict','droptol',1e-2,'diagcomp',0.1));
    b=pcg(T.xx,T.xy,1e-10,1000,L,L');    
       
    R.AKMStatsL.pe = T.D*b(1:size(T.D,2));
    R.AKMStatsL.fe = T.F*b((size(T.D,2)+1) : (size(T.D,2)+size(T.F,2)));
    Temp           = T.XBTemp(T.Sample == 1,:);
    R.AKMStatsL.xb = Temp*b((size(T.D,2)+size(T.F,2))+1:end);
    R.AKMStatsL.r  = OU.logwage_1p2 - R.AKMStatsL.pe - R.AKMStatsL.fe - R.AKMStatsL.xb;    
    
    disp('Number of observations:')
    disp(['Number of spells: ',num2str(numel(OU.logwage_1p2))])
    disp(['Number of workers: ',num2str(numel(unique(OU.id)))])
    disp(['Number of estabs: ',num2str(numel(unique(OU.idnum)))])    
    
    disp('AKM Reg (L) - Correlation (L)')
    corr(R.AKMStatsL.pe,R.AKMStatsL.fe,'type','spearman')
    
    disp('AKM Reg (L) - Decompostion (L)')
    disp('      Y        XB        PE        FE        R')
    disp(cov([OU.logwage_1p2,R.AKMStatsL.xb,R.AKMStatsL.pe,R.AKMStatsL.fe,R.AKMStatsL.r]))
    disp(cov([OU.logwage_1p2,R.AKMStatsL.xb,R.AKMStatsL.pe,R.AKMStatsL.fe,R.AKMStatsL.r])./var(OU.logwage_1p2))
    
    S = OU.ind_u == 1;
    disp('Number of observations:')
    disp(['Number of spells: ',num2str(numel(OU.logwage_1p2(S)))])
    disp(['Number of workers: ',num2str(numel(unique(OU.id(S))))])
    disp(['Number of estabs: ',num2str(numel(unique(OU.idnum(S))))])       
    disp('AKM Reg (L) - Corr (U)')
    corr(R.AKMStatsL.pe(S),R.AKMStatsL.fe(S),'type','spearman')
    
    disp('AKM Reg (L) - Decomposition (U)')
    disp('      Y        XB        PE        FE        R')
    disp(cov([OU.logwage_1p2(S),R.AKMStatsL.xb(S),R.AKMStatsL.pe(S),R.AKMStatsL.fe(S),R.AKMStatsL.r(S)]))
    disp(cov([OU.logwage_1p2(S),R.AKMStatsL.xb(S),R.AKMStatsL.pe(S),R.AKMStatsL.fe(S),R.AKMStatsL.r(S)])./var(OU.logwage_1p2(S)))
  
    %% Save Fixed Effect Estimates
    save([RootDir,'\data\m3_3',P.Header,num2str(P.StartYear),num2str(P.EndYear),'_',P.Spec,'.mat'],'R','-v7.3');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('-------------------------------------------------------------------')

    fprintf('\n')
    disp('m3_3_estimateAKMMQ.m completed successfully and log closed.')

    % End logging or return to keyboard
    fclose(fopen([RootDir,'\log\done.done'],'w+'));
    exit
end
