% This code is written by Ankur, DD imaging Lab, IIT Roorkee.
% Date 24/06/2022.
% Code to mark different peaks in the ultrasound wave signal and find amplitude of
% each. In this code we can select any no of peaks around the central peak
% of the wave packet. 

% Loading the input file.
filename='D:\Ankur Research Data\Ultrasound_testing\Offcentre_air1.5Mhz40x40\5_6_38'; % 5_29_33
data= readmatrix(filename);
Amp=data(:,2);
time=data(:,1);
L = length(data);             % Length of signal
dt=abs(time(1)-time(2));
font_size=20;
filt=designfilt('highpassfir', 'PassbandFrequency', .02, 'StopbandFrequency', .01, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
fs=1/dt;
fft_signal=abs(fft(Amp));
freq=linspace(0,fs,L);
freq=normalize(freq,'range');
freq=freq';

% First filter.: To filter out the unwanted low freq high amplitude signal.
filt_signal=filter(filt,Amp);
filt_signal_fft=abs(fft(filt_signal));

fvtool(filt);

% secind filter: To filter out high freq noise.

filt2=designfilt('lowpassfir', 'PassbandFrequency', .01, 'StopbandFrequency', .05, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
filt_signal2=filter(filt2,filt_signal);

fvtool(filt2);

figure(1)
subplot(2,2,1)
plot(time,Amp);
xlabel('Time(s)');
ylabel('Amplitude(V)');
title('Initial Signal');
set(gca,'fontsize',font_size);

subplot(2,2,2)
plot(freq,fft_signal);
title("Filtered Signal FFT");
xlabel('Time(s)');
ylabel('Amplitude(V)');
set(gca,'fontsize',font_size);

subplot(2,2,3)
plot(time,filt_signal);
title("Detrended Signal"); %Detrended Signal
xlabel('Time(s)');
ylabel('Amplitude(V)');
set(gca,'fontsize',font_size);

subplot(2,2,4)
plot(freq,filt_signal_fft)
title("Filtered Signal FFT");
xlabel('Time(s)');
ylabel('Amplitude(V)');
set(gca,'fontsize',font_size);

figure(2)
plot(time,filt_signal2);
title("Filtered Signal");
xlabel('Time(s)');
ylabel('Amplitude(V)');
set(gca,'fontsize',font_size);
% % Laplace transform of the input.
% input_laplace=fft(input);
% 
% % Z transform of the input.
% input_z=fft(input);