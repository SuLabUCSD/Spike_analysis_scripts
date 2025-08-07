function [time, srate] = spike_rate(spk, deltat, win, sliding)

half_step = round(win/(2*deltat));
sliding = round(sliding/deltat);

[L, trials]=size(spk);

point = (1:sliding:L-sliding)+ half_step;
point(point>L-half_step)=[];

srate = zeros(length(point),trials);
for i=1:length(point)
    srate(i,:) = sum(spk(point(i)-half_step+1:point(i)+half_step,:))/(half_step*2*deltat);
end
% half_step*2*deltat
% figure
% plot(srate, 'o')
time = point*deltat;

end