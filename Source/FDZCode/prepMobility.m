function T = prepMobility(O)
% Construct worker mobility data from spell data, including employment
% spell duration, an indicator if the worker was unemployed before the
% current spell and an indicator if the next job was taken while unemployed

[~,T.FirstWIdx,~]   = unique(O.id,'rows','first');
T.LastWIdx          = [T.FirstWIdx(2:end) - 1; numel(O.id)];
T.SplFL             = zeros(size(O.id));
T.SplFL(T.FirstWIdx)    = 1;
T.SplFL(T.LastWIdx) = T.SplFL(T.LastWIdx) + 2;

%Picks up all exits from unemployment. If first time we see a worker is an
%exit from unemployment, there was a new employment spell there. It may not
%be the very first episode of the employment spell, but as a counting
%device, it is alright.

T.FirstSpellOfEmpSpell = (T.SplFL == 1);

%T.FirstSpellOfEmpSpell = (T.SplFL == 1 & O.ind_u == 1) | [0;O.ind_u(1:end-1) == 0 & O.ind_u(2:end) == 1 & O.id(1:end-1) == O.id(2:end)];

%Picks up all new job spells. First time we see a worker must account for
%one new job spell. Same thing about not being the very first
%record/episode but alright for counting.
T.FirstSpellOfJobSpell = T.SplFL == 1 | [0;O.idnum(1:end-1) ~= O.idnum(2:end)] | T.FirstSpellOfEmpSpell;

T.idnumlead = O.idnum(2:end);
T.idnumlag  = O.idnum(1:end-1);
T.idlead    = O.id(2:end);
T.idlag     = O.id(1:end-1);

% %Set ind_u = 1 only for the first episode in a job spell
% T.ind_u     = O.ind_u;
% T.Temp      = T.ind_u(2:end);
% T.Temp(T.idnumlead == T.idnumlag & T.idlead == T.idlag) = nan;
% T.ind_u(2:end) = T.Temp;
% 
% %Get the ind_u status of next job spell where available.
% T.NextIndU  = [T.ind_u(2:end);nan];
% T.NextIndU(T.SplFL >= 2) = nan;

end
