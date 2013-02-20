clear;
close all;

data = load('p2_g.csv');

range = 680:2485;
range = 680:3485;
range = 680:4400;

frames = [];
tempdata = [];

tracks = 2;

prevX = -1;
prevY = -1;
prevA = -1;

for i = 1:tracks
    track(i).prevX = -1;
    track(i).prevY = -1;
    track(i).prevA = -1;
end

for i = range
    states = data(find(data(:,1) == i),:); % find all states for frame
    for j = 1:length(states) % iterate over all detections
        % find closest state
        closestTrack = -1;
        % if none, create new tracker and store states
        if closestTrack == -1
            track(length(track)+1).prevX = states(1, 5);
            track(length(track)+1).prevY = states(1, 6);
            track(length(track)+1).prevA = states(1, 7);
        end
    end
    if length(states) > 0 % TODO iterate over all detections (do one for now)
        %for 1:length(track)
            % 
        %end
        %tempdata = [tempdata; states(find(states(:,4) == max(states(:,4))),:)]; % save
        maxstates = states(find(states(:,4) == max(states(:,4))),:); % find largest states
        % 
        if prevX == -1
            prevX = states(1, 5);
            prevY = states(1, 6);
            prevA = states(1, 7);
        end
        % find closest state
        minDistance = Inf;
        for j = 1:size(states, 1)
            stateDistance1 = sqrt((states(j, 2) - prevX)^2 + (states(j, 3) - prevY)^2);
            stateDistance2 = sqrt((states(j, 5) - prevX)^2 + (states(j, 6) - prevY)^2);
            stateDistance3 = abs(states(j, 7) - prevA);
            stateDistance = stateDistance2;
            if stateDistance < minDistance
                maxstates = states(j, :);
                minDistance = stateDistance;
            end
        end
        if minDistance < 50
            frames = [frames i];
            % select 1 state only
            if length(maxstates) > 1
                tempdata = [tempdata; maxstates(1,:)];
            else
                tempdata = [tempdata; maxstates];
            end
            % store previous position
            prevX = tempdata(size(tempdata, 1), 5);
            prevY = tempdata(size(tempdata, 1), 6);
            prevA = tempdata(size(tempdata, 1), 7);
        end
    end
end

data = tempdata;

data(:,2) = medfilt1(data(:,2), 10);
data(:,3) = medfilt1(data(:,3), 10);

% State = (x y xdot ydot radius). We only observe (x y radius).

% This code was used to generate Figure 15.9 of "Artificial Intelligence: a Modern Approach",
% Russell and Norvig, 2nd edition, Prentice Hall, 2003.

% X(t+1) = F X(t) + noise(Q)
% Y(t) = H X(t) + noise(R)

ss = 5; % state size
os = 3; % observation size
deltaT = 0.01;
F = [1 0 deltaT 0 0; 0 1 0 deltaT 0; 0 0 1 0 0; 0 0 0 1 0; 0 0 0 0 1]; 
H = [1 0 0 0 0; 0 1 0 0 0; 0 0 0 0 1];
Q = 1*eye(ss);
R = 0.5*eye(os);
index = 1; % start
initx = [data(index,2) data(index,3) 0 0 data(index, 4)]'; % initial state
initV = 10*eye(ss);

% seed = 9;
% rand('state', seed);
% randn('state', seed);
% T = 1005;
% [x,y] = sample_lds(F, H, Q, R, initx, T);

y = data(index+1:size(data,1), [2 3 4])'; % observation

[xfilt, Vfilt, VVfilt, loglik] = kalman_filter(y, F, H, Q, R, initx, initV);

figure(1)
clf
%subplot(2,1,1)
hold on
% plot(x(1,:), x(2,:), 'ks-');
plot(y(1,:), y(2,:), 'g*-.');
%plot(xfilt(1,:), xfilt(2,:), 'rx:');
hold off
legend( 'observed', 'filtered', 3)
xlabel('x')
ylabel('y')

% 3x3 inches
set(gcf,'units','inches');
set(gcf,'PaperPosition',[0 0 3 3])  
%print(gcf,'-depsc','/home/eecs/murphyk/public_html/Bayes/Figures/aima_filtered.eps');
%print(gcf,'-djpeg','-r100', '/home/eecs/murphyk/public_html/Bayes/Figures/aima_filtered.jpg');

result = figure;
imagenum = 0;

kkk=1:1:length(frames);

for i=frames(kkk) %680:2485
    image = imread(sprintf('/media/Charence500/Data/20121221/10/2/frame%04d.jpg',i));
    %image = imread(sprintf('/home/charence/Workspace/biomotion-vision/images/set2/3/10/frame%04d.jpg',i));
    imshow(image)
    %states = xfilt(find(xfilt(:,1) == i),:); % find all states for xfilt
    %if length(states) > 0 % TODO iterate over all detections (do one for now)
    %    tempdata = [tempdata; states(find(states(:,4) == max(states(:,4))),:)]; % save
    %end
    hold on
    j = find(frames == i);
    if length(j) > 0
        plot(y(1,j), y(2,j), 'bo','linewidth',18);
        plot(xfilt(1,j), xfilt(2,j), 'rx','linewidth',18);
        % save result figure
        print(result, ['/media/Charence500/Data/temp/frame' int2str(imagenum)], '-dpng');
        imagenum = imagenum + 1;
    end
    %print(result, ['/home/charence/Workspace/biomotion-vision/images/set2/3/10/temp/frame' int2str(imagenum)], '-dpng');
    %pause(0.001)
    clf
end
