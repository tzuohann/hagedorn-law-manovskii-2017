% This just vectorizes x and converts it 
% into a vector in the dimension specified by the second arguement
% E.G X = 3x3 array. point(X,4) = reshape(X(:),[1 1 1 numel(X)])
function X = point(x,dim)
X = reshape(x(:),[ones(1,dim-1) numel(x)]);