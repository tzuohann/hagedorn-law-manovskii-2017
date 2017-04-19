%% ProductionFunctionError_Appendix
iplot = 0;
for ispec = {'benchmark','ojs','matchquality','highbeta','shortsample','smallfirms'}
  Bla = dir(['Output\',ispec{1},'\']);
  ProdError.(ispec{1}).AbsDiff_Prod       = zeros(50,50,108);
  ProdError.(ispec{1}).AbsDiff            = zeros(50,50,108);
  ProdError.(ispec{1}).AbsDiff_AvgProd    = zeros(50,50,108);
  ProdError.(ispec{1}).AvgWtDiff_AvgProd  = zeros(108,1);
  ProdError.(ispec{1}).AvgDiff_AvgProd    = zeros(108,1);
  iparam = 0;
  for iout = 4:numel(Bla)
    iparam = iparam + 1;
    load(['Output\',ispec{1},'\',Bla(iout).name],'M','RD');
    AbsDiff                             = abs(M.AverageProd - RD.Y.Prod);
    AvgDiff                             = nanmean(vec(abs(M.AverageProd - RD.Y.Prod)));
    AvgWtDiff                           = nansum(vec(abs(M.AverageProd - RD.Y.Prod).*sum(M.MatDen,3)))./nansum(vec(sum(M.MatDen,3)));
    AvgProd                             = nansum(vec(abs(M.AverageProd).*sum(M.MatDen,3)))./nansum(vec(sum(M.MatDen,3)));
    Filter                              = ~isnan(M.AverageProd) & ~isnan(RD.Y.Prod);
    TotSS                               = nansum(vec(((M.AverageProd - AvgProd).^2.*sum(M.MatDen,3)).*Filter));
    ResSS                               = nansum(vec(((M.AverageProd - RD.Y.Prod).^2.*sum(M.MatDen,3)).*Filter));
    ProdError.(ispec{1}).AbsDiff_Prod(:,:,iparam)                     = AbsDiff./M.AverageProd;
    ProdError.(ispec{1}).AbsDiff(:,:,iparam)                          = AbsDiff;
    ProdError.(ispec{1}).AbsDiff_AvgProd(:,:,iparam)                  = AbsDiff./AvgProd;
    ProdError.(ispec{1}).AvgWtDiff_AvgProd(iparam,1)                  = AvgWtDiff./AvgProd;
    ProdError.(ispec{1}).AvgDiff_AvgProd(iparam,1)                    = AvgDiff./AvgProd;
    ProdError.(ispec{1}).R2(iparam,1)                                 = 1 - ResSS/TotSS;
  end
end

save ProdError.mat ProdError