function Vec = nonnan(X)
  Vec = vec(X(~isnan(X)));
end
