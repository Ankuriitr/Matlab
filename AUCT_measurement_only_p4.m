%This code is written by Ankur Kumar, DD Imaging Lab, Physics, IIT Roorkee
%It controls two stepper motors, a DSO, and Wave generator.
%The stepper motors are controlled via Arduino.
%This code perform the 2D Ultrasound CT scanning measurement only of the object.
%function [scan_time,Exp_loc,filename]= ScanUCT(file_address,Exp_name,N_packets,distance,ard_port,wave_type,freq,amplitude,rise_time,fall_time,N_rot,N_translation)


clear all 
close all
clc
code_start_time=tic;
delete(instrfindall); % it is a good practice that we call this
% INPUT
cd('E:\Ankur\MATLAB\Auto_Scan_reconst');
file_address='E:\Ankur\MATLAB\Auto_Scan_reconst';
Exp_name='Model_Square1';
N_packets=7;
distance=30;  %in mm.
ard_port='COM5';
freq=1500000;
amplitude=20;
N_rot=20;
N_translation=40;

wavetype='PULSE';
rise_time=0.0000000104;
fall_time=0.0000000084;
pulse_width=0.0000000290;

scp=0; % set this 0 for manual positioning of the starting scanning point.
%

% file_address="E:\Ankur\MATLAB\UCT_Matlab_test"; %All data will be saved here.
[status, message] = mkdir(Exp_name);
if ~status
    sprintf('Failed to create folder because %s\n', message);
    %get out of while loop
end
new_address=strcat(file_address,'\',Exp_name);
Exp_loc=new_address;

%Connecting Arduino
% here we define the main communication parameters
arduino=serial(ard_port,'BaudRate',9600,'DataBits',8);

% Comments: We create a serial communication object on port COM4
% in your case, the Ardunio microcontroller might not be on COM4, to
% double check, go to the Arduino editor, and on click on "Tools". Under the "Tools" menu, there
% is a "Port" menu, and there the number of the.......... communication port should
% be displayed

% Define some other parameter, check the MATLAB help for more details
InputBufferSize = 8;
Timeout = 0.1;
set(arduino , 'InputBufferSize', InputBufferSize);
set(arduino , 'Timeout', Timeout);
set(arduino , 'Terminator', 'CR');
% Now, we are ready to go:

fopen(arduino); % initiate arduino communication
fprintf(" Arduino Connected \n");
% Connecting Wave Generator
wavegen = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0xF4EC::0xEE38::SDG2XCAD2R3765::0::INSTR', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(wavegen)
    wavegen = visa('NI', 'USB0::0xF4EC::0xEE38::SDG2XCAD2R3765::0::INSTR');
else
    fclose(wavegen);
    wavegen = wavegen(1);
end

% Connect to instrument object, obj1.
fopen(wavegen);
fprintf(" \n Wave Generator Connected  \n");
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

time(1)=toc(code_start_time);     % Time to establishing connection to all the instruments.
%  Calculations to select the timebase according to the wavepackets.
period=1/freq;
tim_div=N_packets*period/10;
set(deviceObj.Acquisition(1), 'Timebase', tim_div);
% Set Wave parameters for the instrument.USING QUERY fn.
%value of rise, fall time,pulse width should be in sec.
%Units of freq in Hz, Amplitude in V.
%To set output on, C1:OUTP ON
%data1 = query(wavegen, '*IDN?');
data2 = query(wavegen, '*RST');
input_parameters=strcat('C1:BSWV WVTP,',wavetype,',FRQ,',num2str(freq),',AMP,',num2str(amplitude),',WIDTH,',num2str(pulse_width),',RISE,',num2str(rise_time),',FALL,',num2str(fall_time));
fprintf(wavegen,input_parameters);
fprintf(wavegen,'C1:OUTP ON');
wave_data=query(wavegen,'C1:BSWV?');
fclose(wavegen);

% Correcting the N_packets according to the output from the DSO. As it cant set
% timebase in desired way.
get1 = get(deviceObj.Acquisition(1), 'Timebase');
N_packets=round(get1*10/period);

%Calculations required to set the various parameters.
% Input Data: Direction, Distance and Speed.
%distance= object will move within this displacement.
% N_rot=4;   %No. of projections
speed=900;    %fix 550 for smooth movement    upper limit 1000.
direction=1;  %0 for Translation towards the stepper motor.
tmp_speed=2500-speed;  %Delay in each step. Inversely proportionl to speed.
one_mm_steps=200;      %Stepper steps in one mm movement.
%During Rotation, there shouldnt be any translational motion and vice-versa
no_translational_steps=0;
no_rotational_steps=0;

comb_sp_daq_act_time=tic;
%Calculations required to set the various parameters.
% Input Data: Direction, Distance and Speed.
% distance=10;          %distance= object will move within this displacement.
dis_step_size=distance/N_translation;
nGle=360/N_rot;

total_steps_dist=round(one_mm_steps*distance);  % Rounding to avoid the unexpected movement.
total_steps_rot=1600;                     %Total stepper steps in one rotation.


%Calculating the no. of steps according to the distance(in mm).
%The threaded rod used have a pitch of 8mm/turn.
%Also the stepper motor is moving 1600 steps per turn. steps in one rotation=1600;
step_size_rotation=round(total_steps_rot/N_rot);   % # stepper steps one in rotational step.
num_translation_steps=total_steps_dist/(one_mm_steps*dis_step_size);% Total no of translational steps in the distance.
step_size_translation=round(total_steps_dist/num_translation_steps);% # Stepper steps in one translational steps.

%To format data to be sent to arduino in proper form.
%direction = 1 char, steps= 4 char(rotation) + 4 char(translation) , speed= 4 char .

data_to_arduino_rotation=strcat(num2str(0),num2str(step_size_rotation,'%04d'),num2str(no_translational_steps,'%04d'),num2str(tmp_speed,'%04d'));

proj_data_all=[];
trans_loop_time=zeros(N_rot);
for rot=1:N_rot

    
    a=(-1)^(rot);
    if a==1
        direction=0;
    else
        direction=1;
    end
    i=1;proj_data=zeros(1,N_translation);
    data_to_arduino_translation=strcat(num2str(direction),num2str(no_rotational_steps,'%04d'),num2str(step_size_translation,'%04d'),num2str(tmp_speed,'%04d'));
    trans_loop_start_time=tic;
    for dis=0:dis_step_size:(distance-dis_step_size)
        fprintf(arduino,data_to_arduino_translation); %Send the data to arduino in the required format.
        pause(0.1);
        %         d2=fscanf(arduino,'%d')    % Translation #  =
        % Acquiring the data from DSO.
        data=acq_DSO_data(deviceObj);
        filename=strcat(new_address,'\',num2str(rot),'_',num2str(i),'.txt');
        writematrix(data,filename);
        i=i+1;
    end

    trans_loop_time(rot)=toc(trans_loop_start_time);
        
    fprintf(arduino,data_to_arduino_rotation);
    pause(.1);
    
end
time(2)=toc(comb_sp_daq_act_time);
data_to_arduino_rotation=strcat(num2str(1),num2str(1600,'%04d'),num2str(no_translational_steps,'%04d'),num2str(tmp_speed,'%04d'));
fprintf(arduino,data_to_arduino_rotation);  % To rotate the object to its initial position.
if rem(N_rot,2)==1
    % To move the object at initial position. Movement towards stepper
    % motor.
    data_to_arduino_translation=strcat(num2str(0),num2str(no_rotational_steps,'%04d'),num2str(distance*one_mm_steps,'%04d'),num2str(tmp_speed,'%04d'));
    fprintf(arduino,data_to_arduino_translation);
end

% Close the connected devices
fclose(arduino);
delete([deviceObj DSO]);
clear groupObj;
clear deviceObj;
clear DSO;
time(3)=toc(code_start_time);

% Saving timeing data.
trans_loop_file=strcat('E:\Ankur\P4_docs\Time_analysis\MATLAB\Measurement_only\','trans_loop_time',num2str(N_rot),'x',num2str(N_translation),'.dat');
writematrix(trans_loop_time,trans_loop_file);
time_code_parts_file=strcat('E:\Ankur\P4_docs\Time_analysis\MATLAB\Measurement_only\','code_parts_time',num2str(N_rot),'x',num2str(N_translation),'.dat');
writematrix(time,time_code_parts_file);  

%end