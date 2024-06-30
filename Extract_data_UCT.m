% To extract data from the UCT when files are in reverse order for
% alternate rotation.
function [Normal_Proj_Data,optimal_N_packets_Values,j_opt]=Extract_data_UCT(file_Address,N_packets,max_rot,num_peak,N_translation,N_rot,start_angle)
% file_Address;
% N_packets=3;
% max_rot=360;
% num_peak=10;
% N_translation=25;
% N_rot=20;
% start_angle=0;
N_det=N_translation;
nGle=(max_rot-start_angle)/N_rot;%angle of rotation
cd(file_Address);
F=dir('*.csv');
% To obtain a single file of complete data.
% for i=1:length(F)
%     i;
%     file=F(i).name;
%     pulsedata=xlsread(file);
%     Amp(:,i)=pulsedata((6:end),2);
% end
% [N_rows,N_columns]=size(Amp);
pulsedata=xlsread(F(1).name);
time=pulsedata((6:end),1);
k=0;
for i=start_angle:nGle:max_rot-nGle    
    for j0=1:1:N_det                      %To find optimal values for each translation data.
        file=F(k*N_det+j0).name;
        pulsedata=xlsread(file);
        Amp=pulsedata((6:end),2);
        [N_rows,N_c]=size(Amp);
        Length_of_Single_Packet=fix(N_rows/N_packets)-1;
        for j=1:N_packets
            %             [k2,j0,j,(j-1)*Length_of_Single_Packet+1,j*Length_of_Single_Packet,Length_of_Single_Packet,length(Amp),length(time)]
            
            D=Amp((j-1)*Length_of_Single_Packet+1:j*Length_of_Single_Packet);
            T=time((j-1)*Length_of_Single_Packet+1:j*Length_of_Single_Packet);
            
            %D=Amp(j+(j-1)*Length_of_Single_Packet:j*Length_of_Single_Packet);%Took the indices containing one packet at a time.
            
            %leveling the slantness in data
            D=D-mean(D);
            
            %obtaining peaks
            [~,locs1]=findpeaks(D.*-1);          %trough ,'minpeakprominence',20
            [~,locs2]=findpeaks(D);              %peak     'minpeakprominence',20
            peak=D(locs2);time_peak=T(locs2);
            trough=D(locs1);time_trough=T(locs1);
            
            %assending order peak sorting
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
            %             if image==1
            [size(T),size(D),size(time_peak),size(peak),size(time_trough0),size(trough0),];
            figure(1);plot(T,D);hold on;plot(time_peak,peak,'or','markersize',5);hold on;plot(time_trough0,trough0,'sk');
            ylabel('Amplitude (V)');xlabel('Time (Sec.)');
            set(gca,'fontsize',20);
            %                 pause(0.01);
            %             end
            
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
            clear('trough','time_trough','D','T','time_peak','peak','time_trough0','trough0','locs1','locs2');
            
        end
        clf(figure(1));
        %CLT
        [j_opt0]=Central_Limit_theorem(mag_peak);
        j_opt(k+1,j0)=j_opt0;
        optimal_N_packets_Values(k+1,j0,:)=mag_peak(j_opt0,:);%peak values  from optimal N_packet of ith rotation and j0th translation
        Normal_Proj_Data(k+1,j0)=max(mag_peak(1,:));%peak values  from First N_packet of ith rotation and j0th translation
    end
    k=k+1;
end
save data.mat

end
%         for i=1:N_columns-1
%             figure(1);
%             plot(time,data(:,i+1));
%
%             pause(1);
%         end