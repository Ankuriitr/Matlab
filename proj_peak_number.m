% This code is written by Ankur, DD imaging Lab, IIT Roorkee.
% Date 24/06/2022.
% Code to mark different peaks in the ultrasound wave signal and find amplitude of
% each. In this code we can select any no of peaks around the central peak
% of the wave packet.
% 27/06/2022
% It return the peak amplitude specified by the input index od the peak, central peak is considered the median peak.
% It take the mean of the final amplitudes with outliers removed.
% filename: name of the data file
% Select trend ==1 if you see significant trend in the data.
% NOTE: Selecting the trend slowdown the timing efficiency.

function [proj]=proj_peak_number(filename,freq,num_peak,peak_num,trend)
% input
threshold_bound=20; % greater than positive average
MPD=20;
image=1;
color1=[.2 0.8470 0.3410];      % For multiSample.
color2=[0.4660 0.2740 0.1080];      % For Rubber3M.
font_size=16;leg_font_size=12;
% To read data.
data= readmatrix(filename);
Amp=data(:,2);
Amp=ult_filter(data); % To filter out the ultrasound signal.
Amp_original=data(:,2);
time=data(:,1);
samplingfreq=1/abs(time(1)-time(2));
len_amp=length(Amp);
packet_len=1/freq*samplingfreq;
N_packets=fix(len_amp/packet_len)
env_MPD=.7*length(Amp)/N_packets;

% Detrending the signal
if trend==1
    opol = 20;
    [p,~,mu] = polyfit(time,Amp,opol);  % fit the data.
    f_y = polyval(p,time,[],mu);        % generate the ploynomial to subtract.
    
    Amp1 = Amp - f_y;
    Amp=Amp1;
end

if image==1
    % Plotting the initial data.
    h1=figure(1);
    subplot(2,2,1)
    plot(time,Amp_original);
    xlabel('Time(s)');
    ylabel('Amplitude');
    title('Acquired Signal');
    set(gca,'fontsize',font_size);
    h1.Position=[300,200,1300,800];
end
[up, lo]=envelope(Amp,200,'peak');

% Searching the rough peaks, then applying the threshold minimum to find
% peaks again.
MPD_1=round(.8*env_MPD);
[~, peak_rough]=findpeaks(up,'MinPeakDistance',MPD_1);
threshold_env_peaks=mean(Amp(peak_rough));
for i=1:length(peak_rough)-1
    dis_rough(i)=peak_rough(i+1)-peak_rough(i);
end
[~,index_rough]=sort(dis_rough); % Sorting the peaks distance in increasing order.
% Applying the logic that the distance between the actual peak is in narrow
% range approximately equal to 1/freq*samplingfreq.
% retaining only the peaks that should be in the signal.
index_rough_new=[];
count=1;
for a=1:length(dis_rough)-1
    if dis_rough(a)>.9*packet_len
        ind=index_rough(a);
        index_rough_new(count)=ind;
        count=count+1;
    end
end

% Contains the original peak only. For averaging the amplitude.
peak_rough_new=peak_rough(index_rough_new);
th_peak_env=.7*mean(up(peak_rough_new)); % Peak should have the value atleast above this threshold.
if image==1
    subplot(2,2,2)
    plot(time,Amp);hold on;plot(time,up);hold on;plot(time,lo);hold on;plot(time(peak_rough),up(peak_rough),'s','linewidth',1.1);hold on;
    plot(time(peak_rough_new),up(peak_rough_new),'<','linewidth',1.2);hold off;
    xlabel('Time');
    ylabel('Amplitude');set(gca,'fontsize',font_size);
    title("Detrended & Filtered Signal");
    set(gca,'fontsize',font_size);
    leg=legend("Signal","Upper Envelope","Lower Envelope","Rough Peaks","New Rough Peaks");
    set(leg,'FontSize',leg_font_size);
end
% Dynamic searching for the location of the wave packets.
% Enveloping the signal to divide the signal into given number.
% finding the peaks of the positive envelop. Searching for the peaks equal
% to number of the packets.
[~, peak_env]=findpeaks(up,'MinPeakHeight',th_peak_env,'MinPeakDistance',env_MPD);

if image==1
    subplot(2,2,3)
    plot(Amp);hold on;plot(up);hold on;plot(lo);hold on;plot(peak_env,up(peak_env),'s','linewidth',1.3);hold off;
    xlabel('Time Index');
    ylabel('Amplitude');
    title('Signal with envelope peaks');
    leg=legend('Signal','Upper envelope','Lower envelope','Peaks');
    set(leg,'FontSize',leg_font_size);
    set(gca,'fontsize',font_size);
end


% Checking if the first packet have enough peaks.
dis_env_peaks=zeros(length(peak_env)-1,1);
for i=1:length(peak_env)-1
    dis_env_peaks(i)=peak_env(i+1)-peak_env(i);
end
mean_dis1=mean(dis_env_peaks);
peak_vicinity=round(2*mean_dis1/N_packets);

if peak_env(1)<peak_vicinity
    peak_env=peak_env(2:length(peak_env));
end

if (length(Amp)-peak_env(end))<peak_vicinity
    peak_env=peak_env(1:length(peak_env)-1);
end
% Corrected N_packets.
N_packets=length(peak_env);
mag_peak=zeros(num_peak,N_packets);
threshold_pos=(threshold_bound/100+1)*pnmean(Amp,1);
threshold_neg=(threshold_bound/100+1)*pnmean(Amp,2);
for j=1:N_packets
    j;
    % Locating the peaks in the first envelope then finding the corresponding troughs.
    % Peaks are located only near the maximum.
    test_data=Amp(peak_env(j)-peak_vicinity:peak_env(j)+peak_vicinity);
    test_time=time(peak_env(j)-peak_vicinity:peak_env(j)+peak_vicinity);
    [~,peak_locs]=findpeaks(test_data,'MinPeakHeight',threshold_pos,'MinPeakProminence',threshold_pos,'MinPeakDistance',MPD);
    
    % Considering peaks nearby to the max amp peak.
    [~,peak_loc_max]=max(test_data(peak_locs));
    % Sol1: Checking if the peak belong to the wavepacket or not. It may occur
    % when signal strength is low.
    peak_locs_temp=peak_locs;
    peaks_removed=0; % Store the number of peaks removed that comes before peak_locs_max.
    peak_loc_max_temp=10000;
    while (peak_loc_max+peaks_removed)-num_peak/2<1 || (peak_loc_max+peaks_removed+num_peak/2+1)>length(peak_locs)
        %comm='I m Here';
        % Now removing this peak and searching for another peak.
        peak_locs_temp=peak_locs_temp(peak_locs_temp~=peak_locs_temp(peak_loc_max));
        [~,peak_loc_max]=max(test_data(peak_locs_temp));
        if peak_loc_max_temp>peak_loc_max
            peaks_removed=+1;
        end
        peak_loc_max_temp=peak_loc_max;
    end
    peak_loc_max=peak_loc_max+peaks_removed;
    % End sol1
    %Sol2: In case number of peaks are smaller than num peak, this will result in
    %error
    peak_locs_modified=ones(num_peak,1);
    if length(peak_locs)<num_peak
        num_peak=length(peak_locs);
    end
    for i=1:num_peak
        peak_ind=peak_loc_max-fix(num_peak/2)+i;
        if peak_ind>0
            peak_locs_modified(i)=peak_locs(peak_ind);
        end
    end
    % To check the distance between successive peaks.
    distance_bw_peaks=zeros((length(peak_locs_modified)-1),1);
    for i=1:length(peak_locs_modified)-1
        distance_bw_peaks(i)=peak_locs_modified(i+1)-peak_locs_modified(i);
    end
    
    % To remove outliears and modify the peak in case the selected peak is
    % not from the wave packets.
    distance_bw_peaks1=rmoutl(distance_bw_peaks,50);
    tf=isempty(distance_bw_peaks1);
    if tf==1
        if (i+1)<length(peak_locs_modified)
            peak_locs_modified(i)=peak_locs_modified(i+1);
        else
            peak_locs_modified(i)=peak_locs_modified(i-1);
        end
    else
        distance_bw_peaks=distance_bw_peaks1;
    end
    
    avg_dis_bw_peaks=mean(distance_bw_peaks);
    min_diff_threshold=1/4*avg_dis_bw_peaks;
    
    trough_locs=ones(num_peak,1);
    ll=length(test_data);
    % searching trough individually near the peak.
    for i=1:num_peak
        i;
        st_index=peak_locs_modified(i);
        end_index=peak_locs_modified(i)+round(1.5*avg_dis_bw_peaks);
        [~,tr_locs]=findpeaks(-test_data(st_index:end_index),'MinPeakProminence',.5*abs(threshold_neg),'MinPeakDistance',MPD);
        if length(tr_locs)<=1
            [~,tr_locs]=findpeaks(-test_data(st_index:end_index),'MinPeakDistance',MPD);
        end
        % searching the nearest trough in forward manner. difference should be
        % minimum between the index of prak and trough.
        diff=zeros(length(tr_locs),1);
        for k=1:length(tr_locs)
            diff(k)=abs(peak_locs_modified(i)-st_index-tr_locs(k));
        end
        % The minimum difference should be more than 1/3 of the difference
        % between the two positive peaks.
        
        [min_index_tr,~]=min(diff(diff>min_diff_threshold));  % Condition for nearest favouarble trough.
        
        tf=isempty(min_index_tr);
        % trough with minimum distance.
        if tf==1
            trough_locs(i)=st_index+tr_locs(1);  % if above condition will not be satisfied. To keep the code running.
        else
            trough_locs(i)=st_index+min_index_tr;
        end

        
    end
    if image==1
        subplot(2,2,4)
        %plot(test_time,test_data);hold on; plot(test_time(peak_locs_modified(i)),test_data(peak_locs_modified(i)),'o');hold on; plot(test_time(trough_locs(i)),test_data(trough_locs(i)),'o');hold on;
        plot(test_time,test_data);hold on; 
        plot(test_time(peak_locs_modified),test_data(peak_locs_modified),'o','color',color1);hold on; 
        plot(test_time(trough_locs),test_data(trough_locs),'o','color',color2);hold on;
        plot(test_time(peak_locs_modified(peak_num)),test_data(peak_locs_modified(peak_num)),'ks','linewidth',1.3,'MarkerSize',6);hold on; 
        plot(test_time(trough_locs(peak_num)),test_data(trough_locs(peak_num)),'ks','linewidth',1.3,'MarkerSize',6);hold on;
        xlabel('Time(s)');
        ylabel('Amplitude');
        title("Processed signal");
        set(gca,'fontsize',font_size);
        leg=legend("Packet","All Peaks", "All troughs","Corrected Peaks");
        set(leg,'FontSize',leg_font_size);
    end
    % Finding the magnitude of amplitude.
    mag_peak(:,j)=test_data(peak_locs_modified)-test_data(trough_locs);
    
end
hold off;
proj_arr=mag_peak(peak_num,:);
% Finding the average transmitted amplitude by averaging out peaks and troughs and removing outliers.
proj_arr_ro=rmoutliers(proj_arr);
proj=mean(proj_arr_ro);

if proj<.5*mean(proj_arr)
    proj=.7*max(proj_arr);
end

end