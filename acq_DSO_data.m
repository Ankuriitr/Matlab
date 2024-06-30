function [data]= acq_DSO_data(deviceObj)
groupObj = get(deviceObj, 'Waveform');
set(deviceObj.Waveform(1), 'Precision', 'int16');
[Y,X,~,~,~] = invoke(groupObj,'readwaveform','channel1'); %        [Y,X,YUNIT,XUNIT,HEADER]
data=[X',Y'];
end