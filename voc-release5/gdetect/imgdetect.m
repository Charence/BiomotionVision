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
window.size = 400;
window.increment = 10; %window.size/4;
window.x = 1;
window.y = 1;

ds = [];
bs = [];
trees = [];

while window.y + window.size < size(im, 1)
    while window.x + window.size < size(im, 2)
        % crop image and turn into polar form
        for i = 1:size(im, 3)
            imW(:,:,i) = im(window.y:window.y+window.size, window.x:window.x+window.size, i);
            %imW = rgb2gray(imW);
            %imW = double(imW)/255.0;
            imP(:,:,i) = ImToPolar(imW(:,:,i), 0, 1, window.size/2, 360);
        end
        figure(4);
        imshow(imW);
        % feature extraction and detection
        pyra = featpyramid(imW, model); % image should be colour with double vals
        [dsW, bsW, treesW] = gdetect(pyra, model, thresh);
        % flatten feature pyramid (largest)
        for i = 1:32
            subplot(4,8,i), subimage(pyra.feat{1}(:,:,i));
        end
        %maxfeature = pyra.feat{1};
        % translate local detections in window to image
        for i = 1:size(dsW, 1) %dsW and bsW should have same number of rows
            ds = [ds; dsW(i, :)+[1 0 1 0 0 0]*(window.x-1)+[0 1 0 1 0 0]*(window.y-1)];
            for j = 1:4:size(bsW, 2)-2 %floor(size(bsW, 2)/4)
                %bsW(i, j:j+3) = bsW(i, j:j+3)+[1 0 1 0]*(window.x-1)+[0 1 0 1]*(window.y-1);
                if bsW(i, j) ~= 0
                    bsW(i, j) = bsW(i, j)+(window.x-1);
                end
                if bsW(i, j+1) ~= 0
                    bsW(i, j+1) = bsW(i, j+1)+(window.y-1);
                end
                if bsW(i, j+2) ~= 0
                    bsW(i, j+2) = bsW(i, j+2)+(window.x-1);
                end
                if bsW(i, j+3) ~= 0
                    bsW(i, j+3) = bsW(i, j+3)+(window.y-1);
                end
            end
            bs = [bs; bsW(i, :)];
        end
        trees = [trees; treesW];
        % shift window across
        window.x = window.x + window.increment;
    end
    % shift window down
    window.y = window.y + window.increment;
end
