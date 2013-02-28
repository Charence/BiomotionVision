%
clc;
clear;
close all;

points = load('points/CamA_1.txt');
for i=101:1100
    c=strcat('aa=imread(''/data/3D Reconstruction/CamA3/imag_',int2str(i),'.png'');');
    eval(c);
    imshow(aa);
    hold on;
    plot(points(i-100,1), points(i-100,2),'ro');
    fprintf('i=%d\n',i);
     pause(0.1);
   
    clf;
end


