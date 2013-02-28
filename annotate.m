clear;
close all;

data = load('p1_g.csv');

range = 680:10:4400;

for i=range
    % read and show image
    image = imread(sprintf('/media/Charence500/Data/20121221/10/1/frame%04d.jpg',i));
    %image = imread(sprintf('/home/charence/Workspace/biomotion-vision/images/set2/3/10/frame%04d.jpg',i));
    imshow(image)
    % input
    point = ginput(1);
    fprintf(fid, '%d   %d\n', point(1), point(2));
    hold on
    plot(point(1), point(2),'ro');
    pp=[pp,point(:)];
    fprintf('i=%d\n',i);
    %print(result, ['/home/charence/Workspace/biomotion-vision/images/set2/3/10/temp/frame' int2str(imagenum)], '-dpng');
    pause(0.1)
    clf
end
