close all
clear

% load ground truth
%truth = load('1p-sub1-truth.csv');
truth = load('2p-sub1-truth.csv');
%truth = load('2p-sub2-truth.csv');
%truth = load('3p-sub1-truth.csv');
%truth = load('3p-sub2-truth.csv');
%truth = load('3p-sub3-truth.csv');

% load detection
%load('1p-sub1.mat');
load('2p-sub1.mat');
%load('2p-sub2.mat');
%load('3p-sub1a.mat');
%load('3p-sub2.mat');
%load('3p-sub3.mat');

% take a look at last record
frames(length(frames))
truth(length(truth),:)

detectedFrames = [];
detectionError = [];

pathFrames = [];
correspondingFrames = [];

% loop through ground truth
for i = 1:size(truth, 1)
	% get frame number
	frameNumber = truth(i, 1);
	% find corresponding detected frame
	correspondingFrameNumber = find(frames(:)==frameNumber);
	% if found
	if length(correspondingFrameNumber) == 1 && correspondingFrameNumber <= size(xfilt, 2)
		% store frame number
		detectedFrames = [detectedFrames frameNumber];
		% ground truth X, Y
		trueX = truth(i, 2);
		trueY = truth(i, 3);
		% detected X, Y
		detectedX = xfilt(1, correspondingFrameNumber);
		detectedY = xfilt(2, correspondingFrameNumber);
		% error
		distance = sqrt((trueX - detectedX)^2 + (trueY - detectedY)^2);
		detectionError = [detectionError distance];
		pathFrames = [pathFrames i];
		correspondingFrames = [correspondingFrames correspondingFrameNumber];
	elseif length(correspondingFrameNumber) > 1
		fprintf('Multiple detections for frame %d\n', frameNumber);
	else
		fprintf('Something wrong for frame %d\n', frameNumber);
	end
end

% 10 pixels == 22mm
%detectionError = detectionError * 0.22;

% normalise against diagonal
imageDiagonal = sqrt(720^2 + 576^2);
%detectionError = detectionError / imageDiagonal;

% plot error
figure
plot(detectedFrames, detectionError);
ylabel('Normalised Error');
xlabel('Frame');

% plot path
figure
plot(truth(pathFrames,2), truth(pathFrames,3), 'b-')
hold on
plot(xfilt(1,correspondingFrames),xfilt(2,correspondingFrames),'rx-')
