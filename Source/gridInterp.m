function [M]     = gridInterp(M,C,P,S)
  % Interpolate the original grid.
  % 1D first.
  TMP  = M;
  
  % Interpolate surplus and match density. Then use the original program to
  % recover everything else so it is more consistent.
  C.Surp0    = areaInter2D(M.Surp,C.LenGrid,C.MatchSize,C.LenGridZ,M.MatDen);
  
  MatDen    = areaInter2D(M.MatDen,C.LenGrid,C.MatchSize,C.LenGridZ);
  if checkMD(MatDen,P.Pf) == 1
    C.MatDen0 = MatDen;
  else
    warning('Match Density Interp is Wrong')
    keyboard
  end

  PostProcess = 1;
  disp('Approximating Equilibrium - In Theory')
  M = computeModel(C,P,S,PostProcess);
  M.Solution = TMP;
end

function OK = checkMD(MatDen,Pf)
  if any(sum(sum(MatDen,3),1) > Pf*size(MatDen,1))
    warning('MatDen too large')
    OK = 0;
    return
  elseif any(sum(sum(MatDen,3),2) > size(MatDen,1))
    warning('MatDen too large')
    OK = 0;
    return
  elseif any(MatDen(:) < 0)
    warning('MatDen negative')
    OK = 0;
    return
  else
    OK = 1;
  end
end

function NewMat = areaInter2D(OrigMat,LenGrid,MatchSize,LenGridZ,varargin)
  %Display average the original function to get the new one.
  if isempty(varargin) == 1
  else
    WeightMat = varargin{1};
  end

  NewMat                      = zeros(LenGrid,LenGrid,LenGridZ);
  PAS                         = 1./size(OrigMat,1);
  PMS                         = PAS^2;
  LeftsNew                    = linspace(0,1,LenGrid + 1);
  RightsNew                   = LeftsNew(2:end);
  LeftsNew                    = LeftsNew(1:end-1);
  LeftsOld                    = linspace(0,1,size(OrigMat,1) + 1);
  RightsOld                   = LeftsOld(2:end);
  LeftsOld                    = LeftsOld(1:end-1);
  %Do a numerical integration here.
  for iz = 1:LenGridZ
    for i1 = 1:LenGrid
      D1Inclu         = RightsOld >= LeftsNew(i1) & LeftsOld <= RightsNew(i1);
      D1Wts           = min(min(RightsNew(i1) - LeftsOld,PAS),min(RightsOld - LeftsNew(i1),PAS)).*D1Inclu./PAS;
      for i2 = 1:LenGrid
        % Enumerate all the points falling in the new grid.
        % Will treat each point of the new grid representing points on some
        % interval. IE, 0 is the first point in a 70 grid. So it is on the
        % interval 0 to 1/70.
        % CONTINUE
        D2Inclu         = RightsOld >= LeftsNew(i2) & LeftsOld <= RightsNew(i2);
        D2Wts           = min(min(RightsNew(i2) - LeftsOld,PAS),min(RightsOld - LeftsNew(i2),PAS)).*D2Inclu./PAS;
        if isempty(varargin)
          NewMat(i1,i2,iz)   = sum(vec(OrigMat(:,:,iz).*(D1Wts'*D2Wts)))*PMS/MatchSize;
        else
          try
            NewMat(i1,i2,iz)   = wmean(vec(OrigMat(:,:,iz)),vec((D1Wts'*D2Wts).*WeightMat(:,:,iz)));
          catch
            keyboard
          end
        end
      end
    end
  end
  
  function y = wmean(x,w,dim)
    %WMEAN   Weighted Average or mean value.
    %   For vectors, WMEAN(X,W) is the weighted mean value of the elements in X
    %   using non-negative weights W. For matrices, WMEAN(X,W) is a row vector
    %   containing the weighted mean value of each column.  For N-D arrays,
    %   WMEAN(X,W) is the weighted mean value of the elements along the first
    %   non-singleton dimension of X.
    %
    %   Each element of X requires a corresponding weight, and hence the size
    %   of W must match that of X.
    %
    %   WMEAN(X,W,DIM) takes the weighted mean along the dimension DIM of X.
    %
    %   Class support for inputs X and W:
    %      float: double, single
    %
    %   Example:
    %       x = rand(5,2);
    %       w = rand(5,2);
    %       wmean(x,w)
    
    if nargin<2
      error('Not enough input arguments.');
    end
    
    % Check that dimensions of X match those of W.
    if(~isequal(size(x), size(w)))
      error('Inputs x and w must be the same size.');
    end
    
    % Check that all of W are non-negative.
    if (any(w(:)<0))
      error('All weights, W, must be non-negative.');
    end
    
    % Check that there is at least one non-zero weight.
    if (all(w(:)==0))
      y = 0;
      return
    end
    
    if nargin==2,
      % Determine which dimension SUM will use
      dim = min(find(size(x)~=1));
      if isempty(dim), dim = 1; end
    end
    
    y = sum(w.*x,dim)./sum(w,dim);
  end
end