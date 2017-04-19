function MFOBJECT = MedianFilter(directory)
newdirectory = datestr(now,'yyyy-mm-dd_HH-MM-SS');
mkdir(newdirectory);
fileformat = 'F-image-x%d_y%d';
fullformat = strcat(newdirectory,'/',fileformat);
for i = 1:15
    for j = 1:15
prefiltered = load(fullfile(directory,sprintf(fileformat,i,j));
postfiltered = medfilt2(prefilitered);
save(sprintf(fullformat,ImageArrayX,ImageArrayY),'postfiltered');
figure(1)
subplot(1,2,1)
imagesc(prefiltered)
subplot(1,2,2)
imagesc(postfiltered)
pause(.0001)
    end
end
end
