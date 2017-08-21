% Usage example: spiread(5, 200, 'abc')

function spiread(com_num, sample_sec, sample_rate, savefilename, Adot, Bdot)

clc

global left_ascii
global plot_count
global savefile
global s 
global plotdata
global frame_count
global frame_dot
global sampleRate
global edgeAdot
global edgeBdot
edgeAdot = Adot;
edgeBdot = Bdot;
sampleRate = sample_rate;
left_ascii = [];
plot_count = 0;
frame_count = 0;
frame_dot = Adot*Bdot + 1;
plotdata = [];
savefile = savefilename;

global upperFlag
global lowerFlag
global left1Flag
global left2Flag
global left3Flag
global right1Flag
global right2Flag
global right3Flag
upperFlag = 0;
lowerFlag = 0;
left1Flag = 0;
left2Flag = 0;
left3Flag = 0;
right1Flag = 0;
right2Flag = 0;
right3Flag = 0;

com = ['COM', num2str(com_num)];
try
    s = serial(com);
catch
    error('wrong serial');
end

set(s,'BaudRate', 115200,'DataBits',8,'StopBits',1,'Parity','none','FlowControl','none');
s.BytesAvailableFcnMode='byte';   %�����¼�����Ϊ���ܴ���
s.InputBufferSize = 4016*32;    %���ý��ܻ�������СΪ5000���ֽ�
s.BytesAvailableFcnCount = frame_dot;    %ÿ�ν��ܵ�50������ʱ�򴥷��¼�
%���ݾ��飬������̫С�����ڴ������׳���


% s.BytesAvailableFcn = @callback_save_ascii;   %ָ�򴥷��¼�����
% s.BytesAvailableFcn = @callback_singledot; 
s.BytesAvailableFcn = @callback; 


fopen(s);
tic
pause(sample_sec);  
fclose(s);  
delete(s);  
clear s  
toc