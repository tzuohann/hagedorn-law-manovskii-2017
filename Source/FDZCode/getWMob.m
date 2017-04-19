function J = getWMob(C,SimO,RD,Sim)
%Author: Tzuo Hann Law (tzuohann@gmail.com)

display('getWMob')

%Workers that a firm hires from the complete history.
%   HWN = L.HiredWorkerName;

SimO.Numj         = max(vec(Sim.SimJName));

Start             = 2;
Inc               = 1;
PeriodsObs        = Start:Inc:C.Periods;
FirmSize          = zeros(SimO.Numj,C.Periods - 1);
NNHUFull          = zeros(SimO.Numj,C.Periods - 1);
NNHEFull          = zeros(SimO.Numj,C.Periods - 1);
NLWEFull          = zeros(SimO.Numj,C.Periods - 1);
AccSetEMob        = zeros(C.LenGrid,SimO.Numj,SimO.Numj);

for iw = 1:size(Sim.SimJName,1)
    iBinW  = RD.I.iBin(iw);
    for it = PeriodsObs
        if Sim.SimJName(iw,it) > 0
            iy      = Sim.SimJName(iw,it);
            iyPrev  = Sim.SimJName(iw,it-1);
            FirmSize(iy,it - 1) = FirmSize(iy,it - 1) + 1;
            if iyPrev == iy
            elseif iyPrev == 0
                NNHUFull(iy,it - 1)   = NNHUFull(iy,it - 1) + 1;
            elseif iyPrev ~= iy
                NNHEFull(iy,it - 1)   = NNHEFull(iy,it - 1) + 1;
                %Record AccSetEMob for LIAB firms only
                if iyPrev > 0
                    NLWEFull(iyPrev,it - 1)   = NLWEFull(iyPrev,it - 1) + 1;
                    AccSetEMob(iBinW,iyPrev,iy) = AccSetEMob(iBinW,iyPrev,iy) + 1;
                end                                
            end
        end
    end
end
J.EmpShare        = sum(FirmSize,2)/sum(vec(FirmSize));
FirmSize(FirmSize == 0) = nan;
J.FirmSize        = FirmSize;
%J.jVacs           = bsxfun(@minus,SimO.FirmSize,FirmSize);
J.NNHUFull        = NNHUFull;
J.NNHEFull        = NNHEFull;
% J.VacsFull        = VacsFull;
J.AccSetEMob      = AccSetEMob;
J.NLWEFull        = NLWEFull;

end
