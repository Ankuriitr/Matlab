% This code is written by Ankur, DD imaging Lab, IIT Roorkee.
% Date 24/06/2022.
% Code to mark different peaks in the ultrasound wave signal and find amplitude of
% each. In this code we can select any no of peaks around the central peak
% of the wave packet. 
% Designed Low and High pass filter to remove noise from the ultrasound
% signal.
function [Amp]=ult_filter(data)
Amp=data(:,2);
filt=designfilt('highpassfir', 'PassbandFrequency', .02, 'StopbandFrequency', .01, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
% First filter.: To filter out the unwanted low freq high amplitude signal.
filt_signal=filter(filt,Amp);
filt2=designfilt('lowpassfir', 'PassbandFrequency', .01, 'StopbandFrequency', .05, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
Amp=filter(filt2,filt_signal);
end