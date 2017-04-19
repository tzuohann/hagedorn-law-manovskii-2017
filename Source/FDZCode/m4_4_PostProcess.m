function m4_4_PostProcess(StartYear,EndYear,Spec,Header,RootDir,drop)
dbstop if error

fprintf('\n')
disp('-------------------------------------------------------------------')
disp('Running m4_2_doRegMat...')
disp(['StartYear    = ',num2str(StartYear)])
disp(['EndYear      = ',num2str(EndYear)])
disp(['Spec         = ',Spec])
disp(['Header       = ',Header])
disp(['RootDir      = ',RootDir])

fprintf('\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('-------------------------------------------------------------------')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Section 4.4.1: Load data from estimation %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Loading .mat data from m4_3...')
fprintf('\n')
%Load the file produced by m4_3
load([RootDir,'\data\m4_3',Header,num2str(StartYear),num2str(EndYear),'_',Spec,'_',num2str(round(drop * 100)),'.mat']);
Emp                 = 1 - mean(RD.I.iUnE);
RD.Y.MatDenOrig     = RD.Y.MatDen;

%diagonalOutput
RD.Y.Prod           = RD.Y.Prod .* RD.Y.AccSetU;
RD.Y.MatDen         = RD.Y.MatDenOrig.* RD.Y.AccSetU;

%Rescale match densities to match unemployment.
%Equal employment in each firm bin.
EmpShares               = (1 - RD.X.UnEBin);
RD.Y.MatDen             = bsxfun(@times,RD.Y.MatDen,EmpShares./sum(RD.Y.MatDen,2));
RD.Y.MatDen             = RD.Y.MatDen./sum(vec(RD.Y.MatDen))*Emp;

C.LenGrid               = size(RD.Y.Prod,1);
C.AgentSize             = 1/C.LenGrid;
P.Pf                    = 1;
C.Nodes                 = 1000;
SF                      = 1/C.Nodes;
AverageProd             = RD.Y.Prod;

%socialplanner
RD.SP.AggOutput         = nansum(vec(RD.Y.MatDen .* RD.Y.Prod));
[OptimalDen]            = getOptimalMatches('main',RD.Y.MatDen,C,'emp',P)*50;
RD.SP.OMainDiagEmp      = nansum(vec(RD.Y.Prod.*(OptimalDen)));
[OptimalDen]            = getOptimalMatches('main',RD.Y.MatDen,C,'all',P)*50;
RD.SP.OMainDiagAll      = nansum(vec(RD.Y.Prod.*(OptimalDen)));

SFDist                  = sum(RD.Y.MatDen,1)'./sum(RD.Y.MatDen(:))*C.Nodes;
SFDist                  = floor(SFDist) + double(rand(size(SFDist)) < mod(SFDist,1));
SWDist                  = sum(RD.Y.MatDen,2)./sum(RD.Y.MatDen(:))*C.Nodes;
SWDist                  = floor(SWDist) + double(rand(size(SWDist)) < rem(SWDist,1));
[EstWDist,EstFDist]     = DistCorr(SWDist,SFDist,C.Nodes,1);
TempProdT               = -costMatMake(EstWDist,EstFDist,AverageProd);
[OptET,TEMPT]           = lapjv(TempProdT,eps);
GatherET                = makeOptAllImg(EstWDist,EstFDist,C.LenGrid,OptET);
SP.GatherET             = GatherET;
RD.SP.OLAP_TrueEmp      = -(TEMPT)*SF*mean(Emp);
 
FullEmp                 = 1/size(RD.Y.MatDen,1);
MatDen                  = bsxfun(@times,RD.Y.MatDen,FullEmp./sum(RD.Y.MatDen,2));
SFDist                  = sum(MatDen,1)'./sum(MatDen(:))*C.Nodes;
SFDist                  = floor(SFDist) + double(rand(size(SFDist)) < mod(SFDist,1));
SWDist                  = sum(MatDen,2)./sum(MatDen(:))*C.Nodes;
SWDist                  = floor(SWDist) + double(rand(size(SWDist)) < rem(SWDist,1));
[EstWDist,EstFDist]     = DistCorr(SWDist,SFDist,C.Nodes,1);
TempProdT               = -costMatMake(EstWDist,EstFDist,AverageProd);
[OptAT,TEMPT]           = lapjv(TempProdT,eps);
GatherAT                = makeOptAllImg(EstWDist,EstFDist,C.LenGrid,OptAT);
SP.GatherAT             = GatherAT;
RD.SP.OLAP_TrueAll      = -(TEMPT)*SF;
   
RD.SP.EstGain_yxEmp     = (RD.SP.OLAP_TrueEmp - RD.SP.AggOutput)/RD.SP.AggOutput;
RD.SP.EstGain_yxAll     = (RD.SP.OLAP_TrueAll - RD.SP.AggOutput)/RD.SP.AggOutput;
RD.SP.EstGain_DiagEmp   = (RD.SP.OMainDiagEmp - RD.SP.AggOutput)/RD.SP.AggOutput;
RD.SP.EstGain_DiagAll   = (RD.SP.OMainDiagAll - RD.SP.AggOutput)/RD.SP.AggOutput;

% Degree of sorting using our method.
RD.Y.MatDen = RD.Y.MatDen./sum(vec(RD.Y.MatDen));
[WBin,FBin,Den] = find(RD.Y.MatDen);
Den = round(Den*100000);
WF  = zeros(sum(Den),2);
DenIndex  = cumsum(Den);
DenIndexS = [1;DenIndex(1:end - 1) + 1];
for i1 = 1:numel(DenIndex)
    WF(DenIndexS(i1):DenIndex(i1),1) = WBin(i1);
    WF(DenIndexS(i1):DenIndex(i1),2) = FBin(i1);
end
RD.SP.Sorting = corr(WF);
RD.SP.Sorting = RD.SP.Sorting(2);

%save([RootDir,'\data\m4_4',Header,num2str(StartYear),num2str(EndYear),'_',Spec,'_',num2str(round(drop * 100)),'.mat'],'RD','-v7.3');

fprintf('\n')
disp('m4_4_PostProcess.m completed successfully and log closed.')

%Requested output: Wages, Value of Vacancy, Sorting
%and Output Gains

display('Level of Aggregation, Whole Sample');
disp(['Number of workers    : ',num2str(size(Sim.SimWage,1))]);
disp(['Number of firms      : ',num2str(max(Sim.SimJName(:)))]);
disp(['Number of wage obs   : ',num2str(sum(Sim.SimJName(:) > 0))]);
disp(['Number of wage obs U : ',num2str(sum(Sim.SimJName(:) > 0 & Sim.SpellType(:) == 1))]);
display(['Sorting between workers and firms : ', num2str(RD.SP.Sorting)]);
display(['Output Gains from Reallocation(Emp)       : ', num2str(RD.SP.EstGain_yxEmp)]);
display(['Output Gains from Reallocation(All)       : ', num2str(RD.SP.EstGain_yxAll)]);
display(['Output Gains from Reallocation(Emp,Diag)  : ', num2str(RD.SP.EstGain_DiagEmp)]);
display(['Output Gains from Reallocation(All,Diag)  : ', num2str(RD.SP.EstGain_DiagAll)]);

display('Level of Aggregation, Firms');
%The Value of Vacancy is the expected wage premium that a firm pays to
%poach workers from other firms calculated in m4_3. 

% The expected wage premium is the sum of 

% Wage of Worker at Current Firm J - Wage of Worker at Previous Firm(not J)
% weighted over all the workers who move into firm J.

% We calculate this number for all the firms in the LIAB, taking into
% account only worker moves from other LIAB firms. Then, we report the means
% of this number for each 2% of the firms, ie, one mean for the first 2%,
% another for the next 2% and so on. Hence, there are 50 numbers
% altogether. I will put the number of firms in each bin (which is about
% 107) Since each firm has at least 1 worker, the number of unique workers
% is at least 107 as well.
disp(['Number of firms in each bin']);
disp(['There are about 107 firms in each bin']);
disp(['Firm Bin, Number of Firms, Percentage']);
numfirms = tabulate(RD.J.jBin);
disp(' ')
disp('Value of Vacancy');
disp(' ')
disp('Firm Bin (2% each bin) , Number of Estb, Value of Vacancy');
disp(sprintf('%15.2i %20.3i %20.5f\n',[vec(1:C.LenGrid),numfirms(:,2),RD.Y.ValVac]'))

%Unemployment rate of workers, bin by bin
numworkers = tabulate(RD.I.iBin);
disp(' ')
disp('Unemployment rate');
disp(' ')
disp('Worker Bin (2% each bin) , Number of Workers, Unemployment Rate');
disp(sprintf('%15.2i %20.3i %20.5f\n',[vec(1:C.LenGrid),numworkers(:,2),RD.X.UnEBin]'))

display('Level of Aggregation, Worker Firm Cells');
display('Every cell has at least 20 unique worker firm pairs.');
display('I set to NaN the cells that do not fit this criteria');
%Tabulate the number of unique worker firm pairs in each cell
WFInfo = LL.WFCA(LL.WFCA(:,2) < numel(RD.J.EEWageDiff),1:2);
WFTab  = unique(WFInfo,'rows');
WFTab(:,1) = RD.I.iBin(WFTab(:,1));
WFTab(:,2) = RD.J.jBin(WFTab(:,2));
numUniqPairs = full(sparse(WFTab(:,1),WFTab(:,2),1));

%Set to nan the cells that do not fit this creteria, or otherwise, dropped
%from the analysis
numUniqPairs(numUniqPairs < 20) = nan;
numUniqPairs(RD.Y.AccSetU == 0) = nan;

%Display match density where criteria is met
%The match density is the number of months where there is an employment
%relationship that is observed. For example, RD.Y.MatDen(5,5) = 50 means 
%in the data, there were 50 months where worker in Bin 5 were employed at
%firms in Bin 5. The number of unique worker firm relationship in each bin
%is what I used to filter the results.
View = RD.Y.MatDen;
View(isnan(View)) = 0;
View(isnan(numUniqPairs)) = 0;
[WX,FY,MatDen] = find(View);
numUniq      = numUniqPairs(sub2ind(size(numUniqPairs),WX,FY)); 
disp(' ')
disp('Match Density');
disp(' ')
disp('Worker Bin, Firm Bin, Number of Unique W-F Pairs,Average Match Density')
disp(sprintf('%8.2i %8.2i %12.2i %25.10f\n',[WX,FY,numUniq,MatDen]'))

%Display wages where criteria is met
%Wages are simply the average wages that workers in a particular bin earn
%with firms in the corresponding bin. I applied the same censorship
%criteria with number of unique worker firm pairs.
View = RD.Y.Wage;
View(isnan(View)) = 0;
View(isnan(numUniqPairs)) = 0;
[WX,FY,Wage] = find(View);
disp(' ')
disp('Wages');
numUniq      = numUniqPairs(sub2ind(size(numUniqPairs),WX,FY)); 
disp(' ')
disp('Worker Bin, Firm Bin, Number of Unique W-F Pairs,Average Wages')
disp(sprintf('%8.2i %8.2i %12.2i %25.10f\n',[WX,FY,numUniq,Wage]'))

%Display wages out of unemployment where criteria is met
View = RD.Y.WageU;
View(isnan(View)) = 0;
View(isnan(View)) = 0;
View(isnan(numUniqPairs)) = 0;
[WX,FY,WageU] = find(View);
numUniq      = numUniqPairs(sub2ind(size(numUniqPairs),WX,FY)); 
disp(' ')
disp('Wages out of Unemployment');
disp(' ')
disp('Worker Bin, Firm Bin, Number of Unique W-F Pairs,Average Wages Out of Unemployment')
disp(sprintf('%8.2i %8.2i %12.2i %25.10f\n',[WX,FY,numUniq,WageU]'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('-------------------------------------------------------------------')

fprintf('\n')
disp('m4_4_PostProcess.m completed successfully and log closed.')

% End logging or return to keyboard
fclose(fopen([RootDir,'\log\done.done'],'w+'));
exit
end
