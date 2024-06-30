%% Instrument Connection

% Find a VISA-USB object.
obj1 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0xF4EC::0xEE38::SDG2XCAD2R3765::0::INSTR', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = visa('NI', 'USB0::0xF4EC::0xEE38::SDG2XCAD2R3765::0::INSTR');
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);

%% Instrument Configuration and Control

% Communicating with instrument object, obj1.
data1 = query(obj1, '*IDN?');
%% Set Wave parameters for the instrument.USING QUERY fn. 
%value of rise, fall time,pulse width should be in sec.
%Units of freq in Hz, Amplitude in V.
%To set output on, C1:OUTP ON
d2=fprintf(obj1,'C1:BSWV WVTP,PULSE');% USE frpintf instead of query, fprintf is fast.
d3=fprintf(obj1,'C1:BSWV FRQ,1500000');
d4=fprintf(obj1,'C1:BSWV AMP,15');
d5=fprintf(obj1,'C1:BSWV RISE,0.0000000104');
d6=fprintf(obj1,'C1:BSWV RISE,0.0000000084');
d7=fprintf(obj1,'C1:OUTP OFF');
d8=query(obj1,'C1:BSWV?');
data16 = query(obj1, 'C1:BSWV?');
fclose(obj1);

