    
function out=dtrnd(time,Amp)
pmean=pnmean(Amp,1);
    nmean=pnmean(Amp,2);
    sum_pnmean=pmean-nmean;
    opol = 20;
    [p,s,mu] = polyfit(time,Amp,opol);  % fit the data.
    f_y = polyval(p,time,[],mu);        % generate the ploynomial to subtract.
    
    Amp1 = Amp - f_y;
    % Only taking the positive amplitudes.
    pmean1=pnmean(Amp1,1);
    nmean1=pnmean(Amp1,2);
    sum_pnmean1=pmean1-nmean1;
    
%   Uncomment if it need to check the trend threshold.
%     if sum_pnmean>sum_pnmean1*2
%         Amp=Amp1;
%     end
    out=Amp1;
end