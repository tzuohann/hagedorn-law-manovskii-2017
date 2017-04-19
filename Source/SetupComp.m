function C = SetupComp(C,P,S,M)
  %Set up computations.
  %See user guide/data dictionary for more information.
    
  display('SetupComp')

  % Set random seed
  if S.FixSeed(1) > 0
    RandStream.setGlobalStream(RandStream('mcg16807','Seed',S.FixSeed(1)));
  end    
  
  if numel(C.GridZeta) > 1
    C.GridBins            = C.GridZeta - ((C.GridZeta(2) - C.GridZeta(1)))/2;
    C.GridBins            = [C.GridBins,C.GridZeta(end) + ((C.GridZeta(2) - C.GridZeta(1))/2)];
    C.ZetaProb            = truncated_normal_ab_cdf ( C.GridBins, 0, C.GridZeta(end)/2, min(C.GridBins), max(C.GridBins) );
    C.ZetaProb            = diff(C.ZetaProb,1);
  else
    C.GridBins            = 1;
    C.ZetaProb            = 1;
  end
  C.LenGridZ              = numel(C.GridZeta);
  C.ZetaBounds            = [min(C.GridZeta),max(C.GridZeta)];
  
  C.NumAgentsSim          = C.NumAgentsSimMult*C.LenGrid; %Number of agents per type on prod grid
  C.NumJobsSimMult        = round(P.Pf.*C.NumAgentsSimMult);
  C.NumJobsSim            = C.LenGrid.*C.NumJobsSimMult;
  C.Periods               = 12*C.Years;   %Convert to monthly.
  C.BurnIn                = 1000;
  
  %Create or clear all irrelavant stuff from Output
  ClearOutputAndVariables;
 
  %These are parameters that don't need to be changed on a regular basis.
  C.NumXBins        = C.LenGrid;    %Number of bins to put workers intM. C.LenGrid for this paper.
  C.NumYBins        = C.LenGrid;    %Number of bins to put firms intM. C.LenGrid for this paper.  
  C.MaxIter         = 5000;
  
    %Make the grids.
  C         = GridMake(C);
  
  %Make the population densities.
  C         = MakeDens(C,P);
 
  %Generate the production function using defined ProdFn and Densities.
  [C.Prod,C.ProdBase]     =   MakeProd(P,C);
  
  %Fix initial match density as some random number.
  %If it already exists, simply interpolate from the previous case.
  if C.LenGrid == C.LenGridChoice(1)
    C.MatDen0   = 0.00001*rand(C.LenGrid,C.LenGrid,C.LenGridZ);
    C.Surp0     = C.Prod.*rand(size(C.Prod));
  else
    Tmp             = size(M.MatDen,1);
    OldGrid         = linspace(0,1,Tmp(end));
    NewGrid         = meshgrid(C.Grid,C.Grid);
    C.Surp0         = zeros(C.LenGrid,C.LenGrid,C.LenGridZ);
    C.MatDen0       = zeros(C.LenGrid,C.LenGrid,C.LenGridZ);
    for iz = 1:C.LenGridZ
      C.Surp0(:,:,iz)     = interp2(OldGrid,OldGrid,M.Surp(:,:,iz),NewGrid,NewGrid','nearest');
      C.MatDen0(:,:,iz)   = interp2(OldGrid,OldGrid,M.MatDen(:,:,iz),NewGrid,NewGrid','linear');
      while max(sum(C.MatDen0(:,:,iz),2)) > C.LenGrid*C.ZetaProb(iz)
        C.MatDen0(:,:,iz)       = C.MatDen0(:,:,iz).*0.999;
      end
      while max(sum(C.MatDen0(:,:,iz),1)) > P.Pf*C.LenGrid*C.ZetaProb(iz)
        C.MatDen0(:,:,iz)       = C.MatDen0(:,:,iz).*0.999;
      end
    end
    if sum(C.MatDen0(:))*C.MatchSize > 1
      disp('Too many matches')
      keyboard
    end
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function ClearOutputAndVariables
  %Clean up irrelavant stuff in output folder.
  if exist('Output','dir') == 0
    mkdir('.','Output');
  else
    delete Output/*.smcl;
    delete Output/*.dta;
    delete Output/StataData*.mat;
    delete Output/*.do;
    delete Output/*.txt;
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [Prod,ProdBase] = MakeProd(P,C)
  DensW     = DensMaker(P.DistX,C.Grid);
  DensF     = DensMaker(P.DistY,C.Grid);
  DensW     = cumsum(DensW)/sum(DensW);
  DensF     = cumsum(DensF)/sum(DensF);
  %Constructing the production function
  
  if strcmp(P.ProdFn,'data')
    load CompiledData.mat

    ScaleFactor     = P.ScaleFactor;
    ValVac_Full     = ValVac_Full*ScaleFactor;
    
    Prod            = WageXY_Full + (1-Bbeta)*repmat(vec(ValVac_Full)',50,1);
    X               = repmat(vec(linspace(0,1,50)),1,50);
    Y               = X';
keyboard
    [xData, yData, zData] = prepareSurfaceData( X, Y, Prod );
    % Set up fittype and options.
    ft = fittype( 'loess' );
    opts = fitoptions( ft );
    opts.Span = 0.05;
    opts.Normalize = 'on';
    % Fit model to data.
    [fitresult, gof] = fit( [xData, yData], zData, ft, opts );
    Xind               = repmat(vec(1:C.LenGrid),1,C.LenGrid);
    Yind               = Xind';    
    Prod             = full(sparse(Xind,Yind,fitresult(X,Y)));

    
%     AccSetA(1:8,17) = 0;
%     AccSetA(20:end,7:8) = 0;
%     AccSetA(30:end,14) = 0;
%     AccSetA(36:end,18:19) = 0;
%     AccSetA(38:end,20) = 0;
%     
%     Expand          = P.Expand;
%     AccSetANew      = zeros(50,50);
%     %Make the production function a little wider
%     for ix = 1:50
%       for iy = 1:50
%         if AccSetA(ix,iy) == 1;
%           AccSetANew(ix,max(1,iy - Expand) : min(50,iy + Expand)) = 1;
%         end
%       end
%     end
%     AccSetA         = AccSetANew;
%     Prod            = Prod.*AccSetA;
        
    Prod(isnan(Prod)) = 0;
    Prod      = Prod + P.ConstantProd.*(Prod > 0);
    ProdBase  = Prod;
  else
  temp      = str2func(P.ProdFn);
  Prod      = zeros(C.LenGrid,C.LenGrid,C.LenGridZ);
  ProdBase  = zeros(C.LenGrid,C.LenGrid);
  for ix = 1:C.LenGrid
    X = interp1(DensW,C.Grid,ix/C.LenGrid);
    for iy = 1:C.LenGrid
      Y = interp1(DensF,C.Grid,iy/C.LenGrid);
      ProdBase(ix,iy) = temp(X,Y);
      for iz = 1:C.LenGridZ
        %This is Production including the shock
        Prod(ix,iy,iz) = temp(X,Y) + C.GridZeta(iz);
      end
    end
  end
  end
  if any(vec(isnan(Prod) | isinf(Prod)))
    error('Production Function Problem')
  end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function C = GridMake(C)
  C.Grid = linspace(0,1,C.LenGrid)';
  C.AgentSize = 1/C.LenGrid;
  C.MatchSize = C.AgentSize.^2;
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function C = MakeDens(C,P)
  %Generate the densities. This are all uniform anyways.
  C.DensX     = ones(C.LenGrid,1);
  C.DensY     = P.Pf.*ones(C.LenGrid,1);
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function Dens = DensMaker(Dist,Grid)
  %Function to generate based densities for workers and firms
  switch Dist
    case {1}
      temp = pdf('uniform',linspace(Grid(1),Grid(end),100*length(Grid)),0,1);
    case {2}
      temp = pdf('normal',linspace(Grid(1),Grid(end),100*length(Grid)),0.5,0.5);
    case {3}
      temp = pdf('normal',linspace(Grid(1),Grid(end),100*length(Grid)),0.2,0.2);
      temp = temp + pdf('normal',linspace(Grid(1),Grid(end),100*length(Grid)),0.8,0.2);
  end
  temp1 = sort(mod(1:(100*length(Grid)),length(Grid))+1);
  Dens = zeros(size(Grid,1),1);
  for i1 = 1:size(Grid,1);
    Dens(i1,1) = mean(temp(temp1 == i1));
  end
end
