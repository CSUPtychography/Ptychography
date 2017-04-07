function [allimages] = LCchat(arduino,x,xmax,y,ymax,passes)
%calculate how high I should go(maybe do this in arduino code and pass to
%here instead through serial)
%%j = (xmax-x)*(ymax-y)*passes;
j = 100;
for i = 1:j
    out = serialpass(arduino,trigger,x,y); %returns whether or not the LED was triggered
    if out == 1                            %test if Led was triggered
        images{x,y} = takephoto(vid);        %returns the image for array x,y
    else
        i = i-1;                            %re-triggers the LED to switch
    end
    x = x+1;
    y = y+1;
end
end