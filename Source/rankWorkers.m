function [I] = rankWorkers(M,RD,C,SimO,LU,S,P)
  %Rank workers using different measures as weLU as implement rank aggregation.
  %See user guide/data dictionary for more information.
  
  display('rankWorkers')
  if S.FixSeed(3) > 0
    RandStream.setGlobalStream(RandStream('mcg16807','Seed',S.FixSeed(3)));
  end
  I = RD.I;
  
  %Rank workers using rank aggregation, or if post processing, select the ranking we want to use.
  %Prep that needs to be done regardless.
  
  %At this point. If Post = 0, we just computed everything we wanted.
  %If Post = 1, everything we wanted should be already computed.
  if C.PerfectiRank == 0
    I                       = rankW(I,C,LU,RD.S.SigmaNoise_HatU^2,M,P,SimO);
    I.iNRUse                = I.iNRRankAgg;
    I.rankIn                = I.iNRExpW;
  elseif C.PerfectiRank == 1
    I.iNRUse                = [SimO.iNames,SimO.iNames];
    I.rankIn                = I.iNRUse;
  end
  
  %Figure out by bin percent of misrank in each bin
  %For the input
  for i1 = 1:C.LenGrid
    I.iBinFracGoodRankIn(i1)    = sum(SimO.iNameX(I.rankIn(SimO.iNameX == i1,2)) == i1)./C.NumAgentsSimMult;
    I.iBinFracGoodRankOut(i1)   = sum(SimO.iNameX(I.iNRUse(SimO.iNameX == i1,2)) == i1)./C.NumAgentsSimMult;
  end
  
  %And on the aggregate
  I.CorrectFracIn               = mean(I.iBinFracGoodRankIn);
  I.CorrectFracOut              = mean(I.iBinFracGoodRankOut);
  
  %Bin workers.
  I.iBin                        = binAgents(I.iNRUse,SimO.iNameX);
  
end

function [I] = rankW(I,C,LU,varW,M,P,SimO)
  
  %Make a work directory for this parameterization.
  WorkDir = 1;
  while exist(['Output\',num2str(WorkDir)],'dir') == 7
    %If it exists already, make another.
    WorkDir = WorkDir + 1;
  end
  WorkDir = num2str(WorkDir);
  mkdir(['Output\',WorkDir])
  
  Bla  = sortrows(LU.WFCA,[2 1]);
  fid = fopen(['Output\',WorkDir,'\DontUse.txt'],'w');
  fprintf(fid,'%i\n', zeros(C.NumAgentsSim,1));
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\OrderFID.txt'],'w');
  fprintf(fid,'%i\n', Bla(:,2));
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\OrderWID.txt'],'w');
  fprintf(fid,'%i\n', Bla(:,1));
  fclose(fid);
  % Write to file here:
  fid = fopen(['Output\',WorkDir,'\NITERMAX.txt'],'w');
  fprintf(fid,'%i\n', C.NITERMAX);
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\DistMaxInGlo.txt'],'w');
  fprintf(fid,'%i\n', C.DistMaxInGlo);
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\OMPTHREADS.txt'],'w');
  fprintf(fid,'%i\n', C.OMPTHREADS);
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\ProbDistInc.txt'],'w');
  fprintf(fid,'%20.10f\n', C.ProbDistInc);
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\MovesToSave.txt'],'w');
  fprintf(fid,'%i\n', C.MovesToSave);
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\DispCheck.txt'],'w');
  fprintf(fid,'%i\n', C.DispCheck);
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\DispMove.txt'],'w');
  fprintf(fid,'%i\n', C.DispMove);
  fclose(fid);
  % SizeBI, WAve, WIdxXS,
  fid = fopen(['Output\',WorkDir,'\NumAgentsSim.txt'],'w');
  fprintf(fid,'%i\n', C.NumAgentsSim);
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\SizeBI.txt'],'w');
  fprintf(fid,'%i\n', size(LU.WFCA,1));
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\VarNoise.txt'],'w');
  fprintf(fid,'%20.10f\n', varW);
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\NRAgg.txt'],'w');
  
  ScoreExp  = computeNaiveScore(I.iNRExpW,LU.iAvWageAtFirm);
  ScoreMin  = computeNaiveScore(I.iNRMin,LU.iAvWageAtFirm);
  ScoreMax  = computeNaiveScore(I.iNRMax,LU.iAvWageAtFirm);
  ScoreAdAv = computeNaiveScore(I.iNRAdAv,LU.iAvWageAtFirm);
  
  switch(min([ScoreExp,ScoreMin,ScoreMax,ScoreAdAv]))
    case {ScoreExp}
      Tmp       = sortrows(I.iNRExpW,2);
    case {ScoreMin}
      Tmp       = sortrows(I.iNRMin,2);
    case {ScoreMax}
      Tmp       = sortrows(I.iNRMax,2);
    case {ScoreAdAv}
      Tmp       = sortrows(I.iNRAdAv,2);
  end
  
  fprintf(fid,'%i\n', Tmp(:,1));
  fclose(fid);
  
  [~,wIdxE,~] = unique(LU.WFCA(:,1));
  if numel(wIdxE) < C.NumAgentsSim
    error('Not everyone has wage record')
  end
  wIdxS       = [1;wIdxE(1:end-1) + 1];
  
  fid = fopen(['Output\',WorkDir,'\wIdxS.txt'],'w');
  fprintf(fid,'%i\n', wIdxS);
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\wIdxE.txt'],'w');
  fprintf(fid,'%i\n', wIdxE);
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\eID.txt'],'w');
  fprintf(fid,'%i\n', int32(LU.WFCA(:,2)));
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\WAve.txt'],'w');
  fprintf(fid,'%20.12f\n',LU.WFCA(:,4));
  fclose(fid);
  fid = fopen(['Output\',WorkDir,'\cInv.txt'],'w');
  fprintf(fid,'%20.12f\n',LU.WFCA(:,3));
  fclose(fid);
  
  copyfile('Source\EXE\rankAlgo\x64\Release\rankAlgo.exe',['Output\',WorkDir,'\rankAlgo.exe']);
  
  pause(2)
  cd(['Output\',WorkDir]);
  !rankAlgo.exe
  
  iNRRankAgg = load('NRAgg.txt');
  iNRRankAgg(:,2) = SimO.iNames;
  I.iNRRankAgg    = sortrows(iNRRankAgg,1);
  
  cd ../..
  pause(2)
  eval(['delete Output\',WorkDir,'\*.*']);
  pause(1)
  eval(['delete Output\',WorkDir,'\*.*']);
  pause(1)
  eval(['rmdir Output\',WorkDir]);
  
  I.ScoreRankAgg  = computeNaiveScore(I.iNRRankAgg,LU.iAvWageAtFirm);
  I.ScoreExp      = ScoreExp;
  I.ScoreMin      = ScoreMin;
  I.ScoreMax      = ScoreMax;
  I.ScoreAdAv     = ScoreAdAv;
end
