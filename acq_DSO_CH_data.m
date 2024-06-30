function [data]= acq_DSO_CH_data(deviceObj,CH)
groupObj = get(deviceObj, 'Waveform');
set(deviceObj.Waveform(1), 'Precision', 'int16');
channel=strcat('channel',num2str(CH));
[Y,X,~,~,~] = invoke(groupObj,'readwaveform',channel); %        [Y,X,YUNIT,XUNIT,HEADER]
data=[X',Y'];
end