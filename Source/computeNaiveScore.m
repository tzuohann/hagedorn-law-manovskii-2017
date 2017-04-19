function NumDisagreements = computeNaiveScore(LowScoreRank,iAvWageAtFirm)
  %Lower rank number is a lower type worker
  NumDisagreements = 0;
  LowScoreRank     = sortrows(LowScoreRank,2);
  iAvWageAtFirm    = full(iAvWageAtFirm);
  iAvWageAtFirm(iAvWageAtFirm == 0) = nan;
  Include = ones(size(LowScoreRank,1),1);
  for i1 = 1:size(LowScoreRank,1) - 1
    Include(LowScoreRank(i1,1)) = 0;
    CurrentWage       = iAvWageAtFirm(LowScoreRank(i1,1),:);
    CurrentFirms      = ~isnan(CurrentWage);
    CurrentWage       = CurrentWage(CurrentFirms);
    NumDisagreements = NumDisagreements + sum(vec(bsxfun(@gt,CurrentWage,iAvWageAtFirm(Include == 1,CurrentFirms))));
  end
end
