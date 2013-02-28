clear;
close all;

fid = fopen('2p-truth.csv','wt');

range = 500:10:3900; %3p
range = 680:10:2140; %1p
range = 290:10:3330; %2p

pp=[];
for i=range
    % read and show image
    image = imread(sprintf('/media/Charence500/Data/20121221/10/2/frame%04d.jpg',i));
    %image = imread(sprintf('/home/charence/Workspace/biomotion-vision/images/set2/3/10/frame%04d.jpg',i));
    imshow(image)
    % input
    point = ginput(1);
    fprintf(fid, '%d,%d,%d\n', i, point(1), point(2));
    hold on
    plot(point(1), point(2),'ro');
    pp=[pp,point(:)];
    fprintf('%d,%d,%d\n', i, point(1), point(2));
    %print(result, ['/home/charence/Workspace/biomotion-vision/images/set2/3/10/temp/frame' int2str(imagenum)], '-dpng');
    pause(0.1)
    clf
end
