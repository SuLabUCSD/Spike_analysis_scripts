function [spk] = spiketime2spk(sp, maxtime)

trials = size(sp,1);
spk = zeros(trials, maxtime);
for t = 1:trials
    times = sp(t,:);
    times(times==0)=[];
    spk(t,times)=1;
end

end

