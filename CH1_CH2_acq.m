% To acquire single data from the DSO.
clear all
clc

%Connecting DSO
DSO = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x05FF::0x1023::3517N53447::0::INSTR', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(DSO)
    DSO = visa('NI', 'USB0::0x05FF::0x1023::3517N53447::0::INSTR');
else
    fclose(DSO);
    DSO = DSO(1);
end

% Create a device object.
deviceObj = icdevice('lecroy_basic_hr_driver.mdd', DSO);

% Connect device object to hardware.
connect(deviceObj);
fprintf("\n DSO Connected \n");
get1 = get(deviceObj.Acquisition(1), 'Timebase');
% address to save files.
address='E:\Ankur\MATLAB\TOF_data\Change_tof';

file='ytest.txt';
filename1=strcat(address,'\CH1_',file);
data1=acq_DSO_CH_data(deviceObj,1);
writematrix(data1,filename1);

filename2=strcat(address,'\CH2_',file);
data2=acq_DSO_CH_data(deviceObj,2);
writematrix(data2,filename2);

figure(1)
plot(data1);hold on;
plot(data2); hold off;

clear groupObj;
clear deviceObj;
clear DSO;
