function [jxAccSetE,Cutoff] = getAccSetEY(RD,C,Sim,NumjY,iDropped)
% jxAccSetE = getAccSetE(RD,C,SimO,M,Sim,P,NumjY,JobGroup,iDropped)
% Compute the average wage difference for firms.
% Check difference between wages at firms using information about
% variance.
disp('getAccSetE')

%For each firm, look at wages out of unemployment of workers who are
%currently employed with the firm less their wage when they were working
%elsewhere (again out of unemployment)

% SimjName                        = recodeAs(Sim.SimJobName,JobGroup);
SimWage                         = Sim.SimWage;
% SimWage(Sim.SimInitJob ~= 0)    = nan;
% SimjName(Sim.SimInitJob ~= 0)   = 0;

NumelWage         = zeros(C.LenGrid,NumjY);
VarWage           = zeros(C.LenGrid,NumjY);
MeanWage          = zeros(C.LenGrid,NumjY);
for ix = 1:C.LenGrid
    WageX   = vec(SimWage(RD.I.iBin == ix & iDropped == 0 ,:));
    FirmX   = vec(Sim.SimJName(RD.I.iBin == ix & iDropped == 0,:));
    for ijO = 1:NumjY
        Temp                = FirmX == ijO;
        NumelWage(ix,ijO)   = sum(Temp);
        if NumelWage(ix,ijO) > 0
            VarWage(ix,ijO)     = var(WageX(Temp));
            MeanWage(ix,ijO)    = mean(WageX(Temp));
        end
    end
end

Cutoff            = 0.7;
jxAccSetE         = zeros(C.LenGrid,NumjY,NumjY,numel(Cutoff));

for ix = 1:C.LenGrid
    for ijO = 1:NumjY
        if NumelWage(ix,ijO) > 0
            Temp                    = (MeanWage(ix,:) - MeanWage(ix,ijO))./sqrt(VarWage(ix,:)./NumelWage(ix,:) + VarWage(ix,ijO)/NumelWage(ix,ijO));
            Temp                    = normcdf(Temp);
            for ic = 1:numel(Cutoff)
                jxAccSetE(ix,ijO,:,ic)   = Temp > Cutoff(ic);
            end
        end
    end
end

% jxAccSetEMob  = RD.J.AccSetEMob;
% jxAccSetEMob  = max(jxAccSetEMob - permute(jxAccSetEMob,[1 3 2]),0);
% jxHasMob      = RD.J.AccSetEMob > 0 | permute(RD.J.AccSetEMob,[1 3 2]) > 0;
% 
% NumGoods      = zeros(numel(Cutoff),1);
% jxAccSetEMob  = vec(jxAccSetEMob);
% for ic = 1:numel(Cutoff)
%     Temp           = vec(jxAccSetE(:,:,:,ic));
%     NumGoods(ic)   =  sum(Temp(jxHasMob) == jxAccSetEMob(jxHasMob));
% end
% 
% [~,BestLoc] = max(NumGoods);
% Cutoff      = Cutoff(BestLoc);
% jxAccSetE   = jxAccSetE(:,:,:,BestLoc);

% jxHasMob    = jxAccSetEMob > 0 | permute(jxAccSetEMob,[1 3 2]) > 0;
% jxAccSetE(jxHasMob) = jxAccSetEMob(jxHasMob);
end

