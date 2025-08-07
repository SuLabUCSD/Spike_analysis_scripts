function [V, filein_name, file_path, svalve, pid, deltat] = spike_sorting_loadfile(dataformat)
% modified by Srinivas to include data about the stimulus on and off times.
% 2011_10_11 modified by Carlotta to load PID measurements. 

if dataformat==1 %% matlab file
    [filein_name, file_path] = uigetfile('*.mat','Select the data file');
    if filein_name~=0
        hw = waitbar(0.2, 'Loading data...');
        F = load([file_path filein_name]);
        deltat = F.deltat;  
        V = F.ORN;
%         V(1,:,:) = F.ORN_back;


        if isfield(F, 'PID') 
            pid = F.PID;
%             pid(1,:,:) = F.PID_back;
        else
            pid=[];
        end

        if isfield(F, 'stimsignal')
            % there is a stimulus for each trial
            if size(F.stimsignal,1)>1
                Stim = F.stimsignal;
            
            % there is only one stimulus for all traces
            else
                stim1(1,1,:)=F.stimsignal;
                %             stim1(1,1,:)=F.stim_back;
                Stim = repmat(stim1, [size(V,1),size(V,2),1]);
            end
        else
            svalve = []; % couldn't find the stim signal
        end

        % normalise and digitise signal
        Stim = round(Stim);
        Stim = Stim/max(max(max(Stim)));
        dstim = diff(Stim,1,3);
        % find all the on times, all the offtimes and return those
        % instead of returning the whole Stim matrix
        waitbar(0.8,hw, 'Finding on and off times for stimuli...')
        sds = size(Stim);

        svalve(sds(1),sds(2)).ton = [];
        svalve(sds(1),sds(2)).toff = [];
        for i = 1:sds(1)
            for j = 1:sds(2)
                svalve(i,j).ton = find(dstim(i,j,:)>0)*deltat;  % in seconds
                svalve(i,j).toff = find(dstim(i,j,:)<0)*deltat; % in seconds
            end
        end
    else
        svalve = []; % couldn't find the stim signal
    end
    waitbar(1,hw, 'DONE')
    close(hw)


elseif dataformat==2 %% Customized format
    disp('no available custom format')
end

end