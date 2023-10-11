clear all; clc; %close all;

nRep = 1000;
nBytes = 6;
s = serial('COM4','BAUD',19200,'Terminator','LF');
t = nan(nRep,1);
data = nan(nRep,6);

% Initialize
fopen(s);
test1 = fscanf(s);
test2 = fscanf(s);
b = s.BytesAvailable;
flushinput(s);
% pause(1);
tic
% try
%     for i = 1:nRep
% %         b = s.BytesAvailable;
%         test = fscanf(s);
%         t1(i) = toc;
% %         fprintf('t:%3.4f %i (%i): %s',toc,i,b,test);
%     end
% 
%     for i = 1:nRep;
%         b = s.BytesAvailable;
%         test = fscanf(s);
%         t2(i) = toc;
% %         fprintf('t:%3.4f %i (%i): %s',toc,i,b,test);
%     end
%     
    for i = 1:nRep
        b = s.BytesAvailable
%         flushinput(s);
        sc = fscanf(s);
        t(i) = toc;
        if length(sc) == nBytes + 2
        x = double(sc);
        data(i,1) = x(1) * 255 + x(2); % lever
        x(3) = x(3) - 100;
        data(i,2) = floor(x(3)/10);
        data(i,3) = mod(x(3),10);
        data(i,4:6) = x(4:6);        
        end
        fprintf('t:%3.4f %i lev=%i l1=%i l2=%i x=%i y=%i z=%i\n',toc,i,data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6));
    end
    
    fclose(s);
% catch
%     fclose(s);
% end


figure; plot(t,data); title(['SR=' num2str(1/nanmean(diff(t)))])
%%
% figure; plot(t,lowPassFilterButter(data,0.1,1,2))
