function plotims(images)

Ni = size(images,1);
Nj = size(images,2);

for i = 1:Ni
    for j = 1:Nj
        subplot(Ni,Nj,j+3*(i-1));
        imagesc(log(abs(images{i,j})))
        title(sprintf('image %d, %d',i,j))
        axis image;
    end %for
end %for
    