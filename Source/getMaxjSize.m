function MaxjSize = getMaxjSize(C,SimO,P,AccRateU,AccRateE,MVCU,MVCE,FirmSize,NLWEFull)
  %Estimate maximum size of the firm
  disp('getMaxjSize')
  if C.PerfectMaxjSize || C.UseVacs == 1
    MaxjSize          = SimO.FirmSize;
  else
    MeanFirmSize      = mean(FirmSize,2);
    ReturnVac         = (1-P.Ddelta)*(MVCU*AccRateU + MVCE*AccRateE);
    %Need to also account for probability of moving to a different firm.
    VacsToMaintain    = (P.Ddelta * MeanFirmSize + mean(NLWEFull,2)) ./ ReturnVac;
    MaxjSize          = MeanFirmSize + VacsToMaintain;
    % Scale so that it equals to the P.Pf which we assume we know.
    MaxjSize          = MaxjSize/(sum(MaxjSize)/(P.Pf*C.NumAgentsSim));
  end
end
