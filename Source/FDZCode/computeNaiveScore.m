function NumDisagreements = computeNaiveScore(LowScoreRank,iAvWageAtFirm)
  %Lower rank number is a lower type worker
  NumDisagreements = int64(0);
  LowScoreRank     = sortrows(LowScoreRank,2);
%   iAvWageAtFirm    = full(iAvWageAtFirm);
%   iAvWageAtFirm(iAvWageAtFirm == 0) = nan;
  Include = ones(size(LowScoreRank,1),1);
  for i1 = 1:size(LowScoreRank,1) - 1
    Include(LowScoreRank(i1,1)) = 0;
    [~,CurrentFirms,CurrentWage]      = find(iAvWageAtFirm(LowScoreRank(i1,1),:));
    NumDisagreements = NumDisagreements + int64(full(sum(vec(bsxfun(@gt,CurrentWage,iAvWageAtFirm(Include == 1,CurrentFirms))))));
  end
end
