
function xbf = butter_filter(x, fmin, fmax, deltat, ord1, ord2)

nu=1/(2*deltat); % sampling frequency 

if (fmin>0)
    [b,a] = butter(ord1,fmin/nu,'high');
    Hd = dfilt.df2t(b,a);     % Direct-form II transposed
    z = filter(Hd,x);         %   structure
else
    z=x;
end

if fmax<nu
    [b1,a1] = butter(ord2,fmax/nu,'low');
    Hd1 = dfilt.df2t(b1,a1);     % Direct-form II transposed
    xbf = filter(Hd1,z);         %   structure
else
    xbf = z;
end
