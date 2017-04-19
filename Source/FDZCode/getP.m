function p = getP(LenGrid,Numj,SpellType,SimJName,iBin)
  %Author: Tzuo Hann Law (tzuohann@gmail.com)
  p        = zeros(LenGrid,Numj);
  for i1 = 1:size(SpellType,1)
    for it = 1:size(SpellType,2)
      Record = 0;
        if it > 1
          if SimJName(i1,it) ~= SimJName(i1,it-1)
              Record = 1;
          end
        end
        if it == 1 
            Record = 1;
        end
        ij = SimJName(i1,it);
        if ij > 0 && Record == 1     
            p(iBin(i1),ij) = p(iBin(i1),ij) + 1;
        end
    end
  end
end

% function p = getP(LenGrid,NumjY,JobNamejY,AllWBins)
%   %Get the number of out of unemployment spells by bin for all firms.
%   %See user guide/data dictionary for more information.
%   %Author: Tzuo Hann Law (tzuohann@gmail.com)
%   p = zeros(LenGrid,NumjY);
%   [Job,~,WBin]  = find(AllWBins);
%   Job           = JobNamejY(Job);
%   JobWBin       = sortrows([Job,WBin],1:2);
%   [B,Cnt]       = unique(JobWBin,'rows');
%   Cnt           = diff([0;Cnt]);
%   for i1 = 1:size(B,1)
%     p(B(i1,2),B(i1,1)) = Cnt(i1);
%   end
% end
