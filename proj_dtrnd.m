%This code process the AUCT generated data to find the projection data of a single file.
% The proj_data values are peak to peak values with outliers removed.
% It take the mean of the final amplitudes.
% filename: name of the data file
% Select trend ==1 if you see significant trend in the data.
% NOTE: Selecting the trend slowdown the timing efficiency.
function [proj_data]=proj_dtrnd(filename,N_packets,num_peak,pulsedata,trend)
% i=0;
% cd('D:\Ankur Research Data\AUCT Data\DataF1Mhz\AL_WP5_f1MHz_NT35_NR35');
%
% N_packets=5;
% num_peak=10;
% pulsedata=0;
% filename='30_3.xls';
if pulsedata==0
    pulsedata=readmatrix(filename);
end
time=pulsedata((1:end),1);
Amp=pulsedata((1:end),2);
[N_rows,~]=size(Amp);
Length_of_Single_Packet=fix(N_rows/N_packets)-1;
trans_peak=zeros(1);trans_peak_time=zeros(1);trans_trough=zeros(1);trans_trough_time=zeros(1);
trans_ptp_trough1=[];trans_ptp_trough_time1=[];
% Some transmission data have noise only and does not contribute to
% the actual result. Discarding those signal files based on the
% amplitude difference.
% This code also checks if the data have trend.
% If significant trend found, signal is detrended.
% To check if the data have trend affecting the peak detection.
if trend==1
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
    if sum_pnmean>sum_pnmean1*2
        Amp=Amp1;
    end
end
%         if
for j=1:N_packets
    
    D=Amp((j-1)*Length_of_Single_Packet+1:j*Length_of_Single_Packet);
    T=time((j-1)*Length_of_Single_Packet+1:j*Length_of_Single_Packet);
    
    %obtaining peaks
    [~,locs1]=findpeaks(D.*-1);          %trough ,'minpeakprominence',20
    [~,locs2]=findpeaks(D);              %peak     'minpeakprominence',20
    peak=D(locs2);time_peak=T(locs2);
    trough=D(locs1);time_trough=T(locs1);
    
    %ascending order peak sorting
    [peak,index_peak]=sort(peak);
    time_peak=time_peak(index_peak);
    
    [trough,index_trough]=sort(trough);
    time_trough=time_trough(index_trough);
    
    %correction if peak size is different than expected
    if length(peak)-num_peak >1
        peak=peak(end-num_peak:end);
        time_peak=time_peak(end-num_peak:end);
        
    elseif length(peak)-num_peak ==0
        peak=peak;
        time_peak=time_peak;
        
    elseif length(peak)-num_peak <0 && length(peak) ~= 0
        %in case peaks in signal are less than the peak required, adding fake peaks for sake the code running
        for j3=(length(peak))+1:num_peak
            peak(j3)=0;time_peak(j3)=0;
        end
    end
    trough0=zeros(num_peak,1);
    time_trough0=zeros(num_peak,1);
    %Ascending order time sorting.
    [time_peak,time_peak_index]=sort(time_peak);
    peak=peak(time_peak_index);
    %synchronizing the peak and trough and locating trough in neighbour only
    %it taggs the time of a peak and looks trough with minimum time distance
    %with it in forward sense.
    for j2=1:length(time_peak)
        min_distan_peak_to_Trough=10000000000000;
        for j3=1:length(trough)
            if (time_peak(j2)-time_trough(j3)) < 0 %peak should come before than trough
                if abs(time_peak(j2)-time_trough(j3)) < min_distan_peak_to_Trough
                    min_distan_peak_to_Trough=abs(time_peak(j2)-time_trough(j3));
                    trough0(j2)=trough(j3);
                    time_trough0(j2)=time_trough(j3);
                end
            end
        end
    end
    %adding zeroes in the start and end of the trough0 so that if
    %trough01 can processed even when trough appear on starting or
    %ending index.
    %             trough0=[0;trough0;0];time_trough0=[0;time_trough0;0];
    trough0=[trough0;0];time_trough0=[time_trough0;0];
    [trans_peak0,trans_peak_loc0]=max(peak);
    trans_peak_time0=time_peak(trans_peak_loc0);
    %             trough01=trough0((trans_peak_loc0-1):(trans_peak_loc0+1));
    %             [trans_trough0,trans_trough_loc0]=trough0(trans_peak_loc0);
    trans_trough0=trough0(trans_peak_loc0);
    trans_trough_time0=time_trough0(trans_peak_loc0);
    % Finding the peak to peak value. Check the peak in neighbour for peak to peak amplitude. It
    % compare the peaks only in neighbour.
    %           trans_ptp_peak=trans_peak0;trans_ptp_peak_time=trans_peak_time0;
    if trans_peak_loc0<2
        trans_peak_loc0=2;
    end
    trans_ptp_trough0=trough0(trans_peak_loc0);trans_ptp_trough_time0=time_trough0(trans_peak_loc0); % Immediate trough in the forward direction.
    trans_ptp_trough1=trough0(trans_peak_loc0-1);trans_ptp_trough_time1=time_trough0(trans_peak_loc0-1); % Immediate trough in the backward direction.
    % Now comparing the amplitude of the troughs.
    if abs(trans_ptp_trough0)>abs(trans_ptp_trough1)
        trans_ptp_trough=trans_ptp_trough0;
        trans_ptp_trough_time=trans_ptp_trough_time0;
    else
        trans_ptp_trough=trans_ptp_trough1;
        trans_ptp_trough_time=trans_ptp_trough_time1;
    end
    
    %                         if image==1
    %             [size(T),size(D),size(time_peak),size(peak),size(time_trough0),size(trough0),];
    %                         figure(1);plot(T,D);hold on;plot(time_peak,peak,'or','markersize',5);hold on;plot(time_trough0,trough0,'sk');
    %                         hold on;
    %                         plot(trans_peak_time0,trans_peak0,'vg','markersize',6,'linewidth',1);hold on;
    %                         plot(trans_trough_time0,trans_trough0,'^y','markersize',6,'linewidth',1);
    % %                         plot(trans_ptp_peak,trans_ptp_peak_time,'vg','markersize',6,'linewidth',1);hold on;
    %                         plot(trans_ptp_trough_time,trans_ptp_trough,'^g','markersize',6,'linewidth',1);
    %                         ylabel('Amplitude (V)');xlabel('Time (Sec.)');
    %                         set(gca,'fontsize',20);
    %                         pause;
    %                         end
    %peak to Trough peak to peak difference
    if length(peak) < num_peak, num_peak = length(peak); end
    if length(trough0) < num_peak, num_peak = length(trough0); end
    
    for k1=1:num_peak
        %                 [i+1,j,k1]
        %                 [length(peak),length(trough0)]
        mag_peak(j,k1)=double(peak(k1)-trough0(k1));
        %since we are in short of info about which peak is transmission peak, we save num of peaks
        %we create sinogram based on all these peaks one by one to look
        %for confirmity with CLT and RMSE. The one with accuracy and
        %prescion and least error gives us transmission Peak.
    end
    trans_peak(j,1)=trans_peak0;trans_peak_time(j,1)=trans_peak_time0; % Peak is same for both methods.
    trans_trough(j,1)=trans_trough0;trans_trough_time(j,1)=trans_trough_time0;
    trans_ptp_trough2(j,1)=trans_ptp_trough;trans_ptp_trough_time2(j,1)=trans_ptp_trough_time;
    %           clear('trough','time_trough','D','T','time_peak','peak','time_trough0','trough0','locs1','locs2');
    mag_abs_peak(j,1)=trans_peak(j,1)-trans_ptp_trough2(j,1);
end
% Finding the average transmitted amplitude by averaging out peaks and troughs and removing outliers.
mag_abs_peak_ro=rmoutliers(mag_abs_peak);
proj_data=mean(mag_abs_peak_ro);

if proj_data<.5*mean(mag_abs_peak)
    proj_data=.7*max(mag_abs_peak);
end
% plot(time,Amp); hold on;plot(trans_peak_time,trans_peak,'vg','markersize',6,'linewidth',1);hold on;
% plot(trans_trough_time,trans_trough,'^r','markersize',6,'linewidth',2);hold on;
% plot(trans_ptp_trough_time2,trans_ptp_trough2,'^g','markersize',6,'linewidth',1);hold off;
% ylabel('Amplitude (V)');xlabel('Time (Sec.)');
%         pause;
% i=i+1;

% % To check the trend in the data.
%          figure(2)
%          plot(Amp);hold on;
%          plot(f_y);hold on;
%          plot(Amp1);hold off;

end