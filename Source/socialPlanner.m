function SP  = socialPlanner(C,M,SimO,RD,S,P,Sim)
  display('socialPlanner')
  if S.FixSeed(4) > 0
    RandStream.setGlobalStream(RandStream('mcg16807','Seed',S.FixSeed(4)));
  end
  SP = RD.SP;
  if any(C.Nodes < C.LenGrid);
    warning('LAP not run. Nodes < LenGrid')
  else
    
%     ProdUse                   = prodAdjust(RD.Y.Prod,M.AverageProd,RD.Y.MatDen,sum(M.MatDen,3));
    ProdUse                   = RD.Y.Prod;
    
    SF                        = 1/C.Nodes;
    MatDenSim                 = sum(SimO.MatDenSim,3);
    AverageProd               = nansum(M.Prod.*SimO.MatDenSim,3)./sum(SimO.MatDenSim,3);

    % Moving employed people only.
    %Set up and solve the LAP on true model
    disp('LAP:Employed True')
    SWDist                  = sum(MatDenSim,2)./sum(MatDenSim(:))*C.Nodes;
    SWDist                  = floor(SWDist) + double(rand(size(SWDist)) < mod(SWDist,1));
    SFDist                  = sum(MatDenSim,1)'./sum(MatDenSim(:))*C.Nodes;
    SFDist                  = floor(SFDist) + double(rand(size(SFDist)) < rem(SFDist,1));
    [EstWDist,EstFDist]     = DistCorr(SWDist,SFDist,C.Nodes,1);
    TempProdT               = -costMatMake(EstWDist,EstFDist,AverageProd);
    [OptET,TEMPT]           = lapjv(TempProdT,eps);
    GatherET                = makeOptAllImg(EstWDist,EstFDist,C.LenGrid,OptET);
    SP.GatherET             = GatherET;
    SP.OLAP_TrueEmp         = -(TEMPT)*SF*mean(SimO.Emp);
    
    %Set up and solve the LAP on yx
    disp('LAP:Employed Est')
    SWDist                  = (1 - RD.X.UnEBin)/sum(1 - RD.X.UnEBin)*C.Nodes;
    SWDist                  = floor(SWDist) + double(rand(size(SWDist)) < mod(SWDist,1));
    SFDist                  = RD.Y.EmpShare*mean(SimO.Emp)*C.Nodes;
    SFDist                  = floor(SFDist) + double(rand(size(SFDist)) < rem(SFDist,1));
    [EstWDist,EstFDist]     = DistCorr(SWDist,SFDist,C.Nodes,1);
    TempProdE               = -costMatMake(EstWDist,EstFDist,ProdUse);
    [OptEE,TEMPE]           = lapjv(TempProdE,eps);
    GatherEE                = makeOptAllImg(EstWDist,EstFDist,C.LenGrid,OptEE);
    SP.GatherEE             = GatherEE;
    SP.OLAP_HatYEmp         = -(TEMPE)*SF*mean(SimO.Emp);
    
    % Moving all people.
    %Set up and solve the LAP on true model
    disp('LAP:All True')
    C.Nodes                 = C.LenGrid;
    SF                      = 1/C.Nodes;
    SWDist                  = ones(C.LenGrid,1);
    SFDist                  = ones(C.LenGrid,1);
    TempProdT               = -costMatMake(SWDist,SFDist,AverageProd);
    [OptAT,TEMP]            = lapjv(TempProdT,eps);
    GatherAT                = makeOptAllImg(SWDist,SFDist,C.LenGrid,OptAT);    
    SP.GatherAT             = GatherAT;
    SP.OLAP_TrueAll         = -(TEMP)*SF;
    
    %Set up and solve the LAP on yx
    disp('LAP:All Est')
    TempProdE               = -costMatMake(SWDist,SFDist,ProdUse);
    [OptAE,TEMP]            = lapjv(TempProdE,eps);
    GatherAE                = makeOptAllImg(SWDist,SFDist,C.LenGrid,OptAE);    
    SP.GatherAE             = GatherAE;
    SP.OLAP_HatYAll         = -(TEMP)*SF;
    
    
    SP.TrueGainEmp          = (SP.OLAP_TrueEmp - SP.OTrueSim)./SP.OTrueSim;
    SP.EstGain_yxEmp        = (SP.OLAP_HatYEmp - SP.OTrueSim)/SP.OTrueSim;
    SP.TrueGainAll          = (SP.OLAP_TrueAll - SP.OTrueSim)/SP.OTrueSim;
    SP.EstGain_yxAll        = (SP.OLAP_HatYAll - SP.OTrueSim)/SP.OTrueSim;
    
    %Now we want to know much much gain is actually acheived from moving
    %people.
    %From moving everyone.
%     disp('Realized Gain')
%     SP.RealGainA      = getRealizedGain(SP.TrueOutput,M.AverageProd,GatherAE,RD.I.iBin,C,RD.J.jBin,1,SimO);
%     SP.RealGainE      = getRealizedGain(SP.TrueOutput,M.AverageProd,GatherEE,RD.I.iBin,C,RD.J.jBin,mean(SimO.Emp),SimO);
  end
end

function CostMat = costMatMake(SWDist,SFDist,Prod)
  CostMat           = zeros(sum(SWDist),sum(SFDist));
  WIndex            = 0;
  for ix  = 1:size(SWDist,1)
    FIndex            = 0;
    for iy = 1:size(SFDist,1)
      for ixx = 1:SWDist(ix)
        CostMat(WIndex + ixx,(FIndex + 1):(FIndex + SFDist(iy))) = Prod(ix,iy);
      end
      FIndex = FIndex + SFDist(iy);
    end
    WIndex = WIndex + SWDist(ix);
  end
  CostMat(isnan(CostMat)) = 0;
end
