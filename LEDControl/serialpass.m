function [output] = serialpass(s,trigger,x,y)
fprintf(s,trigger);
mbox = msgbox('Next Led Triggered');
uiwait(mbox);
output = fscanf(s,'%f');
end
