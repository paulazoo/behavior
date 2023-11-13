function fname = getfnamelist(path)
if nargin < 1;
    path = pwd;
end
r = dir(path);
j = 1;
fname = {};
for f = 1:length(r)
    if length(r(f).name) > 4 && ~strcmp(r(f).name,'.DS_Store')
        fname{j} = r(f).name;
        j = j+1;
    end
end