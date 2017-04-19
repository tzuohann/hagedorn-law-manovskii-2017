% Finds connected set of firms by looking at worker moves between firms

function O = getConnectedSet(O)

T               = prepMobility(O);
T.idnumlead     = [T.idnumlead;nan];
T.idnumcon      = [O.idnum,T.idnumlead];
%Last one carries no information. Same for 1 obs.
T.idnumcon      = T.idnumcon(T.SplFL < 2,:);
T.idnumcon      = unique(T.idnumcon(T.idnumcon(:,1) ~= T.idnumcon(:,2),:),'rows');

%FIND CONNECTED SET
maxsize     = max(max(O.id),max(O.idnum));
disp('Finding connected set...')
T.A = logical(sparse(T.idnumcon(:,1),T.idnumcon(:,2),1,maxsize,maxsize)); %adjacency matrix
T.A = (T.A+T.A') > 0; %connections are undirected

[T.sindex, T.sz]=components(T.A); %get connected sets

T.idx = find(T.sz==max(T.sz)); %find largest set

clear A
T.firmlst=find(T.sindex==T.idx); %firms in connected set
disp(['Obs in largest connected set ',num2str(mean(ismember(O.idnum,T.firmlst)))]);
disp(['Firms in largest connected set ',num2str((numel(T.firmlst)))]);
T.Sample = ismember(O.idnum,T.firmlst);
for ifield = fieldnames(O)'
    eval(['O.',ifield{1},'=','O.',ifield{1},'(T.Sample);']);
end
end
