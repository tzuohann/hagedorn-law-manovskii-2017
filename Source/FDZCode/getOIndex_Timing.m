function O           = getOIndex_Timing(O,F,SimO)
%Compute employment durations and return indices
O.Duration   = F.getDuration(F.getPeriod(O.end_year,O.end_month),F.getPeriod(O.start_year,O.start_month));
O.tFrom1     = F.getPeriod(O.start_year,O.start_month);
O.IndexLoc  = zeros(sum(O.Duration),1);
O.IndexDur  = zeros(sum(O.Duration),1);
O.BackToO   = zeros(SimO.NumI,1);
icount      = 0;
for i1 = 1:numel(O.id);
    O.BackToO(i1)   = icount + 1;
    O.IndexLoc(icount + 1:icount + O.Duration(i1),1) = i1;
    O.IndexDur(icount + 1:icount + O.Duration(i1),1) = 1:O.Duration(i1);
    icount = icount + double(O.Duration(i1));
end
end