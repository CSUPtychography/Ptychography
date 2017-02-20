function plotims(images)

Ni = size(images,1);
Nj = size(images,2);

for i = 1:Ni
    for j = 1:Nj
        subplot(Ni,Nj,j+Ni*(i-1));
        imagesc(abs(images{i,j}))
        set(gca, 'YTickLabel', [], 'XTickLabel', []);
        title(sprintf('image %d, %d',i,j))
        axis image;
    end %for
end %for
