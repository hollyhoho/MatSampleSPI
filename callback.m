function callback(obj, event) 

global out_ascii
global left_ascii % 从串口读取的一段数据组帧后留下的部分
global plot_count
global savefile
global frame_count
global frame_dot
global sampleRate
global edgeAdot
global edgeBdot


readCount = frame_dot;
out_ascii = fread(obj, readCount, 'uint8'); %ascii

% 保存原始ascii码数据
% fid=fopen([savefile, '_ascii.txt'],'a+'); 
% fprintf(fid,'%3d ',out_ascii); 
% fclose(fid); 

% history = [history; out_ascii];
out_ascii = out_ascii';
out_ascii = [left_ascii, out_ascii];

%删除回车符
loc10 = find(out_ascii == 10);
for j=length(loc10):-1:1
    out_ascii(loc10(j)) = [];
end


loc13 = find(out_ascii == 13); %找到换行符，换行符是两帧数据的分隔（换行符可能有多个）
if isempty(loc13)              %若无换行符，说明当前帧未传输完毕
    left_ascii = out_ascii;
else                           %若有换行符，说明当前帧传输完毕
    left_ascii = out_ascii(loc13(end)+1 : end);
    
    
    for j = 0:length(loc13)-1
        
        if j == 0
            frame_ascii = out_ascii(1:loc13(1)-1);%第一帧
        else
            frame_ascii = out_ascii(loc13(j)+1 : loc13(j+1)-1);%第一帧后面的帧
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
        
        if length(frame_num) == frame_dot %开始传输时有乱码
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




%  如果s.BytesAvailableFcnCount < fread(obj,readCount,'uint8')中的readCount，
%  那么当缓存中只有s.BytesAvailableFcnCount个数据时，会导致读不出数据。