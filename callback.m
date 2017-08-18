function callback(obj, event) 

global out_ascii
global left_ascii % �Ӵ��ڶ�ȡ��һ��������֡�����µĲ���
global plot_count
global savefile
global frame_count
global frame_dot
global sampleRate
global edgeAdot
global edgeBdot


readCount = frame_dot;
out_ascii = fread(obj, readCount, 'uint8'); %ascii

% ����ԭʼascii������
% fid=fopen([savefile, '_ascii.txt'],'a+'); 
% fprintf(fid,'%3d ',out_ascii); 
% fclose(fid); 

% history = [history; out_ascii];
out_ascii = out_ascii';
out_ascii = [left_ascii, out_ascii];

%ɾ���س���
loc10 = find(out_ascii == 10);
for j=length(loc10):-1:1
    out_ascii(loc10(j)) = [];
end


loc13 = find(out_ascii == 13); %�ҵ����з������з�����֡���ݵķָ������з������ж����
if isempty(loc13)              %���޻��з���˵����ǰ֡δ�������
    left_ascii = out_ascii;
else                           %���л��з���˵����ǰ֡�������
    left_ascii = out_ascii(loc13(end)+1 : end);
    
    
    for j = 0:length(loc13)-1
        
        if j == 0
            frame_ascii = out_ascii(1:loc13(1)-1);%��һ֡
        else
            frame_ascii = out_ascii(loc13(j)+1 : loc13(j+1)-1);%��һ֡�����֡
        end
        
        while frame_ascii(1) == ','
            frame_ascii(1) = [];
        end
        while frame_ascii(end) == ','
            frame_ascii(end) = [];
        end
        frame_char = char(frame_ascii);
        frame_cell = regexp(frame_char, ',', 'split');
        frame_num = str2double(frame_cell);
        
        if length(frame_num) == frame_dot %��ʼ����ʱ������
            frame_count = frame_count + 1;
%             display(['frame count:',num2str(frame_count), '    frame length: ',num2str(length(frame_num))])
            
            plot_count = plot_count+1;
            if plot_count == floor(sampleRate/3); 
                frame = frame_num(1:frame_dot-1);            
                data = reshape(frame, edgeAdot, edgeBdot);                
                bar3(data)
                axis([0 edgeAdot+1 0 edgeBdot+1 0 4096])  
                plot_count = 0;
            end
            
            fid=fopen([savefile, '.txt'], 'a+'); 
            fprintf(fid,'%3d ',frame_num); 
            fclose(fid); 
        else 
            nan_count = 0;
            for h = 1:length(frame_num)
                if isnan(frame_num(h))   
                    nan_count = nan_count + 1;
                end
            end
            display(['nan count: ',num2str(nan_count),'   frame length: ',num2str(length(frame_num)), '---'])
        end
    end
end   
end




%  ���s.BytesAvailableFcnCount < fread(obj,readCount,'uint8')�е�readCount��
%  ��ô��������ֻ��s.BytesAvailableFcnCount������ʱ���ᵼ�¶��������ݡ�