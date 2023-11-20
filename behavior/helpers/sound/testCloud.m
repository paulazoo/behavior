clear all;

freq = [4000 12000];
rateList = [0.0 0.05 0.1 0.2 0.4];
pedestal = rateList(1:end-1);

for i=1:length(pedestal)
    x = [rateList(i:end)' pedestal(i)*ones(size(rateList(i:end)))']
    x(x(:,1) == x(:,2),:) = []; % remove pedestal point as they will be hard  to interpret in a go no/no-go
    sortedRate{i} = [flipud(x); fliplr(x)];
end

%%
% 
% x1 = repmat(rateList,1,length(rateList))';
% x2 = repmat(rateList,length(rateList),1);
% x2 = x2(:);
% rateList = [x1 x2];
% rateList(rateList(:,1) == rateList(:,2),:) = [];
% [~,iSort] = sort(diff(rateList,[],2));
% % rateList = rateList(iSort,:);
% for i = 1:length(pedestal)
%     sortedRate{i} = rateList(any(rateList == pedestal(i),2),:)
% end

% rateList = [
%     0.4 0
%     0.2 0
%     0.1 0
%     0.05 0
%     0 0.05
%     0 0.1
%     0 0.2
%     0 0.4
%     0.4 0.05
%     0.2 0.05
%     0.1 0.05
%     0.05 0.1
%     0.05 0.2
%     0.05 0.4
%     0.4 0.1
%     0.2 0.1
%     0.1 0.2
%     0.1 0.4
%     0.4 0.2
%     0.2 0.4];
%%
[snd,soundParams] = soundInitCloud;
for i = 1:size(rateList,1)
    [s,sequence] = soundCloudStim(freq,rateList(i,:),soundParams);
    snd.buffers = PsychPortAudio('CreateBuffer', snd.pahandle, s);
    fprintf('Playing freq1 = %1.2f freq2 = %1.2f\n',rateList(i,1),rateList(i,2));
    soundPlay(1,snd);
    pause(2);
end
soundClean(snd);

