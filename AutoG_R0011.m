dataFile = 'DATA.TXT';

% headerLabels = readtable(headerFile);
data = readtable(dataFile);
nSmooth = 200;
animalWeight = data.Var5(find(data.Var1==0,1));
loadData = smoothdata(data.Var5(data.Var1==1),'gaussian',nSmooth);
lightData = smoothdata(data.Var7(data.Var1==1),'gaussian',nSmooth);
loadStd = abs(gradient(data.Var5(data.Var1==1)));
targetLoad = data.Var6(find(data.Var1==1,1));
targetWeight = animalWeight*(100-targetLoad)/100;
timeData = data.Var3(data.Var1==1);
Fs = median(diff(timeData));

t = datetime(timeData,'ConvertFrom','epochtime','TimeZone','UTC');
t.TimeZone = 'America/Detroit';

lns = [];
colors = lines(5);
close all
ff(1200,400);
useylim = [0 round(targetWeight*2)];
lightThresh = 600;
startX = [];
for ii = 1:numel(lightData)
    if lightData(ii) > lightThresh && isempty(startX)
        startX = ii;
    end
    if (lightData(ii) < lightThresh || ii == numel(lightData)) && ~isempty(startX)
        lns(1) = patch(t([startX,ii,ii,startX]),[min(useylim),min(useylim),max(useylim),max(useylim)],...
            'k','FaceColor',colors(3,:),'EdgeColor','none','FaceAlpha',0.2);
        hold on;
        startX = [];
    end
end

lns(2) = plot(t,loadData,'k-','linewidth',2);
lns(3) = plot(t,loadStd,'k:','linewidth',1);
lns(4) = plot(t,repmat(targetWeight,[1,numel(t)]),'color','r','linewidth',2);
ylabel('Crane Weight (g)');
xlim([min(t) max(t)]);
xtickangle(30);
ylim(useylim);
set(gca,'fontsize',16);
grid on;

yyaxis right;
lns(5) = plot(t,normalize(smoothdata(loadStd,'movmean',60*60*6),'range',[-1 1]),'color',colors(5,:),'linewidth',1.5);
set(gca,'ycolor',colors(5,:));
yticks([-.2 .2]);
yticklabels({[char(8595),'Asleep'],[char(8593),'Awake']});
ylim([-1.2 1.2]);


title(sprintf('%1.1f hours, %i%% Partial Bearing (rat = %ig)',hours(t(end)-t(1)),targetLoad,animalWeight));
legend(lns,{'Room lights','Crane Weight (g)','    (variance)','    (target)','Sleep Est.'});