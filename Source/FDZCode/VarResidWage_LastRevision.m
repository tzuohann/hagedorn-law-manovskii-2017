[IName,T]       = find(Sim.SimJName > 0);
[WageLevel]     = Sim.SimWage(sub2ind(size(Sim.SimWage),IName,T));
JName           = Sim.SimJName(sub2ind(size(Sim.SimWage),IName,T));
IType           = RD.I.iBin(IName);
JType           = RD.J.jBin(JName);
RD.Y.Wage(RD.Y.AccSetU == 0) = nan;
WageModelBin    = RD.Y.Wage(sub2ind([50,50],IType,JType));
Resid           = WageLevel - WageModelBin;
ResidLog        = log(WageLevel) - log(WageModelBin);
idx             = ~isnan(Resid) & ~isnan(ResidLog);
Resid           = Resid(idx);
ResidLog        = ResidLog(idx);
IType           = IType(idx);
JType           = JType(idx);
VarLevel        = nan(50,50);
VarLog          = nan(50,50);
for i1 = 1:50
    for i2 = 1:50
        idx = IType == i1 & JType == i2;
        if any(idx)
            VarLevel(i1,i2)    = var(Resid(idx));
            VarLog(i1,i2)      = var(ResidLog(idx));
        end
    end
end
%Averaging the variance by cell type.
VarLog2 = nan(10,10);
for i1 = 1:10
    for i2 = 1:10
        VarLog2(i1,i2) = nanmean(nanmean(VarLog((i1-1)*5 + 1 : i1*5,(i2-1)*5 + 1 : i2*5)));
    end
end
VarLog2(isnan(VarLog2)) = 0;
VarLog(isnan(VarLog)) = 0;
VarLevel(isnan(VarLevel)) = 0;
[a,b,c] = find(nanmax(VarLevel./RD.Y.Wage,0))
[B,BINT] = regress(c,[ones(size(a)),a,b,a.*b],0.01);
B
BINT
[B,BINT] = regress(c,[ones(size(a)),a,b],0.01);
B
BINT