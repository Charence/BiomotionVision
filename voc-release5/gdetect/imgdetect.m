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
imG = rgb2gray(im);
imG = double(imG)/255.0;
pyra = featpyramid(im, model); % image should be colour with double vals
[ds, bs, trees] = gdetect(pyra, model, thresh);
