function [S,C,P,M,Sim,RD,SimO] = Compute(C,V,S)
  %Applies all other functions to each set of parameters defined earlier.
  
  %Generate all possible combinations of the parameters
  S = GenParMixAndDelegate(V,S);
  
  %Fix random number generator seeds
  FixRNGSeeds
  
  %Run computation for all sets specified.
  iseed = 0;
  for iprod = 1:3
    for iout = S.Sets
      iseed = iseed + 1;
      
      if (iprod == 2 && ismember(iout,[33]))
        
        clearvars -except C V S iout iprod iseed FixSeed
        
        %Select the appropriate RNG seed
        %         S.FixSeed = FixSeed.(S.Scheme)(iseed,:);
        S.FixSeed = randperm(400,4);
        S.FixSeed = randperm(400,4);
        S.FixSeed = randperm(400,4);
        S.FixSeed = randperm(400,4);
        S.FixSeed = randperm(400,4);
        S.FixSeed = randperm(400,4);
        S.FixSeed = randperm(400,4);
        S.FixSeed = randperm(400,4);
        S.FixSeed = randperm(400,4);
        S.FixSeed = randperm(400,4);
        S.FixSeed = randperm(400,4);
        S.FixSeed = randperm(400,4);
        
        %Set the parameters.
        P   = AssignParameters(C,V,S,iout,iprod);
        
        %Use progresively finer grid points with previous output
        C.LenGridChoice   = C.LenGrid:100:C.LenGrid+7*100;
        ic                = 0;
        M.Converged       = 0;
        LenGridOrig       = C.LenGrid;
        while ic < numel(C.LenGridChoice) && M.Converged == 0
          %Use the next grid choice.
          ic = ic + 1;
          C.LenGrid       = C.LenGridChoice(ic);
          
          disp(['Using ',num2str(C.LenGrid),' grid points.']);
          
          % Set up the computation
          C               = SetupComp(C,P,S,M);
          
          %Check for incorrect inputs to simulation.
          Warnings(C,S,P)
          
          M     = computeModel(C,P,S);
          
        end
        C.LenGrid         = LenGridOrig;
        if M.Converged == 0
          error('Computation did not work.')
        end
        
        %Interpolate back to the desired gridding.
        C     = SetupComp(C,P,S,M);
        M     = gridInterp(M,C,P,S);
        
        %Post processing. Calculate wages from surplus.
        M     = postProcessOutput(C,P,M);
        
        %Simulation
        [SimO,Sim]        = SimMaker(M,C,P,S);
        
        %Estimation
        [RD]              = WantedVars(C,M,P,Sim,SimO,S);
        
        %Save data
        SaveData(S,M,P,C,V,SimO,RD,Sim); %#ok<*NODEF>
      end
    end
  end
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function SaveData(S,varargin) %#ok<INUSL,INUSD>
  %Saves the data if S.SaveData = 1
  for in = 2:numel(varargin) + 1
    eval([inputname(in),' = varargin{in - 1};'])
  end
  Str   = '';
  for in = 1:numel(varargin) + 1
    Str   = [Str,inputname(in),' '];
  end
  eval(['clearvars -except ',Str])
  eval(strcat('save Output\',P.FName,'.mat -v7.3'))
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function Warnings(C,S,P)
  %Use this function to detect errors in setup.
  if rem(C.NumJobsSimMult,C.jSizeDist) ~= 0 && S.Simulate > 0
    error('Firm size misspecified. Put random, or fix it so that rem(Size,NumJobsSimMult) == 0')
  else
    disp(['Each bin has ',num2str(C.NumJobsSimMult/C.jSizeDist),' firms with ',num2str(C.jSizeDist),' jobs each.']);
  end
  if any(S.Sets > size(S.Mix,1))
    error('Selected sets outside size of Mix')
  end
  if isempty(S.Sets)
    error('No sets computed. Check S.Sets')
  end
  if C.LenGridZ ~= numel(C.ZetaProb) && strcmp(C.ShockStyle,'none') == 0
    error('Specify Zeta Prob properly.')
  end
  if any(isnan(C.ZetaProb))
    error('Zeta Shock Prob must not be nan')
  end
  if sum(C.ZetaProb) - 1 > eps
    error('Zeta Shock Prob must add to 1')
  end
  if any(C.ZetaProb < 0)
    error('Zeta Probability negative somewhere.')
  end
  if C.LenGridZ > 1 && P.Pphi > 0
    error('You do not have security clearance for OJS and Match Specific Shocks.')
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [S] = GenParMixAndDelegate(V,S)
  %Generate the permutations of V
  V = rmfield(V,{'ProdFn'});
  S.Mix = mixgenAM(V);
  S.Sets = 1 : size(S.Mix,1);
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function Mix = mixgenAM(Y)
  %Utility function for GenParMixAndDelegate
  YFieldNames = fieldnames(Y);
  X = zeros(size(YFieldNames,1),1);
  for i1 = 1:size(YFieldNames,1);
    eval(strcat('X(i1) = size(Y.',YFieldNames{i1},',1);'));
  end
  len = length(X);
  Strbuildndgrid = '1:X(1)';
  Strbuildmix = 'Temp{1}(:)';
  for a = 2:len
    Strbuildndgrid = [Strbuildndgrid,sprintf(',1:%d',X(a))];
    Strbuildmix =[Strbuildmix,sprintf(',Temp{%d}(:)',a)];
  end
  [Temp{1:len}] = eval(sprintf('ndgrid(%s)',Strbuildndgrid));
  Mix = eval(sprintf('[%s]',Strbuildmix));
end
