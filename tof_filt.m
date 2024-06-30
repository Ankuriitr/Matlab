% This code is written by Ankur, DD imaging Lab, IIT Roorkee.
% Date: 30/09/2022
% To filter the time of flight component in ultrasound signal.
% This filter is designed to filter signal having sampling frequency 50002.
% 07/10/22 Modified for any number of samples but for signals having
% similar TOF data.


function [amp_filtered]=tof_filt(input_signal,N_samples)
filt=designfilt('lowpassfir', 'PassbandFrequency', 50002*.01/N_samples, 'StopbandFrequency', 50002*.03/N_samples, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
amp_filtered=filter(filt,input_signal);
end