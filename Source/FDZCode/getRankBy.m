% Function NRRank
function NRRank = getRankBy(Names,Input)
  NRRank        = sortrows([Names,Input],2);
  NRRank        = [NRRank(:,1),Names];
  NRRank        = sortrows(NRRank,1);
end
