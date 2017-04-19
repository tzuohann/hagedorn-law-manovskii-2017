clear
load Output\benchmark\Data.mat
%% Worker ranking correlation, Rank Aggregation Only
MinLB                 = 1;
LB                    = 0.96;
UB                    = 1;
HistCell              = 15;
MaxCount              = 0;
XFontSize             = 20;
AxisLim               = [0.96 1.002 0 80];
F1 = figure;
set(F1,'Name','WorkerSortingRAPNN')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')
Vec2Hist = RDFS_WCorrUse;
MinLB = min(MinLB,min(Vec2Hist));
MinLB = min(MinLB,min(Vec2Hist));
BBB = histc(Vec2Hist,[-inf,linspace(LB,UB,HistCell)]);
MaxCount = max(MaxCount,max(BBB));
bar(linspace(LB,UB,HistCell),BBB(1:end-1))
xlabel('Correlation','fontsize',XFontSize)
set(gca,'FontSize',XFontSize)
axis(AxisLim)

%% Firm ranking correlation, Rank Aggregation Only
MinLB                 = 1;
LB                    = 0.97;
UB                    = 1;
HistCell              = 15;
MaxCount              = 0;
XFontSize             = 20;
AxisLim               = [0.97 1.0015 0 40];
F1 = figure;
set(F1,'Name','FirmSorting')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')
Vec2Hist = RDFS_FCorr;
MinLB = min(MinLB,min(Vec2Hist));
MinLB = min(MinLB,min(Vec2Hist));
BBB = histc(Vec2Hist,[-inf,linspace(LB,UB,HistCell)]);
MaxCount = max(MaxCount,max(BBB));
bar(linspace(LB,UB,HistCell),BBB(1:end-1))
xlabel('Correlation','fontsize',XFontSize)
set(gca,'FontSize',XFontSize)
axis(AxisLim)

%% WF True and Estimated Sorting
LB            = -1;
UB            = 1;
LBY           = -1;
UBY           = 1;
FontSize      = 20;
TickMark      = 6;
F1 = figure;
set(F1,'Name','WorkerFirmSorting3Panel')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')
WidthX = 0;
WidthY = 0;
subplot(1,3,1)
Group = ProdName == 1 ;
Width     = max(RDFS_WFTrueCorr(Group,1)) - min(RDFS_WFTrueCorr(Group,1));
WidthX    = max(WidthX,Width);
CenterX1  = (max(RDFS_WFTrueCorr(Group,1)) + min(RDFS_WFTrueCorr(Group,1)))/2;
Width     = max([RDFS_WFEstCorr(Group,1);RDAKM_RankCorr(Group,1)]) - min([RDFS_WFEstCorr(Group,1);RDAKM_RankCorr(Group,1)]);
WidthY    = max(WidthY,Width);
CenterY1  = (max([RDFS_WFEstCorr(Group,1);RDAKM_RankCorr(Group,1)]) + min([RDFS_WFEstCorr(Group,1);RDAKM_RankCorr(Group,1)]))/2;
plot(RDFS_WFTrueCorr(Group,1),RDFS_WFEstCorr(Group,1),'k.','markersize',14)
hold on
plot(RDFS_WFTrueCorr(Group,1),RDAKM_RankCorr(Group,1),'r+','markersize',TickMark,'linewidth',2)
plot(linspace(-1,1,100),linspace(-1,1,100),'-','linewidth',1.5,'Color',[.6 0.6 0.6])
plot(RDFS_WFTrueCorr(Group,1),RDFS_WFEstCorr(Group,1),'k.','markersize',14)
plot(RDFS_WFTrueCorr(Group,1),RDAKM_RankCorr(Group,1),'r+','markersize',TickMark)
ylabel('Estimated worker-firm type rank correlation','fontsize',FontSize)
title('PAM','fontsize',FontSize)
set(gca,'FontSize',FontSize)
hold off
subplot(1,3,2)
Group = ProdName == 2 ;
Width     = max(RDFS_WFTrueCorr(Group,1)) - min(RDFS_WFTrueCorr(Group,1));
WidthX    = max(WidthX,Width);
CenterX2  = (max(RDFS_WFTrueCorr(Group,1)) + min(RDFS_WFTrueCorr(Group,1)))/2;
Width     = max([RDFS_WFEstCorr(Group,1);RDAKM_RankCorr(Group,1)]) - min([RDFS_WFEstCorr(Group,1);RDAKM_RankCorr(Group,1)]);
WidthY    = max(WidthY,Width);
CenterY2  = (max([RDFS_WFEstCorr(Group,1);RDAKM_RankCorr(Group,1)]) + min([RDFS_WFEstCorr(Group,1);RDAKM_RankCorr(Group,1)]))/2;
plot(RDFS_WFTrueCorr(Group,1),RDFS_WFEstCorr(Group,1),'k.','markersize',14)
hold on
plot(RDFS_WFTrueCorr(Group,1),RDAKM_RankCorr(Group,1),'r+','markersize',TickMark,'linewidth',2)
plot(linspace(-1,1,100),linspace(-1,1,100),'-','linewidth',1.5,'Color',[.6 0.6 0.6])
plot(RDFS_WFTrueCorr(Group,1),RDFS_WFEstCorr(Group,1),'k.','markersize',14)
plot(RDFS_WFTrueCorr(Group,1),RDAKM_RankCorr(Group,1),'r+','markersize',TickMark)
ylabel('Estimated worker-firm type rank correlation','fontsize',FontSize)
title('NAM','fontsize',FontSize)
set(gca,'FontSize',FontSize)
hold off
subplot(1,3,3)
Group = ProdName == 3 ;
Width     = max(RDFS_WFTrueCorr(Group,1)) - min(RDFS_WFTrueCorr(Group,1));
WidthX    = max(WidthX,Width);
CenterX3  = (max(RDFS_WFTrueCorr(Group,1)) + min(RDFS_WFTrueCorr(Group,1)))/2;
Width     = max([RDFS_WFEstCorr(Group,1);RDAKM_RankCorr(Group,1)]) - min([RDFS_WFEstCorr(Group,1);RDAKM_RankCorr(Group,1)]);
WidthY    = max(WidthY,Width);
CenterY3  = (max([RDFS_WFEstCorr(Group,1);RDAKM_RankCorr(Group,1)]) + min([RDFS_WFEstCorr(Group,1);RDAKM_RankCorr(Group,1)]))/2;
plot(RDFS_WFTrueCorr(Group,1),RDFS_WFEstCorr(Group,1),'k.','markersize',14)
hold on
plot(RDFS_WFTrueCorr(Group,1),RDAKM_RankCorr(Group,1),'r+','markersize',TickMark,'linewidth',2)
plot(linspace(-1,1,100),linspace(-1,1,100),'-','linewidth',1.5,'Color',[.6 0.6 0.6])
plot(RDFS_WFTrueCorr(Group,1),RDFS_WFEstCorr(Group,1),'k.','markersize',14)
plot(RDFS_WFTrueCorr(Group,1),RDAKM_RankCorr(Group,1),'r+','markersize',TickMark)
ylabel('Estimated worker-firm type rank correlation','fontsize',FontSize)
title('NEITHER','fontsize',FontSize)
set(gca,'FontSize',FontSize)
hold off
subplot(1,3,1)
axis([CenterX1 - 1.1*WidthX/2,CenterX1 + 1.1*WidthX/2,CenterY1 - 1.1*WidthY/2,CenterY1 + 1.1*WidthY/2])
subplot(1,3,2)
axis([CenterX2 - 1.1*WidthX/2,CenterX2 + 1.1*WidthX/2,CenterY2 - 1.1*WidthY/2,CenterY2 + 1.1*WidthY/2])
subplot(1,3,3)
axis([CenterX3 - 1.1*WidthX/2,CenterX3 + 1.1*WidthX/2,CenterY3 - 1.1*WidthY/2,CenterY3 + 1.1*WidthY/2])

%% RDY_OCorrMZ
MinLB                 = 1;
LB                    = 0.99;
UB                    = 1;
HistCell              = 6;
MaxCount              = 0;
FontSize              = 15;
AxisLim               = [0.97 1.002 0 90];
F1 = figure;
set(F1,'Name','RDY_OCorrMZ')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')
Vec2Hist = RDY_OCorrMZ;
BBB = histc(Vec2Hist,[-inf,linspace(min(Vec2Hist),max(Vec2Hist),HistCell)]);
XTicks = linspace(min(Vec2Hist),max(Vec2Hist),HistCell);
bar(XTicks,BBB(1:end-1))
xlabel('Correlation','fontsize',FontSize)
set(gca,'FontSize',FontSize)
set(gca,'FontSize',FontSize)
axis(AxisLim)

%% Output losses all
FontSize              = 20;
F1                    = figure;
set(F1,'Name','OutputLossesAllPNN')
Group = ProdName < 4;
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')
plot(linspace(0,0.995,100),linspace(0.005,1,100),'k--','linewidth',1.5,'Color',[.6 0.6 0.6])
hold on
legend({'0.5% Bound'},'FontSize',FontSize,'Location','southeast');
plot(linspace(0,1,100),linspace(0,1,100),'k-','linewidth',1.5,'Color',[.6 0.6 0.6])
plot(linspace(0.005,1,100),linspace(0,0.995,100),'k--','linewidth',1.5,'Color',[.6 0.6 0.6])
plot(RDSP_TrueGainAll(Group,1),RDSP_EstGain_yxAll(Group,1),'k.','markersize',20)
axis([0.95*min([RDSP_TrueGainAll;RDSP_EstGain_yxAll]) 1.05*max([RDSP_TrueGainAll;RDSP_EstGain_yxAll]) 0.95*min([RDSP_TrueGainAll;RDSP_EstGain_yxAll]) 1.05*max([RDSP_TrueGainAll;RDSP_EstGain_yxAll])])
set(gca,'XTickLabel',100*get(gca,'XTick'))
set(gca,'YTickLabel',100*get(gca,'YTick'))
set(gca,'FontSize',FontSize)
hold off
ylabel('Estimated Output Percent Gain','fontsize',FontSize)
xlabel('True Output Percent Gain','fontsize',FontSize)


%% Output losses employed only
FontSize              = 20;
F1 = figure;
set(F1,'Name','OutputLossesEmployedOnlyPNN')
Group = ProdName < 4;
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')
plot(linspace(0,0.995,100),linspace(0.005,1,100),'k--','linewidth',1.5,'Color',[.6 0.6 0.6])
hold on
legend({'0.5% Bound'},'FontSize',FontSize,'Location','southeast');
plot(linspace(0,1,100),linspace(0,1,100),'k-','linewidth',1.5,'Color',[.6 0.6 0.6])
plot(linspace(0.005,1,100),linspace(0,0.995,100),'k--','linewidth',1.5,'Color',[.6 0.6 0.6])
plot(RDSP_TrueGainEmp(Group,1),RDSP_EstGain_yxEmp(Group,1),'k.','markersize',20)
axis([0.95*min([RDSP_TrueGainEmp;RDSP_EstGain_yxEmp]) 1.05*max([RDSP_TrueGainEmp;RDSP_EstGain_yxEmp]) 0.95*min([RDSP_TrueGainEmp;RDSP_EstGain_yxEmp]) 1.05*max([RDSP_TrueGainEmp;RDSP_EstGain_yxEmp])])
set(gca,'XTickLabel',100*get(gca,'XTick'))
set(gca,'YTickLabel',100*get(gca,'YTick'))
set(gca,'FontSize',FontSize)
hold off
ylabel('Estimated Output Percent Gain','fontsize',FontSize)
xlabel('True Output Percent Gain','fontsize',FontSize)

%% JobFindingRatePNN
HistCell = 15;
FontSize = 35;
Group = ismember(ProdName,1:3);
F1 = figure;
set(F1,'Name','JobFindingRate')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')
if any(Group)
  Vec2Hist = M_UERate(Group);
  BBB = histc(Vec2Hist,[-inf,linspace(min(Vec2Hist),max(Vec2Hist),HistCell),inf]);
  XTicks = linspace(min(Vec2Hist),max(Vec2Hist),HistCell);
  bar(XTicks,BBB(2:end-1))
  axis([min(Vec2Hist) - 0.65*(XTicks(2) - XTicks(1)),max(Vec2Hist) + 0.65*(XTicks(2) - XTicks(1)),0, max(BBB(2:end-1)) + 0.1])
  xlabel('Job finding rate','fontsize',FontSize)
  set(gca,'FontSize',FontSize)
end

%% UnemploymentPNN
Group = ismember(ProdName,1:3);
F1 = figure;
set(F1,'Name','Unemployment')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')

if any(Group)
  Vec2Hist = M_UnE(Group);
  
  BBB = histc(Vec2Hist,[-inf,linspace(min(Vec2Hist),max(Vec2Hist),HistCell),inf]);
  XTicks = linspace(min(Vec2Hist),max(Vec2Hist),HistCell);
  bar(XTicks,BBB(2:end-1))
  axis([min(Vec2Hist) - 0.65*(XTicks(2) - XTicks(1)),max(Vec2Hist) + 0.65*(XTicks(2) - XTicks(1)),0, max(BBB(2:end-1)) + 0.1])
  xlabel('Unemployment','fontsize',FontSize)
  set(gca,'FontSize',FontSize)
end

%% VarianceLogWagesPNN
Group = ismember(ProdName,1:3);
F1 = figure;
set(F1,'Name','VarianceLogWages')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')
if any(Group)
  Vec2Hist = SimO_NewVarLog(Group);
  BBB = histc(Vec2Hist,[-inf,linspace(min(Vec2Hist),max(Vec2Hist),HistCell),inf]);
  XTicks = linspace(min(Vec2Hist),max(Vec2Hist),HistCell);
  bar(XTicks,BBB(2:end-1))
  axis([min(Vec2Hist) - 0.65*(XTicks(2) - XTicks(1)),max(Vec2Hist) + 0.65*(XTicks(2) - XTicks(1)),0, max(BBB(2:end-1)) + 0.1])
  xlabel('Variance log(Wages)','fontsize',FontSize)
  set(gca,'FontSize',FontSize)
end

%% Rank Minimum
MinLB                 = 1;
LB                    = 0.96;
UB                    = 1;
HistCell              = 15;
MaxCount              = 0;
XFontSize             = 35;
AxisLim               = [0.96 1.002 0 30];
F1 = figure;
set(F1,'Name','WorkerSortingMinPNN')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')
Vec2Hist = RDFS_WCorrMin;
MinLB = min(MinLB,min(Vec2Hist));
MinLB = min(MinLB,min(Vec2Hist));
BBB = histc(Vec2Hist,[-inf,linspace(LB,UB,HistCell)]);
MaxCount = max(MaxCount,max(BBB));
bar(linspace(LB,UB,HistCell),BBB(1:end-1))
xlabel('Correlation','fontsize',XFontSize)
set(gca,'FontSize',XFontSize)
axis(AxisLim)

%% Rank Maximum
MinLB                 = 1;
LB                    = 0.96;
UB                    = 1;
HistCell              = 15;
MaxCount              = 0;
XFontSize             = 35;
AxisLim               = [0.96 1.002 0 30];
F1 = figure;
set(F1,'Name','WorkerSortingMaxPNN')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')
Vec2Hist = RDFS_WCorrMax;
MinLB = min(MinLB,min(Vec2Hist));
MinLB = min(MinLB,min(Vec2Hist));
BBB = histc(Vec2Hist,[-inf,linspace(LB,UB,HistCell)]);
MaxCount = max(MaxCount,max(BBB));
bar(linspace(LB,UB,HistCell),BBB(1:end-1))
xlabel('Correlation','fontsize',XFontSize)
set(gca,'FontSize',XFontSize)
axis(AxisLim)

%% Rank AdAv
MinLB                 = 1;
LB                    = 0.96;
UB                    = 1;
HistCell              = 15;
MaxCount              = 0;
XFontSize             = 35;
AxisLim               = [0.96 1.002 0 30];
F1 = figure;
set(F1,'Name','WorkerSortingAdAvPNN')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')
Vec2Hist = RDFS_WCorrAdAv;
MinLB = min(MinLB,min(Vec2Hist));
MinLB = min(MinLB,min(Vec2Hist));
BBB = histc(Vec2Hist,[-inf,linspace(LB,UB,HistCell)]);
MaxCount = max(MaxCount,max(BBB));
bar(linspace(LB,UB,HistCell),BBB(1:end-1))
xlabel('Correlation','fontsize',XFontSize)
set(gca,'FontSize',XFontSize)
axis(AxisLim)

%% PAM
fileName = dir('Output\benchmark\benchmark_pam_000007_*.mat');
load(['Output\benchmark\',fileName.name])
display('*****PAM********')

F1 = figure;
set(F1,'Name','PAMProd')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')

for i1 = 1:4
  subplot(2,2,i1)
  surf(C.Grid,C.Grid,M.Prod','CData',10*ones(size(M.Prod')),'FaceAlpha',0.75)
  hold on
  ProdHat = RD.Y.Prod;
  surf(C.Grid,C.Grid,ProdHat','linestyle','none','FaceAlpha',0.5)
  set(gca,'FontSize',16)
  if i1 == 1
    view(-45,10)
    title('Top')
  elseif i1 == 2
    view(-45-180,10)
    title('Under')
  elseif i1 == 3
    view(-100,10)
    title('Side-Top')
  else
    view(100,10)
    title('Side-Under')
  end
  xlabel('x')
  ylabel('y')
  zlabel('f(x,y)')
  Li = line([1 0],[1 0],[nanmin(vec(C.Prod)) nanmax(vec(C.Prod))]);
  set(Li,'Color','r');
  set(Li,'LineWidth',2);
  axis([0 1 0 1 nanmin(vec(C.Prod)) nanmax(vec(C.Prod))]);
  hold off
end

set(gca,'LooseInset',get(gca,'TightInset'))

%% NAM
fileName = dir('Output\benchmark\benchmark_nam_000007_*.mat');
load(['Output\benchmark\',fileName.name])
display('*****NAM********')

F1 = figure;
set(F1,'Name','NAMProd')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')

for i1 = 1:4
  subplot(2,2,i1)
  surf(C.Grid,C.Grid,M.Prod','CData',10*ones(size(M.Prod')),'FaceAlpha',0.75)
  hold on
  ProdHat = RD.Y.Prod;
  surf(C.Grid,C.Grid,ProdHat','linestyle','none','FaceAlpha',0.5)
  set(gca,'FontSize',16)
  if i1 == 1
    view(-45,10)
    title('Top')
  elseif i1 == 2
    view(-45-180,10)
    title('Under')
  elseif i1 == 3
    view(-100,10)
    title('Side-Top')
  else
    view(100,10)
    title('Side-Under')
  end
  xlabel('x')
  ylabel('y')
  zlabel('f(x,y)')
  Li = line([1 0],[1 0],[nanmin(vec(C.Prod)) nanmax(vec(C.Prod))]);
  set(Li,'Color','r');
  set(Li,'LineWidth',2);
  axis([0 1 0 1 nanmin(vec(C.Prod)) nanmax(vec(C.Prod))]);
  hold off
end

set(gca,'LooseInset',get(gca,'TightInset'))

%% NOT
fileName = dir('Output\benchmark\benchmark_not_000007_*.mat');
load(['Output\benchmark\',fileName.name])
display('*****NOT********')

F1 = figure;
set(F1,'Name','NOTProd')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')

for i1 = 1:4
  subplot(2,2,i1)
  surf(C.Grid,C.Grid,M.Prod','CData',10*ones(size(M.Prod')),'FaceAlpha',0.75)
  hold on
  ProdHat = RD.Y.Prod;
  surf(C.Grid,C.Grid,ProdHat','linestyle','none','FaceAlpha',0.5)
  set(gca,'FontSize',16)
  if i1 == 1
    view(-45,10)
    title('Top')
  elseif i1 == 2
    view(-45-180,10)
    title('Under')
  elseif i1 == 3
    view(-100,10)
    title('Side-Top')
  else
    view(100,10)
    title('Side-Under')
  end
  xlabel('x')
  ylabel('y')
  zlabel('f(x,y)')
  Li = line([1 0],[1 0],[nanmin(vec(C.Prod)) nanmax(vec(C.Prod))]);
  set(Li,'Color','r');
  set(Li,'LineWidth',2);
  axis([0 1 0 1 nanmin(vec(C.Prod)) nanmax(vec(C.Prod))]);
  hold off
end

set(gca,'LooseInset',get(gca,'TightInset'))
