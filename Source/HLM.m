function [S,C,P,M,Sim,RD,SimO] = HLM(Scheme)  
  %% HOUSEKEEPING
  format short; clear mex;
  
  %% SETUP
  S.Scheme                = Scheme; %Name this specification.
  S.IterInfoDisp          = 100; %How often to display status.
  
  %These paremeters are for troubleshooting.
  C.PerfectiRank          = 0; %1 assigns perfect ranking. %2 uses ExpW
  C.PerfectjRank          = 0; %1 perfect firm ranking.
  C.PerfectMatchVars      = 0; %1 assigns perfect job filling rate.
  C.PerfectAccRate        = 0; %1 assigns perfect job acceptance rate to all firms.
  C.PerfectMaxjSize       = 0; %1 assigns exact firm(j) size.
  C.PerfectMinWage        = 0; %1 assigns model minimum wage to all workers >= reservation wage. 2 assigns the reservation wage.
  C.PerfectjWageDiff      = 0; %1 perfect firm average wage premium.
  C.PerfectEEWageDiff     = 0; %1 perfect firm EE wage diff.
  C.PerfectiUnE           = 0; %1 use model for worker unemployment.
  C.PerfectAverageWages   = 0; %1 perfect average wage for each firm.
  C.PerfectWMob           = 0; %1 perfect mobility numbers.
  C.PerfectZAccProb       = 0; %1 perfect value ZAccProb
  
  %% COMPUTATION PARAMETERS
  V.HomeProd              = [0];        %Home production for worker.
  V.VacCost               = [0];        %Vacancy costs (For cost of 1 per period, put 1 and not -1).
  V.Kkappa                = [0.4;0.7];  %Matching function parameter, refer to above.
  V.NnuS                  = [0.5];      %Matching function parameter, refer to above.
  V.NnuV                  = [0.5];      %Matching function parameter, refer to above.
  V.Aalpha                = [0.5];      %Worker share of surplus.
  V.Ddelta                = [0.01;0.025];     %Exogenous destruction rate.
  V.DistX                 = [1;2;3];          %1 uniform, 2 normal, 3 bimodal. Refer to paper.
  V.DistY                 = [1;2;3];          %1 uniform, 2 normal, 3 bimodal. Refer to paper.
  V.Pf                    = 1;                %Relative size of firms to workers.
  V.ProdFn.pam            = '@(x,y) 0.6 + 0.4* (x^0.5 + y^0.5)^(2)';
  V.ProdFn.nam            = '@(x,y) (x^2 + 2*y^2)^(1/2)';
  V.ProdFn.not            = '@(x,y) (0.4 + (x-0.4+1)*y).*double(x<=0.4) + (0.4+((x-0.4)^2+y^2)^(1/2)).*double(x>0.4)';
  
  switch S.Scheme
    case {'test'}
      
    case {'benchmark'}
      C.NumAgentsSimMult      = 600;  %Number of agents per type for simulation.
      C.Years                 = 20;   %Years in simulation.
      C.jSizeDist             = 100; %Total number of vacancies for each firm.
      V.Pphi                  = 0; %OJS parameter
      V.Bbeta                 = 0.996;    %Time discount factor.
      C.GridZeta              = 0;    %Match Quality Shock Grid
      C.UseVacs               = 0; %Use vacancy information
      V.VarDueNoise           = 0.2;              %Wage variance due to measurement error.
      C.DropExt               = 0.1; %Cutoff for dropping algorithm
    case {'smallfirms'}
      C.NumAgentsSimMult      = 600;  %Number of agents per type for simulation.
      C.Years                 = 20; %Years in simulation.
      C.jSizeDist             = 20; %Total number of vacancies for each firm.
      V.Pphi                  = 0; %OJS parameter
      V.Bbeta                 = [0.996];    %Time discount factor.
      C.GridZeta              = 0;    %Match Quality Shock Grid
      C.UseVacs               = 0; %Use vacancy information
      V.VarDueNoise           = 0.2;              %Wage variance due to measurement error.
      C.DropExt               = 0.1; %Cutoff for dropping algorithm
    case {'highbeta'}
      C.NumAgentsSimMult      = 600;  %Number of agents per type for simulation.
      C.Years                 = 20;   %Years in simulation.
      C.jSizeDist             = 100; %Total number of vacancies for each firm.
      V.Pphi                  = 0; %OJS parameter
      V.Bbeta                 = 0.999;    %Time discount factor.
      C.GridZeta              = 0;    %Match Quality Shock Grid
      C.UseVacs               = 0; %Use vacancy information
      V.VarDueNoise           = 0.2;              %Wage variance due to measurement error.
      C.DropExt               = 0.1; %Cutoff for dropping algorithm
    case {'shortsample'}
      C.NumAgentsSimMult      = 1200;  %Number of agents per type for simulation.
      C.Years                 = 10;   %Years in simulation.
      C.jSizeDist             = 100; %Total number of vacancies for each firm.
      V.Pphi                  = 0; %OJS parameter
      V.Bbeta                 = [0.996];    %Time discount factor.
      C.GridZeta              = 0;    %Match Quality Shock Grid
      C.UseVacs               = 0; %Use vacancy information
      V.VarDueNoise           = 0.2;              %Wage variance due to measurement error.
      C.DropExt               = 0.1; %Cutoff for dropping algorithm
    case {'matchquality'}
      C.NumAgentsSimMult      = 1200;  %Number of agents per type for simulation.
      C.Years                 = 20;    %Years in simulation.
      C.jSizeDist             = 100;   %Total number of vacancies for each firm.
      V.Pphi                  = 0;     %OJS parameter
      V.Bbeta                 = 0.996; %Time discount factor.
      C.GridZeta              = linspace(-0.21,0.21,21); %Match Quality Shock Grid
      C.UseVacs               = 1;      %Use vacancy information
      V.VarDueNoise           = 0.03;              %Wage variance due to measurement error.
      C.DropExt               = 0; %Cutoff for dropping algorithm
    case {'ojs'}
      C.NumAgentsSimMult      = 600;  %Number of agents per type for simulation.
      C.Years                 = 20;    %Years in simulation.
      C.jSizeDist             = 100;   %Total number of vacancies for each firm.
      V.Pphi                  = 0.2;   %OJS parameter
      V.Bbeta                 = 0.996; %Time discount factor.
      C.GridZeta              = 0;     %Match Quality Shock Grid
      C.UseVacs               = 0;     %Use vacancy information
      V.VarDueNoise           = 0.2;   %Wage variance due to measurement error.
      C.DropExt               = 0.1; %Cutoff for dropping algorithm
    otherwise
      error('Scheme is not defined')
  end
  
  %More computation parameters
  C.LenGrid               = 50;   %Number of grid points to discretize productivity.
  C.Nodes                 = 3000; %Number of nodes for the LAP problem.
  C.Std2Truncate          = 3; %Standard deviations to truncate from noise.
  C.TolExit               = 5e-7;  %Exit tolerance.
  C.OMPTHREADS            = 1; %Number of OMPTHREADS to use in ranking workers.
  C.NITERMAX              = 100; %Number of iterations to run ranking algorithm
  C.MCutOff               = 3; %Mi >= C.MCutOff is not used for min wage, but used for acc prob
  C.DistMaxInGlo          = C.NumAgentsSimMult.*C.LenGrid*0.9; %Initial width of worker ranking.
  C.ProbDistInc           = 0.9; %Prob of increasing distance in rankAlgo
  C.MovesToSave           = 0; %How many moves to save NRAgg. 0 means never.
  C.DispCheck             = 10000; %How many checks before display
  C.DispMove              = 10000; %How many moves before display
  
  %% AUTOMATED, USER SHOULD IGNORE
  % Compute the model and run simulation if needed
  [S,C,P,M,Sim,RD,SimO]       = Compute(C,V,S);
  
end
