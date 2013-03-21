function [ds, bs, trees] = imgdetect(im, model, thresh)
% Wrapper around gdetect.m that computes detections in an image.
%   [ds, bs, trees] = imgdetect(im, model, thresh)
%
% Return values (see gdetect.m)
%
% Arguments
%   im        Input image
%   model     Model to use for detection
%   thresh    Detection threshold (scores must be > thresh)

im = color(im);

% CHARENCE - setup sliding window
window.size = 200;
window.increment = 10; %window.size/4;
window.x = 1;
window.y = 1;

while window.y + window.size < size(im, 1)
    while window.x + window.size < size(im, 2)
        % crop image and turn into polar form
        for i = 1:size(im, 3)
            imW = im(window.y:window.y+window.size, window.x:window.x+window.size, i);
            %imW = rgb2gray(imW);
            imW = double(imW)/255.0;
            imP(:,:,i) = ImToPolar(imW, 0, 1, window.size/2, 360);
        end
        imshow(imP);
        % feature extraction and detection
        pyra = featpyramid(imP, model); % image should be colour with double vals
        [ds, bs, trees] = gdetect(pyra, model, thresh);
        % shift window across
        window.x = window.x + window.increment;
    end
    % shift window down
    window.y = window.y + window.increment;
end