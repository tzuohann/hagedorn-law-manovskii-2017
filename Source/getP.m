% function p = getP(LenGrid,Numj,iBin,AllW,JobNamejY,iDropped)
%   %Get the number of unemployment spells by bin for all firms.
%   %See user guide/data dictionary for more information.
%   AllW(AllW > 0) = iBin(AllW(AllW > 0));
%   p = zeros(LenGrid,Numj);
%   for ij = 1:Numj
%     VecW  = nonzeros(AllW(JobNamejY == ij & iDropped == 0,:));
%     for ix = 1:LenGrid
%       p(ix,ij) = sum(VecW == ix);
%     end
%   end
% end

function p = getP(LenGrid,NumjY,JobNamejY,AllWBins)
  %Get the number of out of unemployment spells by bin for all firms.
  %See user guide/data dictionary for more information.
  %Author: Tzuo Hann Law (tzuohann@gmail.com)
  p = zeros(LenGrid,NumjY);
  [Job,~,WBin]  = find(AllWBins);
  Job           = JobNamejY(Job);
  JobWBin       = sortrows([Job,WBin],1:2);
  [B,Cnt]       = unique(JobWBin,'rows');
  Cnt           = diff([0;Cnt]);
  for i1 = 1:size(B,1)
    p(B(i1,2),B(i1,1)) = Cnt(i1);
  end
end
