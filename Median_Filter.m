function MFOBJECT = Median_Filter(directory)
newdirectory = datestr(now,'yyyy-mm-dd_HH-MM-SS');
mkdir(newdirectory);
oldfileformat = 'image-x%d_y%d';
newfileformat = 'image-x%d_y%d';
oldfullformat = strcat(newdirectory,'/',oldfileformat);
newfullformat = strcat(newdirectory,'/',newfileformat);
for i = 1:15
    for j = 1:15
load(fullfile(directory,sprintf(oldfileformat,i,j)));
prefiltered = Image;
Image = medfilt2(prefiltered);
save(sprintf(newfullformat,i,j),'Image');
figure(1)
subplot(1,2,1)
imagesc(prefiltered)
subplot(1,2,2)
imagesc(Image)
pause(.0001)
    end
end
end
