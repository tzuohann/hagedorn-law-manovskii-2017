%This function takes output from 3_1 and prepares it so that it can be used
%by subsequent procedures. 
function m3_2_dataPreparation(StartYear,EndYear,Spec,Header,RootDir)
  
  fprintf('\n')
  disp('-------------------------------------------------------------------')
  disp('Running m3_2_dataPreparation.m...')
  disp('This function takes the .mat from Section 3.1.1')
  disp('and prepares it so that it can be used later.')
  fprintf('\n')
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('-------------------------------------------------------------------')
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Section 3.2.1: Load Data %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('Section 3.2.1: Load Data')
  disp('Loading .mat data from Section 3.1.1...')
  fprintf('\n')  
  
  %Load the file produced by 3_1
  if strcmp(Header,'men')
    load([RootDir,'\data\',Header,num2str(1993),num2str(2007),'_',Spec,'.mat'])
  else
    load([RootDir,'\data\',Header,num2str(StartYear),num2str(EndYear),'.mat'])
  end

  P.Header    = Header;
  P.StartYear = StartYear;
  P.EndYear   = EndYear;
  P.Spec      = Spec;

  %Functions used to calculate ages and employment durations from raw data
  F.getPeriod       = @(year,month) (year - P.StartYear)*12 + month;
  F.getDuration     = @(tend,tstart) tend - tstart + 1;
  F.getAge          = @(birthyear,year) year - birthyear;
  
  %Display the title of the data under consideration
  disp([Header,Spec,num2str(StartYear),num2str(EndYear)]);
  disp([Header,Spec,num2str(StartYear),num2str(EndYear)]);
  disp([Header,Spec,num2str(StartYear),num2str(EndYear)]);
  disp([Header,Spec,num2str(StartYear),num2str(EndYear)]);
   
  disp('-------------------------------------------------------------------')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Section 3.2.2: Restrict to Non-Missing Data %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('Section 3.2.2: Restrict to Non-Missing Data')
  fprintf('\n')

  %% Sample
  %Restrict to available data (education group, etc)
  T.Sample = zeros(size(O.start_year));
  % Outside year range.
  T.Sample(O.start_year < P.StartYear | O.end_year > P.EndYear) = 1;
  % Missing education.
  T.Sample(T.Sample == 0 & (O.edgroup < 0)) = 2;
  % Missing birthyear
  T.Sample(T.Sample == 0 & (O.gebjahr < 0)) = 3;
  % Missing idnum
  T.Sample(T.Sample == 0 & (O.idnum < 0)) = 4;
  disp('Report Missing information')
  disp('Outside year range - 1');
  disp('Missing education  - 2');
  disp('Missing birthyear  - 3');
  disp('Missing idnum      - 4');
  tabulate(T.Sample);
  
  %First round is to get rid of missing data
  T.Sample = T.Sample == 0;
  for ifield = fieldnames(O)'
    eval(['O.',ifield{1},'=','O.',ifield{1},'(T.Sample);']);
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('-------------------------------------------------------------------')
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Section 3.2.3: Summary Statistics %%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('Section 3.2.3: Summary Statistics')
  
  fprintf('\n')
  disp('Level of Aggregation: Entire Sample')
  fprintf('\n')
  disp('Sample Size')
  fprintf('\n')
  
  %Relabel the firms to go from 1 to J
  [~,~,O.idnum] = unique([O.idnum]);
  
  disp(['Number of Firms              : ',num2str(max(O.idnum))])
  
  %Relabel the workers to go from 1 to N
  [~,~,O.id]   = unique(O.id);
  
  disp(['Number of Workers            : ',num2str(max(O.id))])
  
  %Display the number of observations
  disp(['Number of observations       : ',num2str(numel(O.id))]);
  fprintf('\n')
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('-------------------------------------------------------------------')
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Section 3.2.4: Restrict Sample to Connected Set of Firms %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('Section 3.2.4: Restrict Sample to Connected Firms')
  fprintf('\n')
  disp('Connectedness is based on worker mobility. A firm is not connected')
  disp('if we never observe its workers moving to another firm.')
  disp('')
  fprintf('\n')
  
  disp('Dropping for connected set.');
  %Add subfunctions that are needed to the path
  addpath(genpath([RootDir,'\prog\matlab_bgl']))
  %Restrict to largest connected set.
  O = getConnectedSet(O);
  disp(['Remaining observations : ',num2str(numel(O.id))]);
  
  %Add subfunctions that are needed to the path
  rmpath(genpath([RootDir,'\prog\matlab_bgl']))
  
  %Relabel the firms to go from 1 to J
  [~,~,O.idnum]=unique([O.idnum]);
  %Relabel the workers to go from 1 to N
  [~,~,O.id]=unique(O.id);
  
  fprintf('\n')
  disp('Level of Aggregation         : Entire Connected Sample')
  fprintf('\n')
  disp(['Number of Firms              : ',num2str(max(O.idnum))])
  fprintf('\n')
  disp(['Number of Workers            : ',num2str(max(O.id))])
  fprintf('\n')
  disp(['Number of Observations       : ',num2str(numel(O.id))]);
  fprintf('\n')
  
  %Delete Temporary Variables
  clear T i* ans
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('-------------------------------------------------------------------')
  
  
  %% Save
  fprintf('\n')
  disp('Saving data to m3_2----.mat...')
  save([RootDir,'\data\m3_2',num2str(P.StartYear),num2str(P.EndYear),'_',P.Spec,'.mat'],'-regexp','^(?!(P|T|F|C|i.*|ans)$).','-v7.3');
   
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('-------------------------------------------------------------------')
  
  
  fprintf('\n')
  disp('m3_2_dataPreparation.m completed successfully and log closed.')
  
  % End logging.
  fclose(fopen([RootDir,'\log\done.done'],'w+'));
  exit
end
