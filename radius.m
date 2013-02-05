clear;
close all;

data=load('p1.csv');
% 
% for i=680:2485
%     index=(data(:,1)==i);
%     newdata=data(index,:);
%     if length(newdata)>0
%         maxradius(i+1)=max(newdata(:,5));
%     end
% end

% Make a point move in the 2D plane
% State = (x y xdot ydot). We only observe (x y).

% This code was used to generate Figure 15.9 of "Artificial Intelligence: a Modern Approach",
% Russell and Norvig, 2nd edition, Prentice Hall, 2003.

% X(t+1) = F X(t) + noise(Q)
% Y(t) = H X(t) + noise(R)

ss = 5; % state size
os = 3; % observation size
deltaT = 0.01;
F = [1 0 deltaT 0 0; 0 1 0 deltaT 0; 0 0 1 0 0; 0 0 0 1 0; 0 0 0 0 1]; 
H = [1 0 0 0 0; 0 1 0 0 0; 0 0 0 0 1];
Q = 0.1*eye(ss);
R = 1*eye(os);
index = 10;
initx = [data(index,3) data(index,4) 0 0 data(index, 5)]';
initV = 10*eye(ss);

% seed = 9;
% rand('state', seed);
% randn('state', seed);
% T = 1005;
% [x,y] = sample_lds(F, H, Q, R, initx, T);

y = data(index+1:size(data,1), [3 4 5])';

[xfilt, Vfilt, VVfilt, loglik] = kalman_filter(y, F, H, Q, R, initx, initV);




figure(1)
clf
%subplot(2,1,1)
hold on
% plot(x(1,:), x(2,:), 'ks-');
plot(y(1,:), y(2,:), 'g*');
plot(xfilt(1,:), xfilt(2,:), 'rx:');
hold off
legend( 'observed', 'filtered', 3)
xlabel('x')
ylabel('y')



% 3x3 inches
set(gcf,'units','inches');
set(gcf,'PaperPosition',[0 0 3 3])  
%print(gcf,'-depsc','/home/eecs/murphyk/public_html/Bayes/Figures/aima_filtered.eps');
%print(gcf,'-djpeg','-r100', '/home/eecs/murphyk/public_html/Bayes/Figures/aima_filtered.jpg');

figure
% for i=680:2485
%     index=(data(:,1)==i);
%     newdata=data(index,:);
%     if length(newdata)>0
%         maxradius(i+1)=max(newdata(:,5));
%     end
% end
for i=680:2485
    image = imread(sprintf('/media/Charence500/Data/20121221/10/1/frame%04d.jpg',i));
    imshow(image)
    hold on
    plot(y(1,i-679), y(2,i-679), 'bo','linewidth',18);
    plot(xfilt(1,i-679), xfilt(2,i-679), 'rx','linewidth',18);
    pause(0.1)
    clf
end