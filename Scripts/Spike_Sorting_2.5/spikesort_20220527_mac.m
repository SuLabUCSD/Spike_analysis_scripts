function [] = spikesort_20220527_mac()
versionname = 'Spike Sorting 2.5';
disp(versionname)
% Carlotta's spike sorting and processing GUI

%% initialise variables, make the master window
svalve = [];
currdata = [1 1];
deltat = 0.001;
stimon = 1;
filein_name = [];
fileout_name = [];
file_path=[];
mode = 0;
numtrials = [];
numexp = [];
px_spk = 1;
px_v = 1;
refractory = 0.0025;
tr = round(refractory/deltat);
trss = []; % will be spike duration
tracedone = [];
time = [];
tlim = 1;
tSPKA = [];
tSPKB = [];
xlimit = [0 11];
ylimit = [];
L = [];
startcount = 0.5;
SPKcountA = [];
SPKcountB = [];
SPKcurr = [];
SPKAcurr = [];
SPKBcurr = [];
SPKtemp = [];
SPKAtemp = [];
SPKBtemp = [];
Tnoise= -0.001;
THnoise = [];
THA = [];
Vcurr = [];
V = []; % voltage matrix
pid = [];
pidcurr = [];
hm1 = [];
hm2 = [];
hm2=  [];
hm3 = [];
hm4 = [];
hm5 = [];
PC= [];
IS= [];
S= [];
cp = [];
hmc = []; % clustering window handle
editon = [];
autofixbutton = [];
fsize = 16;

% make the master figure, and the axes to plot the voltage traces
fig = figure('position',[50 50 1400 700],'WindowButtonDownFcn',@mousecallback, 'WindowKeyPressFcn',@keycallback, 'WindowScrollWheelFcn',@scrollcallback, 'Toolbar','none','Menubar','none','Name',versionname,'NumberTitle','off','IntegerHandle','off');
ax = axes('parent',fig,'position',[0.05 0.05 0.9 0.4]);
ax2 = axes('parent',fig,'position',[0.05 0.48 0.9 0.18]);
% set(ax2,'xticklabel',{[]});
ind = [];

%% file inout-output (IO) module
%this is the file IO module. makes the panel to import data.
IOpanel = uipanel('Title', 'File IO', 'FontSize',fsize, 'units','pixels','pos',[10 510 320 180]);
selectformat = uicontrol(IOpanel,'Position',[7 115 100 20],'Style', 'popupmenu', 'String', {'matlab', 'custom'},'FontSize',11, 'value', 1);
loadfile = uicontrol(IOpanel,'Position',[5 75 100 30],'String','load data','FontSize',12,'Callback',@loadfilecallback);
showloadfile = uicontrol(IOpanel,'Position',[110 75 200 30],'Style', 'text', 'String', filein_name,'FontSize',11); % no callback needed here
loadspk = uicontrol(IOpanel,'Position',[5 40 100 30],'String','load spk','FontSize',12,'Callback',@loadspkcallback);
showloadspkfile = uicontrol(IOpanel,'Position',[100 40 200 30],'Style', 'text', 'String', filein_name,'FontSize',11); % no callback needed here
savefile = uicontrol(IOpanel,'Position',[5 5 100 30], 'String','save data','FontSize',12,'Callback',@savefilecallback);
getfilenameout = uicontrol(IOpanel,'Position',[110 5 200 30],'Style', 'Edit');

%% clustering panel
noisepanel = uipanel('Title','Clustering', 'FontSize',fsize,'units','pixels','pos',[500 490 150 65]);
mansort = uicontrol(noisepanel,'Position',[5 5 140 30], 'String', 'clust','FontSize',12,'Callback',@clustsortcallback);

%% parameters (a subpanel to enter parameters like refractory time, deltat)
parameterpanel = uipanel('Title', 'Parameters', 'FontSize',fsize, 'units','pixels','pos',[335 570 160 120]);
textdeltat = uicontrol(parameterpanel,'Position',[5 55 65 20],'Style', 'text', 'String', 'deltat (s) = ','FontSize',11,'FontWeight','bold');
getdeltat = uicontrol(parameterpanel,'Position',[80 55 55 20],'Style', 'Edit', 'String', num2str(deltat),'FontSize',11,'Callback',@getdeltatcallback);
textstimon = uicontrol(parameterpanel,'Position',[5 30 70 20],'Style', 'text', 'String', 'stim on (s) = ','FontSize',11,'FontWeight','bold');
getstimon = uicontrol(parameterpanel,'Position',[80 30 55 20],'Style', 'Edit', 'String','1','FontSize',11);
textrefractory = uicontrol(parameterpanel,'Position',[5 5 50 20],'Style', 'text', 'String', 'refr (s) = ','FontSize',11,'FontWeight','bold');
getrefractory = uicontrol(parameterpanel,'Position',[80 5 60 20],'Style', 'Edit', 'String',num2str(refractory),'FontSize',11,'Callback',@getdeltatcallback);

%% manual sorting
sortingpanel = uipanel('Title','Manual sort', 'FontSize',fsize, 'units','pixels','pos',[655 530 170 162]);
bgroupmode = uibuttongroup(sortingpanel, 'units','pixels','Position',[10 5 80 130],'BorderType','line');
nomode = uicontrol(bgroupmode,'Position',[5 80 80 27], 'Style', 'radiobutton', 'String', 'no input','FontSize',12);
thnoise = uicontrol(bgroupmode,'Position',[5 2 80 27], 'Style', 'radiobutton', 'String', 'noise','FontSize',12);
thA = uicontrol(bgroupmode,'Position',[5 28 80 27], 'Style', 'radiobutton', 'String', 'neuron','FontSize',12);
modify = uicontrol(bgroupmode,'Position',[5 54 80 27], 'Style', 'radiobutton', 'String', 'modify','FontSize',12);
countmode = uicontrol(bgroupmode,'Position',[5 106 80 27], 'Style', 'radiobutton', 'String', 'count','FontSize',12);
findmin = uicontrol(sortingpanel,'Position',[100 2 60 30], 'String', 'find','FontSize',12,'Callback',@findmincallback);
filt = uicontrol(sortingpanel,'Position',[100 31 60 30],'String', 'filter','FontSize',12, 'Callback',@filtcallback);
done = uicontrol(sortingpanel,'Position',[100 61 60 30],'String','done','FontSize',12, 'Callback',@donecallback);
redo = uicontrol(sortingpanel,'Position',[100 91 60 30],'String','redo','FontSize',12, 'Callback',@redocallback);

%% count panel
countpanel = uipanel('Title','Count spikes', 'FontSize',fsize, 'units','pixels','pos',[500 560 150 130]);
count = uicontrol(countpanel,'Position',[5 50 80 30], 'String', 'count','FontSize',12,'Callback',@countcallback);
textcountA = uicontrol(countpanel,'Position',[5 25 100 20],'Style', 'text', 'String', 'A = 0 spk/sec','FontSize',12,'FontWeight','bold');
textcountB = uicontrol(countpanel,'Position',[5 5 100 20],'Style', 'text', 'String', 'B = 0 spk/sec','FontSize',12,'FontWeight','bold');
textlengthcount = uicontrol(countpanel,'Position',[5 80 55 20],'Style', 'text', 'String', 'win = ','FontSize',11,'FontWeight','bold');
getlengthcount = uicontrol(countpanel,'Position',[55 80 55 20],'Style', 'Edit', 'String','0.5','FontSize',11);

%% viewpanel (the drag and zoom buttons)
viewpanel = uipanel('Title', 'View', 'FontSize',fsize, 'units','pixels','pos',[830 570 180 120]);
cur = uicontrol(viewpanel,'Position',[10 5 80 30],'String','cursor','FontSize',12,'Callback',@cursorcallback);
zin = uicontrol(viewpanel,'Position',[10 35 80 30],'String','zoom x','FontSize',12,'Callback',@zoomincallback);
zy = uicontrol(viewpanel,'Position',[90 35 80 30],'String','zoom y','FontSize',12,'Callback',@zoomycallback);
panon = uicontrol(viewpanel,'Position',[10 65 80 30],'String','drag x','FontSize',12,'Callback',@pancallback);
pany = uicontrol(viewpanel,'Position',[90 65 80 30],'String','drag y','FontSize',12,'Callback',@panycallback);

%% current trace
% this has controls for navigating through the data (trials, experiments)
currtracepanel = uipanel('Title', 'Current Trace', 'FontSize',fsize, 'units','pixels','pos',[1015 550 130 140]);
textexp = uicontrol(currtracepanel,'Position',[10 85 110 20],'Style', 'text', 'String', 'num exp:','FontSize',12,'FontWeight','bold');
nextexp = uicontrol(currtracepanel,'Position',[80 55 30 30],'String','>>','FontSize',12,'Callback',@nextexpcallback);
prevexp = uicontrol(currtracepanel,'Position',[50 55 30 30],'String','<<','FontSize',12,'Callback',@prevexpcallback);
setcurrexp = uicontrol(currtracepanel,'Position',[20 55 30 30],'Style', 'Edit', 'String', num2str(currdata(1)),'FontSize',12,'Callback',@setcurrexpcallback);
texttrial = uicontrol(currtracepanel,'Position',[10 35 110 20],'Style', 'text', 'String', 'num trials: ','FontSize',12,'FontWeight','bold');
nexttrial = uicontrol(currtracepanel,'Position',[80 5 30 30],'String','>>','FontSize',12,'Callback',@nexttrialcallback);
prevtrial = uicontrol(currtracepanel,'Position',[50 5 30 30],'String','<<','FontSize',12,'Callback',@prevtrialcallback);
setcurrtrial = uicontrol(currtracepanel,'Position',[20 5 30 30],'Style', 'Edit', 'String', num2str(currdata(2)),'FontSize',12,'Callback',@setcurrtrialcallback);

%% plot panel
% this has the buttons to plot the raster plots and the PSTH
plotpanel = uipanel('Title','Plot', 'FontSize',fsize, 'units','pixels','pos',[1150 550 230 140]);
rasterplot = uicontrol(plotpanel,'Position',[5 80 80 30],'String','raster','FontSize',12, 'Callback',@rasterplotcallback);
setrasterexp = uicontrol(plotpanel,'Position',[88 80 50 30],'Style', 'Edit', 'String', 'all-all', 'FontSize',12);
bgroupraster = uibuttongroup(plotpanel, 'units','pixels','Position',[140 80 70 30],'BorderType','none');
Araster = uicontrol(bgroupraster,'Position',[2 2 50 30], 'Style', 'radiobutton', 'String', 'A','FontSize',12);
Braster = uicontrol(bgroupraster,'Position',[34 2 50 30], 'Style', 'radiobutton', 'String', 'B','FontSize',12);
PSTHplot = uicontrol(plotpanel,'Position',[5 45 80 30],'String','PSTH','FontSize',12, 'Callback',@PSTHplotcallback);
setPSTHexp = uicontrol(plotpanel,'Position',[88 45 50 30],'Style', 'Edit', 'String', 'all-all', 'FontSize',12);
bgroupPSTH = uibuttongroup(plotpanel, 'units','pixels','Position',[140 45 70 30],'BorderType','none');
APSTH = uicontrol(bgroupPSTH,'Position',[2 2 50 30], 'Style', 'radiobutton', 'String', 'A','FontSize',12);
BPSTH = uicontrol(bgroupPSTH,'Position',[34 2 50 30], 'Style', 'radiobutton', 'String', 'B','FontSize',12);
textbin = uicontrol(plotpanel,'Position',[90 12 40 30],'Style', 'text', 'String', 'bin','FontSize',11,'FontWeight','bold');
getbin = uicontrol(plotpanel,'Position',[90 5 40 20],'Style', 'Edit', 'String','0.1','FontSize',11);
textslid = uicontrol(plotpanel,'Position',[140 12 40 30],'Style', 'text', 'String', 'slid','FontSize',11,'FontWeight','bold');
getslid = uicontrol(plotpanel,'Position',[140 5 40 20],'Style', 'Edit', 'String','0.01','FontSize',11);
savecurrplot = uicontrol(plotpanel,'Position',[5 5 80 30],'String','save plot','FontSize',12, 'Callback',@savecurrplotcallback);

%% some small functions

    function zoomincallback(~,~)
        zoom xon
    end

    function zoomycallback(~,~)
        zoom yon
    end

    function cursorcallback(~,~)
        zoom off
        pan off
    end

    function pancallback(~,~)
        pan xon
    end

    function panycallback(~,~)
        pan yon
    end

    function getdeltatcallback(~,~)
        deltat = str2double(get(getdeltat, 'String'));
        refractory = str2double(get(getrefractory, 'String'));
        tr = round(refractory/deltat);
    end


%% the file I/O panel has these callbacks:
% 1. @loadfilecallback
% 2. @loadspkcallback
% 3. @savefilecallback

% 1.
    function loadfilecallback(~,~)
        dataformat = get(selectformat, 'value');
        [V, filein_name, file_path, svalve, pid, deltat] = spike_sorting_loadfile(dataformat);
        set(getdeltat, 'String', num2str(deltat))
        tr = round(refractory/deltat);
        trss = round(3*tr); % used to cluster spike shapes
        if ~isempty(V)
            [numexp, numtrials, L] = size(V);
            time = (1:L)'*deltat;
            Vcurr = squeeze(V(currdata(1),currdata(2),:));
            plot(ax,time, Vcurr, 'k');
            plotstim;
            pidcurr = squeeze(pid(currdata(1),currdata(2),:));
            plot(ax2, time(1:10:end), pidcurr(1:10:end), 'k');
            set(showloadfile, 'String', filein_name)
            THnoise = zeros(L,1);
            SPKcurr = zeros(L,1);
            THA = zeros(L,1);
            tSPKA = zeros(numexp,numtrials,3000);
            tSPKB = zeros(numexp,numtrials,3000);
            tracedone = zeros(numexp, numtrials);
            SPKcountA = zeros(numexp, numtrials);
            SPKcountB = zeros(numexp, numtrials);
            set(setcurrexp, 'String', num2str(currdata(1)))
            set(setcurrtrial, 'String', num2str(currdata(2)))
            s = regexp(filein_name, '\.mat', 'split');
            fileout_name = [s{1} '_SPKtemp.mat'];
            set(getfilenameout, 'String', fileout_name);
            set(texttrial, 'String', ['num trials: ' num2str(numtrials)],'FontSize',12,'FontWeight','bold');
            set(textexp, 'String', ['num exp: ' num2str(numexp)],'FontSize',12,'FontWeight','bold');
        end

    end

% 2. @loadspkcallback
    function loadspkcallback(~,~)
        [filespk_name, file_path] = uigetfile('*.mat','Select the data file');
        if filespk_name~=0
            set(showloadspkfile, 'String', filespk_name)
            F = load([ file_path filespk_name]);
            tSPKA = F.tSPKA;
            tSPKB = F.tSPKB;
            tracedone = F.tracedone;
            SPKcountA = F.SPKcountA;
            SPKcountB = F.SPKcountB;
            if tracedone(currdata(1), currdata(2)) && ~isempty(V)
                replot_tracedone(ax)
            end
            set(getfilenameout, 'String', filespk_name);
            [numexp, numtrials] = size(tracedone);
            set(texttrial, 'String', ['num trials: ' num2str(numtrials)],'FontSize',12,'FontWeight','bold');
            set(textexp, 'String', ['num exp: ' num2str(numexp)],'FontSize',12,'FontWeight','bold');
            set(textcountA, 'String', ['A = ' num2str(SPKcountA(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
            set(textcountB, 'String', ['B = ' num2str(SPKcountB(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
        end
    end

% 3. @savefilecallback
    function savefilecallback(~,~)
        fileout_name = get(getfilenameout, 'String');
        save([file_path fileout_name], 'tSPKA', 'tSPKB', 'deltat', 'tracedone', 'SPKcountA', 'SPKcountB');
    end


%% these callbacks are for user interaction 
% 1. @mousecallback
% 2. @keycallback
% 3. @scrollcallback

% 1. @mousecallback
    function mousecallback(~,~)
        xlimit = get(ax, 'xlim');
        ylimit = get(ax, 'ylim');
        pos = get(ax,'CurrentPoint');
        xpos = pos(1);
        ypos = pos(3);

        if get(countmode, 'value')
            startcount = xpos;
        elseif get(modify, 'Value')==0
            xpos = round(xpos/deltat);
            if xpos<=0; xpos = 1; end
            if xpos>L; xpos = L; end
            if xpos<tlim; tlim=1; end

            if get(thnoise, 'Value')==1
                mode = 1;
                if tlim==1; THnoise = zeros(L,1); end
                THnoise(tlim:xpos) = ypos;
                pSPKcurr = SPKcurr; pSPKcurr(SPKcurr == 0) = NaN;
                plot(ax,time, Vcurr, 'k', time, pSPKcurr, 'or', time, THnoise, 'r')
                set(ax,'xlim',xlimit)
                set(ax,'ylim',ylimit)
                set(ax2,'xlim',xlimit)
                clear pSPKcurr
                plotstim;
                tlim = xpos+1;
            end
            if get(thA, 'Value')==1
                mode = 2;
                if tlim==1; THA = zeros(L,1); end
                THA(tlim:xpos) = ypos;
                pSPKcurr = SPKcurr; pSPKcurr(SPKcurr == 0) = NaN;
                plot(ax,time, Vcurr, 'k', time, pSPKcurr, 'or', time, THA, 'r')
                set(ax,'xlim',xlimit)
                set(ax,'ylim',ylimit)
                set(ax2,'xlim',xlimit)
                clear pSPKcurr
                plotstim;
                tlim = xpos+1;
            end
        elseif get(modify, 'Value')==1
            % when 'modify' option is selected, it gets the closest identified spike
            % and voltage value
            mode = 3;
            [~,it] = min((time-xpos).^2);
            int = max(it-(tr-1)/2, 0):min(it+(tr-1)/2, length(time));
            [~,px_spk] = min((SPKcurr(int)-ypos).^2);
            px_spk = px_spk + int(1) -1;
            [~,px_v] = min((Vcurr(int)-ypos).^2);
            px_v = px_v + int(1) -1;
            %             [~,px_v] = min((time-xpos).^2+(Vcurr-ypos).^2);

        end

    end

% 2. @keycallback
    function keycallback(~,ed)    % so now this uses ed. What is this?
        % ed is a structure that contains the keyboard input values, the
        % character, the modifier, and the key, which is the actial thing
        % entered. eo seems to contain a number, maybe a handle? not sure.

        if get(modify, 'Value') || get(thnoise, 'Value') || get(thA, 'Value')
            keypressed = ed.Key;
            xlimit = get(ax, 'xlim');
            ylimit = get(ax, 'ylim');
            if strcmp(keypressed, 'rightarrow')
                newlim = xlimit + (xlimit(2)-xlimit(1))/3;
                if newlim(1)<0; newlim(1)=-0.1; newlim(2) = newlim(1) + (xlimit(2)-xlimit(1));   end
                if newlim(2)>(L*deltat)+1; newlim(2)=(L*deltat)+1.1; newlim(1) = newlim(2) - (xlimit(2)-xlimit(1)); end
                xlimit = newlim;
                set(ax,'xlim', xlimit, 'ylim', ylimit)
                set(ax2,'xlim', xlimit)
            elseif strcmp(keypressed, 'leftarrow')
                newlim = xlimit - (xlimit(2)-xlimit(1))/3;
                if newlim(1)<0; newlim(1)=-0.1; newlim(2) = newlim(1) + (xlimit(2)-xlimit(1));   end
                if newlim(2)>(L*deltat)+1; newlim(2)=(L*deltat)+1.1; newlim(1) = newlim(2) - (xlimit(2)-xlimit(1)); end
                xlimit = newlim;
                set(ax,'xlim', xlimit, 'ylim', ylimit)
                set(ax2,'xlim', xlimit);
            elseif get(modify, 'Value')
                mode = 3; % modify mode.
                SPKAtemp = SPKAcurr;
                SPKBtemp = SPKBcurr;
                SPKtemp = SPKcurr;
                if strcmp(keypressed, 'space')
                    SPKcurr(px_spk) = 0;
                    SPKAcurr(px_spk) = 0;
                    SPKBcurr(px_spk) = 0;
                    pSPKAcurr = SPKAcurr; pSPKBcurr = SPKBcurr; pSPKAcurr(SPKAcurr == 0) = NaN; pSPKBcurr(SPKBcurr ==0) =NaN;
                    plot(ax,time, Vcurr, 'k', time, pSPKAcurr, 'or', time, pSPKBcurr, 'ob')
                    clear pSPKAcurr pSPKBcurr
                    xlim(xlimit)
                    ylim(ylimit)
                    plotstim;
                    set(ax2,'xlim',xlimit)

                end
                if strcmp(keypressed, 'a')
                    SPKAcurr(px_spk) = SPKcurr(px_spk);
                    SPKBcurr(px_spk) = 0;
                    pSPKAcurr = SPKAcurr; pSPKBcurr = SPKBcurr; pSPKAcurr(SPKAcurr == 0) = NaN; pSPKBcurr(SPKBcurr ==0) =NaN;
                    plot(ax, time, Vcurr, 'k', time, pSPKAcurr, 'or', time, pSPKBcurr, 'ob')
                    clear pSPKAcurr pSPKBcurr
                    xlim(xlimit)
                    ylim(ylimit)
                    plotstim;
                    set(ax2,'xlim',xlimit)

                end
                if strcmp(keypressed, 'b')
                    SPKBcurr(px_spk) = SPKcurr(px_spk);
                    SPKAcurr(px_spk) = 0;
                    pSPKAcurr = SPKAcurr; pSPKBcurr = SPKBcurr; pSPKAcurr(SPKAcurr == 0) = NaN; pSPKBcurr(SPKBcurr ==0) =NaN;
                    plot(ax, time, Vcurr, 'k', time, pSPKAcurr, 'or', time, pSPKBcurr, 'ob')
                    clear pSPKAcurr pSPKBcurr
                    xlim(xlimit)
                    ylim(ylimit)
                    plotstim;
                    set(ax2,'xlim',xlimit)

                end
                if strcmp(keypressed, 'n')
                    SPKAcurr(px_v) = Vcurr(px_v);
                    SPKcurr(px_v) = Vcurr(px_v);
                    pSPKAcurr = SPKAcurr; pSPKBcurr = SPKBcurr; pSPKAcurr(SPKAcurr == 0) = NaN; pSPKBcurr(SPKBcurr ==0) =NaN;
                    plot(ax, time, Vcurr, 'k', time, pSPKAcurr, 'or', time, pSPKBcurr, 'ob')
                    clear pSPKAcurr pSPKBcurr
                    xlim(xlimit)
                    ylim(ylimit)
                    plotstim;
                    set(ax2,'xlim',xlimit)

                end
                % save on modify
                tSPKA(currdata(1), currdata(2),1:sum(SPKAcurr~=0))=find(SPKAcurr~=0);
                tSPKB(currdata(1), currdata(2),1:sum(SPKBcurr~=0))=find(SPKBcurr~=0);
                tSPKA(currdata(1), currdata(2),sum(SPKAcurr~=0)+1:end)=0;
                tSPKB(currdata(1), currdata(2),sum(SPKBcurr~=0)+1:end)=0;
                tracedone(currdata(1),currdata(2))=1;
                fileout_name = get(getfilenameout, 'String');
                save([file_path fileout_name], 'tSPKA', 'tSPKB', 'deltat', 'tracedone', 'SPKcountA', 'SPKcountB');
            end
        end
    end

% 3. @scrollcallback
    function scrollcallback(~,ed)
        xlimit = get(ax, 'xlim');
        scrollsize = ed.VerticalScrollCount;
        newlim = xlimit + scrollsize*(xlimit(2)-xlimit(1))/3;
        if newlim(1)<0; newlim(1)=-0.1; newlim(2) = newlim(1) + (xlimit(2)-xlimit(1));   end
        if newlim(2)>+(L*deltat)+1; newlim(2)=(L*deltat)+1.1; newlim(1) = newlim(2) - (xlimit(2)-xlimit(1)); end
        xlimit = newlim;
        set(ax,'xlim', xlimit)
        set(ax2,'xlim', xlimit);
    end


%% these callbacks are for changing trace
% 1. @nextexpcallback
% 2. @prevexpcallback
% 3. @nexttrialcallback
% 4. @prevtrialcallback
% 5. @setcurrexpcallback
% 6. @setcurrtrialcallback

% 1. @nextexpcallback
    function nextexpcallback(~,~)
        % donecallback; % NO autosave
        if currdata(1)<numexp
            currdata(1) = currdata(1)+1;
            Vcurr = squeeze(V(currdata(1), currdata(2),:));
            pidcurr = squeeze(pid(currdata(1), currdata(2),:));
            set(setcurrexp, 'String', num2str(currdata(1)));
            set(setcurrtrial, 'String', num2str(currdata(2)));
            set(textcountA, 'String', ['A = ' num2str(SPKcountA(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
            set(textcountB, 'String', ['B = ' num2str(SPKcountB(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
            if tracedone(currdata(1), currdata(2))
                replot_tracedone(ax)
            else
                plot(ax, time, Vcurr, 'k');
                plotstim;
                set(findmin,'Enable','on')
                plot(ax2, time(1:10:end), pidcurr(1:10:end), 'k');
            end
        end
    end

% 2. @prevexpcallback
    function prevexpcallback(~,~)
        % donecallback; % NO autosave
        if currdata(1)>1
            currdata(1) = currdata(1)-1;
            Vcurr = squeeze(V(currdata(1), currdata(2),:));
            pidcurr = squeeze(pid(currdata(1), currdata(2),:));
            set(setcurrexp, 'String', num2str(currdata(1)));
            set(setcurrtrial, 'String', num2str(currdata(2)));
            set(textcountA, 'String', ['A = ' num2str(SPKcountA(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
            set(textcountB, 'String', ['B = ' num2str(SPKcountB(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
            if tracedone(currdata(1), currdata(2))
                replot_tracedone(ax)
            else
                plot(ax, time, Vcurr, 'k');
                plotstim;
                set(findmin,'Enable','on')
                plot(ax2, time(1:10:end), pidcurr(1:10:end), 'k');
            end
        end
    end

% 3. @nexttrialcallback
    function nexttrialcallback(~,~)
        % donecallback; % NO autosave
        if currdata(2)<numtrials
            currdata(2) = currdata(2)+1;
            Vcurr = squeeze(V(currdata(1), currdata(2),:));
            pidcurr = squeeze(pid(currdata(1), currdata(2),:));
            set(setcurrtrial, 'String', num2str(currdata(2)))
            if tracedone(currdata(1), currdata(2))
                replot_tracedone(ax)
            else
                plot(ax, time, Vcurr, 'k');
                plotstim;
                set(findmin,'Enable','on')
                plot(ax2, time(1:10:end), pidcurr(1:10:end), 'k');
            end
            set(textcountA, 'String', ['A = ' num2str(SPKcountA(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
            set(textcountB, 'String', ['B = ' num2str(SPKcountB(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
        end
    end

% 4. @prevtrialcallback
    function prevtrialcallback(~,~)
        % donecallback; % NO autosave
        if currdata(2)>1
            currdata(2) = currdata(2)-1;
            Vcurr = squeeze(V(currdata(1), currdata(2),:));
            pidcurr = squeeze(pid(currdata(1), currdata(2),:));
            set(setcurrtrial, 'String', num2str(currdata(2)))
            if tracedone(currdata(1), currdata(2))
                replot_tracedone(ax)
            else
                plot(ax, time, Vcurr, 'k');
                plotstim;
                set(findmin,'Enable','on')
                plot(ax2, time(1:10:end), pidcurr(1:10:end), 'k');
            end
            set(textcountA, 'String', ['A = ' num2str(SPKcountA(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
            set(textcountB, 'String', ['B = ' num2str(SPKcountB(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
        end
    end

% 5. @setcurrexpcallback
    function setcurrexpcallback(~,~)
        %  donecallback; % NO autosave
        n1 = get(setcurrtrial, 'String');
        currdata(1) = str2num(n1);
        currdata(2) = 1;
        if currdata(1)<numexp
            Vcurr = squeeze(V(currdata(1), currdata(2),:));
            pidcurr = squeeze(pid(currdata(1), currdata(2),:));
            if tracedone(currdata(1), currdata(2))
                replot_tracedone(ax)
            else
                plot(ax, time, Vcurr, 'k');
                plotstim;
                set(findmin,'Enable','on')
                plot(ax2, time(1:10:end), pidcurr(1:10:end), 'k');
            end
        end
        set(textcountA, 'String', ['A = ' num2str(SPKcountA(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
        set(textcountB, 'String', ['B = ' num2str(SPKcountB(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
    end

% 6. @setcurrtrialcallback
    function setcurrtrialcallback(~,~)
        n2 = get(setcurrtrial, 'String');
        currdata(2) = str2num(n2);
        if currdata(2)<numtrials
            Vcurr = squeeze(V(currdata(1), currdata(2),:));
            pidcurr = squeeze(pid(currdata(1), currdata(2),:));
            if tracedone(currdata(1), currdata(2))
                replot_tracedone(ax)
            else
                plot(ax, time, Vcurr, 'k');
                plotstim;
                set(findmin,'Enable','on')
                plot(ax2, time(1:10:end), pidcurr(1:10:end), 'k');
            end
            set(textcountA, 'String', ['A = ' num2str(SPKcountA(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
            set(textcountB, 'String', ['B = ' num2str(SPKcountB(currdata(1), currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
        end
    end


%% Callbacks for manual sort
% 1. @filtcallback
% 2. @findmincallback
% 3. @fcountcallback
% 4. @donecallback
% 5. @redocallback

% 1. @filtcallback
    function filtcallback(~,~)
        Vcurr = butter_filter(Vcurr, 70, 1000, deltat, 1, 3);
        plot(ax, time, Vcurr, 'k');
        plotstim;
    end

% 2. @findmincallback
    function findmincallback(~,~)

        xlimit = get(ax, 'xlim');
        V0 = zeros(tr, 1);
        SPKcurr = Mfind_spikes([V0; Vcurr],Tnoise, tr);
        % SPKcurr is a vector as long as the voltage trace, with zeros everywhere,
        % except at the minimia corresponding to the spikes.
        pSPKcurr = SPKcurr; % these are the current candidate spikes
        pSPKcurr(SPKcurr == 0) =  NaN;
        plot(ax, time, Vcurr, 'k',time, pSPKcurr, 'or')
        set(ax,'xlim',xlimit)
        plotstim;
        % and calling findmin disables the button
        set(findmin, 'Enable', 'off');
        set(ax2,'xlim', xlimit);
    end

% 3. @fcountcallback
    function countcallback(~,~)
        lengthcount = str2double(get(getlengthcount, 'String'));
        if get(countmode, 'value')
            startcount = find(SPKAcurr(round(startcount/deltat):end)<0,1) + round(startcount/deltat)-1;
        else
            startcount = round(str2double(get(getstimon, 'String'))/deltat);
        end
        SPKcountA(currdata(1),currdata(2)) = sum(SPKAcurr(startcount:startcount + lengthcount/deltat)<0)/lengthcount;
        set(textcountA, 'String', ['A = ' num2str(SPKcountA(currdata(1),currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
        SPKcountB(currdata(1),currdata(2)) = sum(SPKBcurr(startcount:startcount + lengthcount/deltat)<0)/lengthcount;
        set(textcountB, 'String', ['B = ' num2str(SPKcountB(currdata(1),currdata(2))) ' spk/sec'],'FontSize',12,'FontWeight','bold');
    end

% 4. @donecallback    
    function donecallback(~,~)
        if get(thnoise, 'Value')==1
            mode = 1;
        elseif get(thA,'Value')==1
            mode = 2;
        elseif get(modify,'Value')==1
            mode=3;
        end
        if mode==1 % noise mode
            THnoise(tlim:end)=THnoise(tlim-1);
            SPKcurr(SPKcurr>THnoise)=0;
            pSPKcurr = SPKcurr; pSPKcurr(SPKcurr==0) = NaN;
            plot(ax, time, Vcurr, 'k', time, pSPKcurr, 'or')
            plotstim;
            tlim = 1;
            THnoise = zeros(L,1);
        end
        if mode==2 % neuron mode
            THA(tlim:end)=THA(tlim-1);
            SPKAcurr = SPKcurr;
            SPKBcurr = SPKcurr;
            SPKAcurr(SPKcurr>THA)=0;
            SPKBcurr(SPKcurr<THA)=0;
            pSPKAcurr = SPKAcurr; pSPKBcurr = SPKBcurr; pSPKAcurr(SPKAcurr == 0) = NaN; pSPKBcurr(SPKBcurr ==0) =NaN;
            plot(ax, time, Vcurr, 'k', time, pSPKAcurr, 'or', time, pSPKBcurr, 'ob')
            plotstim;
            if any(SPKAcurr<0)
                tSPKA(currdata(1), currdata(2),1:sum(SPKAcurr<0))=find(SPKAcurr<0);
                tSPKA(currdata(1), currdata(2),sum(SPKAcurr<0)+1:end)=0;
            else
                tSPKA(currdata(1), currdata(2),:)=0;
            end
            if any(SPKBcurr<0)
                tSPKB(currdata(1), currdata(2),1:sum(SPKBcurr<0))=find(SPKBcurr<0);
                tSPKB(currdata(1), currdata(2),sum(SPKBcurr<0)+1:end)=0;
            else
                tSPKB(currdata(1), currdata(2),:)=0;
            end
            tracedone(currdata(1),currdata(2))=1;
            fileout_name = get(getfilenameout, 'String');
            save([file_path fileout_name], 'tSPKA', 'tSPKB', 'deltat', 'tracedone', 'SPKcountA', 'SPKcountB');
            tlim = 1;
            THA = zeros(L,1);
        end
        if mode==3 % modify mode
            tSPKA(currdata(1), currdata(2),1:sum(SPKAcurr<0))=find(SPKAcurr<0);
            tSPKB(currdata(1), currdata(2),1:sum(SPKBcurr<0))=find(SPKBcurr<0);
            tSPKA(currdata(1), currdata(2),sum(SPKAcurr<0)+1:end)=0;
            tSPKB(currdata(1), currdata(2),sum(SPKBcurr<0)+1:end)=0;
            tracedone(currdata(1),currdata(2))=1;
            fileout_name = get(getfilenameout, 'String');
            save([file_path fileout_name], 'tSPKA', 'tSPKB', 'deltat', 'tracedone', 'SPKcountA', 'SPKcountB');
        end
    end

% 5. @redocallback
    function redocallback(~,~)
        tracedone(currdata(1),currdata(2))=0;
        tSPKA(currdata(1),currdata(2), :) = 0;
        tSPKB(currdata(1),currdata(2), :) = 0;
        Vcurr = squeeze(V(currdata(1), currdata(2),:));
        pidcurr = squeeze(pid(currdata(1), currdata(2),:));
        plot(ax, time, Vcurr, 'k');
        plotstim;
        set(findmin,'Enable','on');
        plot(ax2, time(1:10:end), pidcurr(1:10:end), 'k');
    end


%% Callbacks for clustering
% 1. @clustsortcallback
% 2. @addAcallback
% 3. @addBcallback
% 4. @addNcallback
% 5. @autofixcallback
% 6. @mansortmouse
% 7. @clusterplot
% 8. @updatecluster

% 1. @clustsortcallback
    function clustsortcallback(~,~)
        % sort with clustering callbacks

        cp = []; PC = []; ind = []; IS = []; S = [];
        % SPKcurr is a vector as long as time, with zeros everywhere except
        % at the minima of spikes, where it takes the value of the minima.
        ind = find(SPKcurr<0);
        disp(strcat(mat2str(length(ind)),' putative spikes found.'))

        trss = round(3*tr); % tr is the refractory period in units of deltat, trss is an estimate of the spike duration
        trbefore = round(trss/3);
        trafter = trss-trbefore;
        % remove spikes whose shape does not fall completely within the recording
        if any(find(ind<trbefore, 1))
            ind(1:find(ind>trbefore, 1))=[];
        end
        if any(find(ind>length(SPKcurr)-trafter-1))
            ind(find(ind>length(SPKcurr)-trafter-1,1):end)=[];
        end

        % find shapes for clustering
        S = [];

        for i=1:length(ind)
            S(i,:) = Vcurr(ind(i)-trbefore:ind(i)+trafter-1);
            S(i,:) = S(i,:) - S(i,trbefore+1);
        end

        % what's happened so far is that little segments around the time of
        % spike have been cut out, and are assembled into the matrix S
        [~,PC] = pca(S);


        % open up a new window for the interactive clustering interface
        hmc = figure('Name',strcat(versionname, ': Interactive Clustering'),'WindowButtonDownFcn',@mansortmouse,'NumberTitle','off','position',[50 50 1200 700]); hold on,axis off
        hm1 = axes('parent',hmc,'position',[-0.05 0.1 0.7 0.7]);axis square, hold on ; title('Clusters','FontSize',18), xlabel('PC 1'), ylabel('PC 2')
        hm2 = axes('parent',hmc,'position',[0.5 0.5 0.3 0.3]);axis square, hold on  ; title('Unsorted Spikes','FontSize',18), set(gca,'YLim',[min(min(S)) max(max(S))]);
        hm3 = axes('parent',hmc,'position',[0.5 0.1 0.3 0.3]);axis square, hold on ; title('A Spikes','FontSize',18),set(gca,'YLim',[min(min(S)) max(max(S))]);
        hm4 = axes('parent',hmc,'position',[0.72 0.1 0.3 0.3]);axis square, hold on ; title('B Spikes','FontSize',18),set(gca,'YLim',[min(min(S)) max(max(S))]);
        hm5 = axes('parent',hmc,'position',[0.72 0.5 0.3 0.3]);axis square, hold on ; title('Noise Spikes','FontSize',18),set(gca,'YLim',[min(min(S)) max(max(S))]);
        % define the buttons and stuff
        sortpanel = uipanel('Title','Controls','FontSize',18, 'units','pixels','pos',[35 600 970 70]);
        addA = uicontrol(sortpanel,'Position',[15 10 100 30], 'String', 'Add to A','FontSize',12,'Callback',@addAcallback);
        addB = uicontrol(sortpanel,'Position',[115 10 100 30], 'String', 'Add to B','FontSize',12,'Callback',@addBcallback);
        addN = uicontrol(sortpanel,'Position',[220 10 160 30], 'String', 'Add to Noise','FontSize',12,'Callback',@addNcallback);
        upcb = uicontrol(sortpanel,'Position',[800 10 160 30], 'String', 'Update and Quit','FontSize',12,'Callback',@updatecluster);
        autofixbutton = uicontrol(sortpanel,'Position',[610 10 160 30], 'String', 'Auto Fix','FontSize',12,'Enable','off','Callback',@autofixcallback);
        editon = 0; % this is a mode selector b/w edititing and looking
        IS = zeros(1,length(PC));
        % plot the clusters
        clusterplot;

        cp = [];

    end
    
% 2. @addAcallback
    function addAcallback(~,~)
        editon = 1;
        ifh = drawfreehand(hm1);
        p = ifh.Position;
        inp = inpolygon(PC(:,1),PC(:,2),p(:,1),p(:,2));
        IS(inp) = 1; % A is 1
        clusterplot;
        editon = 0;
    end
 
% 3. @addBcallback
    function addBcallback(~,~)
        editon = 1;
        ifh = drawfreehand(hm1);
        p = ifh.Position;
        inp = inpolygon(PC(:,1),PC(:,2),p(:,1),p(:,2));
        IS(inp) = 2; % B is 2
        clusterplot;
        editon = 0;
    end

% 4. @addNcallback
    function addNcallback(~,~)
        editon = 1;
        ifh = drawfreehand(hm1);
        p = ifh.Position;
        inp = inpolygon(PC(:,1),PC(:,2),p(:,1),p(:,2));
        IS(inp) = 3; % Noise is 3
        clusterplot;
        editon = 0;
    end

% 5. @autofixcallback
    function autofixcallback(~,~)
        % this automatically assigns unsorted points to the nearsest
        % clusters
        if length(unique(IS))  == 4
            % we have made at least some assignments to each cluster
            xN = PC(IS==3,1); yN = PC(IS==3,2);
            xA = PC(IS==1,1); yA = PC(IS==1,2);
            xB = PC(IS==2,1); yB = PC(IS==2,2);
            dothese = find(IS == 0);
            for i = 1:length(dothese)
                p = PC(dothese(i),1:2);
                cdist(1) = min((xA-p(1)).^2+(yA-p(2)).^2);
                cdist(2) = min((xB-p(1)).^2+(yB-p(2)).^2);
                cdist(3) = min((xN-p(1)).^2+(yN-p(2)).^2);
                IS(dothese(i)) = find(cdist == min(cdist));
            end
            clusterplot;
        end
    end

% 6. @mansortmouse
    function mansortmouse(~,~)
        if editon == 1
            return
        end
        if gca == hm2
            pp = get(hm2,'CurrentPoint');

            p(1) = round(pp(1,1)); p(2) = pp(1,2);
            [~, mi] = min(abs(p(2) - S(IS==0,p(1))));

            % plot on main plot
            cla(hm1)
            plot(hm1,PC(IS == 1,1),PC(IS == 1,2),'or')         % plot A
            plot(hm1,PC(IS == 2,1),PC(IS == 2,2),'ob')         % plot B
            plot(hm1,PC(IS == 3,1),PC(IS == 3,2),'ok')         % plot Noise
            plot(hm1,PC(IS == 0,1),PC(IS == 0,2),'og')         % plot unassigned
            scatter(hm1,PC(cp,1),PC(cp,2),'+k')
            scatter(hm1,PC(mi,1),PC(mi,2),64,'dk')

        elseif gca == hm1
            pp = get(hm1,'CurrentPoint');
            p(1) = (pp(1,1)); p(2) = pp(1,2);
            x = PC(:,1); y = PC(:,2);
            [~,cp] = min((x-p(1)).^2+(y-p(2)).^2); % cp is the index of the chosen point
            if length(cp) > 1
                cp = min(cp);
            end
            % plot the point
            cla(hm1)
            plot(hm1,PC(IS == 1,1),PC(IS == 1,2),'or')         % plot A
            plot(hm1,PC(IS == 2,1),PC(IS == 2,2),'ob')         % plot B
            plot(hm1,PC(IS == 3,1),PC(IS == 3,2),'ok')         % plot Noise
            plot(hm1,PC(IS == 0,1),PC(IS == 0,2),'og')         % plot unassigned
            scatter(hm1,PC(cp,1),PC(cp,2),'+k')
            title(hm1,strcat(mat2str(length(PC)),' putative spikes.'))

            cla(hm2)
            plot(hm2,S(IS == 0,:)','g')
            plot(hm2,S(cp,:),'k','LineWidth',2)
            set(hm2,'XLim',[0 trss])
        end
    end

% 7. @clusterplot
    function clusterplot
        cla(hm1)
        % plot A
        plot(hm1,PC(IS == 1,1),PC(IS == 1,2),'or')
        % plot B
        plot(hm1,PC(IS == 2,1),PC(IS == 2,2),'ob')
        % plot Noise
        plot(hm1,PC(IS == 3,1),PC(IS == 3,2),'ok')
        % plot unassigned
        plot(hm1,PC(IS == 0,1),PC(IS == 0,2),'og')
        axis(hm1, 'square') % 'square'

        % also plot the spike shapes
        cla(hm2)
        plot(hm2,S(IS == 0,:)','g')
        set(hm2,'XLim',[1 trss])


        try
            cla(hm3)
            plot(hm3,S(IS == 1,:)','r')
            set(hm3,'XLim',[0 trss])
        catch ME1
            if strcmp(regexp(ME1.identifier, '(?<=:)\w+$', 'match'),'invalidHandle')
                disp('MATLAB is having problems clearing an plot window. This is an error, but your data has been saved, and you can proceed')
            end
        end

        try
            cla(hm4)
            plot(hm4,S(IS == 2,:)','b')
            set(hm4,'XLim',[0 trss])
        catch ME1
            if strcmp(regexp(ME1.identifier, '(?<=:)\w+$', 'match'),'invalidHandle')
                disp('MATLAB is having problems clearing an plot window. This is an error, but your data has been saved, and you can proceed')
            end
        end


        try
            cla(hm5)
            plot(hm5,S(IS == 3,:)','k')
            set(hm5,'XLim',[0 trss])
        catch ME1
            if strcmp(regexp(ME1.identifier, '(?<=:)\w+$', 'match'),'invalidHandle')
                disp('MATLAB is having problems clearing an plot window. This is an error, but your data has been saved, and you can proceed')
            end
        end

        if min([length(find(IS == 1)) length(find(IS == 2)) length(find(IS == 3))]) > 0
            set(autofixbutton,'Enable','on')
        end





    end

% 8. @updatecluster
    function updatecluster(~,~)
        % let's also autofix
        autofixcallback;
        % only update cluster has writing privelege to SPKcurr
        % this labels the spikes with A, B or noise
        % this is copied from autosort....
        close(hmc)
        figure(fig)
        SPKAcurr = SPKcurr*0;
        SPKBcurr = SPKcurr*0;
        SPKAcurr(ind(IS==1))= SPKcurr(ind(IS==1));
        SPKBcurr(ind(IS==2))= SPKcurr(ind(IS==2));

        SPKcurr(ind(IS==3))=0; % bug fix here
        % recompute ind
        ind = find(SPKcurr < 0);
        IS(IS==3) =[];
        % update the main plot
        pSPKAcurr = SPKAcurr; pSPKBcurr = SPKBcurr; pSPKAcurr(SPKAcurr == 0) = NaN; pSPKBcurr(SPKBcurr ==0) =NaN;
        plot(ax, time, Vcurr, 'k', time, pSPKAcurr, 'or', time, pSPKBcurr, 'ob')
        clear pSPKAcurr pSPKBcurr
        axes(ax)
        plotstim;

        if any(SPKAcurr<0)
            tSPKA(currdata(1), currdata(2),1:sum(SPKAcurr<0))=find(SPKAcurr<0);
            tSPKA(currdata(1), currdata(2),sum(SPKAcurr<0)+1:end)=0;
        else
            tSPKA(currdata(1), currdata(2),:)=0;
        end
        if any(SPKBcurr<0)
            tSPKB(currdata(1), currdata(2),1:sum(SPKBcurr<0))=find(SPKBcurr<0);
            tSPKB(currdata(1), currdata(2),sum(SPKBcurr<0)+1:end)=0;
        else
            tSPKB(currdata(1), currdata(2),:)=0;
        end
        tracedone(currdata(1),currdata(2))=1;
        fileout_name = get(getfilenameout, 'String');
        save([file_path fileout_name], 'tSPKA', 'tSPKB', 'deltat', 'tracedone', 'SPKcountA', 'SPKcountB');
        clear abs_S


    end

%% callbacks for plotting

% 1. @plotstim
% 2. @replot_tracedone
% 3. @rasterplotcallback
% 4. @PSTHplotcallback
% 5. @savecurrplotcallback

% 1. @plotstim
    function plotstim(~,~)
        goon = 1;
        % currdata is a 2-element vector which has the current experiment
        % (1) and the current trial (2)
        if isempty(svalve)
            disp('Cant plot Stimulus, I dont have the data.')
            return
        end
        try
            ton = svalve(currdata(1),currdata(2)).ton;
        catch ME1
            if strcmp(ME1.message,'Index exceeds matrix dimensions.')
                disp('I cant plot the stimulus signal for some reason. Maybe you are looking at blank data? Try going back in time')
                goon = 0;
            end
        end

        if goon == 0 || isempty(svalve(currdata(1),currdata(2)).ton)
            disp('I cant plot the stimulus signal for some reason. Maybe you are looking at blank data? Try going back in time')
            return
        end
        toff = svalve(currdata(1),currdata(2)).toff;
        if length(ton) == length(toff)

            if ton(1) < toff(1)
                % all OK
            else
                % padd both ends
                ton = vertcat(0,ton); toff = vertcat(toff,max(time));
                % chop off the last ton and the first toff
                %                 toff(1) = []; ton(length(ton)) = []; % old code
            end
        elseif length(ton) > length(toff)
            % more tons than toffs
            if ton(1) < toff(1)
                % pad  last toff
                toff = vertcat(toff,max(time));

            else
                disp('Havent coded this case instance yet...')
                keyboard
            end
        elseif length(toff) > length(ton)
            % more toffs than tons
            if ton(1) < toff(1)
                disp('Havent coded this case instance yet...')
                keyboard
            else
                % ton(1) > toff(1), pad tons
                ton = vertcat(0,ton);
            end
        end

        % plot
        if length(toff) ~= length(ton)
            error('The last time this error happened, the lengths of ton and toff were very different. I fixed this by digitisting the stim signal, but apparently this problem is still there. ')
        end
        twidths = toff - ton;
        % there are always some artefacts with very large amplitude that
        % throw the plotstim. Instead of finding the max(Vcurr), which
        % includes these unknown artefacts, let's find the mean of the the
        % top 10%. -- CANCELLED. Too complex.
        axes(ax);
        for i = 1:length(twidths)
            if twidths(i)>0 && max(Vcurr)>0
                rectangle('Position',[ton(i) max(Vcurr) twidths(i) max(Vcurr)/10],'FaceColor',[0.6 0.6 0.6],'EdgeColor',[1 1 1])
            end
        end

    end

% 2. @replot_tracedone
    function replot_tracedone(h)
        SPKAcurr = zeros(L,1);
        SPKBcurr = zeros(L,1);
        %         Vcurr = butter_filter(Vcurr, 70, 1000, deltat, 1, 3);
        tSP = tSPKA(currdata(1),currdata(2),:);
        tSP(tSP==0)=[];
        SPKAcurr(tSP)=Vcurr(tSP);
        tSP = tSPKB(currdata(1),currdata(2),:);
        tSP(tSP==0)=[];
        SPKBcurr(tSP)=Vcurr(tSP);
        pSPKAcurr = SPKAcurr; pSPKBcurr = SPKBcurr; pSPKAcurr(SPKAcurr == 0) = NaN; pSPKBcurr(SPKBcurr ==0) =NaN;
        plot(h, time, Vcurr, 'k', time, pSPKAcurr, 'or', time, pSPKBcurr, 'ob')
        %         ylim([-0.6 .4])
        plotstim;
        THnoise = zeros(L,1);
        THA = zeros(L,1);
        SPKcurr = SPKAcurr + SPKBcurr;
        set(findmin,'Enable','off')
        plot(ax2, time, pidcurr, 'k')
    end

% 3. @rasterplotcallback
    function rasterplotcallback(~,~)
        stimon = str2double(get(getstimon, 'String'));
        rastexp = get(setrasterexp, 'String');

        s = regexp(rastexp, '-', 'split');
        if strcmp(s(1), 'all')
            exptoplot = 1:numexp;
        else
            s_ = regexp(s{1}, ',', 'split');
            exptoplot = str2double(s_);
        end
        if strcmp(s(2), 'all')
            trialstoplot = 1:numtrials;
        else
            s_ = regexp(s{2}, ',', 'split');
            trialstoplot = str2double(s_);
        end

        if get(Araster, 'Value')
            neu = [1 0];
        else
            neu = [0 1];
        end
        figure; hold on;
        %         area([0 stimon stimon (stimon+1) (stimon+1) 10], [0 0 h h 0 0], 'faceColor', [.9 .9 .9], 'edgeColor', [.85 .85 .85])
        nn=1;
        for i = exptoplot
            for t = trialstoplot
                if neu(1)
                    timesp = squeeze(tSPKA(i,t,:));
                else
                    timesp = squeeze(tSPKB(i,t,:));
                end
                timesp(timesp==0)=[];
                if any(timesp)
                    errorbar_raster(timesp*deltat, nn*ones(length(timesp),1),0.5*ones(length(timesp),1), 'k');
                end
                nn=nn+1; % white line for empty trace
            end
            nn=nn+2; % leave space between experiments
        end
        %         ylim([0 nn-2])
        title(regexprep(fileout_name, '_', ' '))
        %         axis off
    end

% 4. @PSTHplotcallback
    function PSTHplotcallback(~,~)
        stimon = str2double(get(getstimon, 'String'));
        PSTHexp = get(setPSTHexp, 'String');

        s = regexp(PSTHexp, '-', 'split');
        if strcmp(s(1), 'all')
            exptoplot = 1:numexp;
        else
            s_ = regexp(s{1}, ',', 'split');
            exptoplot = str2double(s_);
        end
        if strcmp(s(2), 'all')
            trialstoplot = 1:numtrials;
        else
            s_ = regexp(s{2}, ',', 'split');
            trialstoplot = str2double(s_);
        end

        if get(APSTH, 'Value')
            neu = [1 0];
        else
            neu = [0 1];
        end
        win = str2double(get(getbin, 'String'));
        sliding = str2double(get(getslid, 'String'));
        sr = [];
        jj=0;
        for i = exptoplot
            jj=jj+1;
            zz = 0;
            for t = trialstoplot
                zz = zz+1;
                if neu(1)
                    timesp = squeeze(tSPKA(i,t,:));
                else
                    timesp = squeeze(tSPKB(i,t,:));
                end
                timesp(timesp==0)=[];
                spk = spiketime2spk(timesp',L);
                [timesr, sr(jj,zz,:)] = spike_rate(spk', deltat, win, sliding);
            end
        end
        figure; hold on;
        msr = zeros(numexp, length(sr));
        ser = zeros(numexp, length(sr));
        %         area([0 stimon stimon (stimon+.5) (stimon+.5) 10], [0 0 240 240 0 0], 'faceColor', [.85 .85 .85],'edgeColor', [.85 .85 .85])
        for dil=1:length(exptoplot)
            SR = squeeze(sr(dil,:,:));
            [nr, nc] = size(SR);
            if nr>nc
                SR = SR';
            end
            jj=0;
            good = [];
            for t=1:min(nr,nc)
                if any(SR(t,:))
                    jj=jj+1;
                    good(jj) = t;
                end
            end
            msr(dil, :) = mean(SR(good,:),1);
            ser(dil, :) = std(SR(good,:),0, 1)/sqrt(length(good));
            shadedErrorBar(timesr, msr(dil,:), ser(dil,:), {'color', 'k'},1)
        end
        ylim([0 max(max(msr))+30])
        set(gca, 'fontsize', 16)
        %         xlim([0 4])
        clear good
    end

% 5. @savecurrplotcallback
    function savecurrplotcallback(~,~)
    % allows saving the trace as displayed in the main figure

        figure(111);
        SPKAcurr = zeros(L,1);
        SPKBcurr = zeros(L,1);
        %         Vcurr = butter_filter(Vcurr, 70, 1000, deltat, 1, 3);
        tSP = tSPKA(currdata(1),currdata(2),:);
        tSP(tSP==0)=[];
        SPKAcurr(tSP)=Vcurr(tSP);
        tSP = tSPKB(currdata(1),currdata(2),:);
        tSP(tSP==0)=[];
        SPKBcurr(tSP)=Vcurr(tSP);
        pSPKAcurr = SPKAcurr; pSPKBcurr = SPKBcurr; pSPKAcurr(SPKAcurr == 0) = NaN; pSPKBcurr(SPKBcurr ==0) =NaN;
        subplot(2,1,2)
        plot(time, Vcurr, 'k', time, pSPKAcurr, 'or', time, pSPKBcurr, 'ob')
        subplot(2,1,1)
        plot(time, pidcurr, 'k')
    end


end

