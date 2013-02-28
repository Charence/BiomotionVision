%
clc;
clear;
close all;

fid = fopen('CamB_3.txt','wt');

pp=[];
for i=101:1100
    c=strcat('aa=imread(''/data/3D Reconstruction/CamB3/imag_',int2str(i),'.png'');');
    eval(c);
    imshow(aa);
    point=ginput(1);
     fprintf(fid, '%d   %d\n', point(1), point(2));
    hold on;
    plot(point(1), point(2),'ro');
    
    pp=[pp,point(:)];
    fprintf('i=%d\n',i);
    
    pause(0.1);
    clf;
end


fclose(fid);
