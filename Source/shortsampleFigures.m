clear
load Output\shortsample\Data.mat
%% RDY_OCorrMZ
HistCell              = 15;
MaxCount              = 0;
FontSize              = 25;
AxisLim               = [0.96 1.002 0 60];
F1 = figure;
set(F1,'Name','RDY_OCorrMZ_shortsample')
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

%% WorkerFirmSortingAll1
FontSize              = 25;
TickMark              = 6;
LB  = -0.8;
UB  = 0.8;
LBY = -0.8;
UBY = 0.8;

F1                    = figure;
set(F1,'Name','WorkerFirmSortingAll_shortsample')
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')

xlabel('True worker-firm type rank correlation','fontsize',FontSize)
hold on
Group = ProdName ==1 ;
plot(RDFS_WFTrueCorr(Group,1),RDFS_WFEstCorr(Group,1),'kx','markersize',TickMark)
Group = ProdName ==2 ;
plot(RDFS_WFTrueCorr(Group,1),RDFS_WFEstCorr(Group,1),'k+','markersize',TickMark,'linewidth',2)
Group = ProdName ==3 ;
plot(RDFS_WFTrueCorr(Group,1),RDFS_WFEstCorr(Group,1),'k.','markersize',14,'linewidth',2)
%legend({'PAM','NAM','NEITHER'},'FontSize',FontSize,'Location','southeast');

plot(linspace(LB,UB,100),linspace(LB,UB,100),'-','linewidth',1.5,'Color',[.6 0.6 0.6])
Group = ProdName ==1 ;
plot(RDFS_WFTrueCorr(Group,1),RDFS_WFEstCorr(Group,1),'kx','markersize',TickMark,'linewidth',2)
Group = ProdName ==2 ;
plot(RDFS_WFTrueCorr(Group,1),RDFS_WFEstCorr(Group,1),'k+','markersize',TickMark,'linewidth',2)
Group = ProdName ==3 ;
plot(RDFS_WFTrueCorr(Group,1),RDFS_WFEstCorr(Group,1),'k.','markersize',14)
ylabel('Estimated worker-firm type rank correlation','fontsize',FontSize)

axis(([LB UB LBY UBY]))
set(gca,'FontSize',FontSize)
set(gca,'XTick',[LB:0.2:UB])
set(gca,'YTick',[LBY:0.2:UBY])
hold off
box on

%% Output losses
F1 = figure;
FontSize              = 25;
TickMark              = 6;
set(F1,'Name','OutputLossesCombined_shortsample')
Group = ProdName < 4;
set(F1,'Units','Inches','outerposition',[0 0 11 11]);
set(F1,'PaperOrientation','Landscape');
set(F1,'PaperPositionMode','Auto');
set(F1,'Clipping','off')
plot(linspace(0,0.995,100),linspace(0.005,1,100),'k--','linewidth',1.5,'Color',[.6 0.6 0.6])
hold on
plot(RDSP_TrueGainAll(Group,1),RDSP_EstGain_yxAll(Group,1),'k.','markersize',20)
plot(RDSP_TrueGainEmp(Group,1),RDSP_EstGain_yxEmp(Group,1),'k+','markersize',6,'linewidth',2)
legend({'0.5% Bound','All Workers','Employed Only'},'FontSize',FontSize,'Location','southeast');
plot(linspace(0,1,100),linspace(0,1,100),'k-','linewidth',1.5,'Color',[.6 0.6 0.6])
plot(linspace(0.005,1,100),linspace(0,0.995,100),'k--','linewidth',1.5,'Color',[.6 0.6 0.6])
plot(RDSP_TrueGainAll(Group,1),RDSP_EstGain_yxAll(Group,1),'k.','markersize',20)
plot(RDSP_TrueGainEmp(Group,1),RDSP_EstGain_yxEmp(Group,1),'k+','markersize',6,'linewidth',2)
axis([0.95*min([RDSP_TrueGainAll;RDSP_EstGain_yxAll;RDSP_TrueGainEmp;RDSP_EstGain_yxEmp]) 1.05*max([RDSP_TrueGainAll;RDSP_EstGain_yxAll;RDSP_TrueGainEmp;RDSP_EstGain_yxEmp]) 0.95*min([RDSP_TrueGainAll;RDSP_EstGain_yxAll;RDSP_TrueGainEmp;RDSP_EstGain_yxEmp]) 1.05*max([RDSP_TrueGainAll;RDSP_EstGain_yxAll;RDSP_TrueGainEmp;RDSP_EstGain_yxEmp])])
set(gca,'FontSize',FontSize)
set(gca,'XTickLabel',100*get(gca,'XTick'))
set(gca,'YTickLabel',100*get(gca,'YTick'))
hold off
ylabel('Estimated Output Percent Gain','fontsize',FontSize)
xlabel('True Output Percent Gain','fontsize',FontSize)
