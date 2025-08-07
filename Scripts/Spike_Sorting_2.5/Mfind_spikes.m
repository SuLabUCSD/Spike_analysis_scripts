function [X] = Mfind_spikes(X, Tnoise, t)
%% t is the refractory time in steps of deltat  

L = length(X);
signal = X;        
X(L)=0;

X(X>=Tnoise)=0;
X(diff(X)<0)=0;

% find putative spikes considering refractory period
s = find(X<0);
if ~isempty(s)
    last_value = s(1);
    for i=2:length(s)
        if(s(i)-last_value<t)
            if(X(s(i))>=X(last_value))
                X(s(i))=0;
            else
                X(last_value)=0;
                last_value=s(i);
            end
        else
            last_value = s(i);
        end
    end

    X0 = X(1:t)';
    X(1:t)=[];
   
else
    X0 = X(1:t);
    X(1:t)=[];
end


end
            
            
        




