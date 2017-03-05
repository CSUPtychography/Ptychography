function[Ard,flag] = serialsetup(comPort)
% Save the serial port name in comPort variable.
%comPort = '/dev/tty.usbmodem411';
% flag value - check if/when the script is completed
flag = 1;
%initializing
Ard = serial(comPort);
set(Ard,'DataBits',8);
set(Ard,'StopBits',1);
set(Ard,'BaudRate',9600);
set(Ard,'Parity','none');
fopen(Ard);
a = 'b';
while (a~='a') 
    a=fread(Ard,1,'uchar');
end
if (a=='a')
    disp('Serial read');
end
fprintf(Ard,'%c','a');
mbox = msgbox('Serial Communication setup'); 
uiwait(mbox);
fscanf(Ard,'%u');
end
