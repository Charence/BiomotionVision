function demo()
startup;
addpath('../PolarRectangularConv0/PolarRectangularConv0.1/'); % add ImToPolar

fprintf('compiling the code...');
compile;
fprintf('done.\n\n');

%load('VOC2007/car_final');
%model.vis = @() visualizemodel(model, ...
%                  1:2:length(model.rules{model.start}));
%test('000034.jpg', model, -0.3);

load('INRIA/inriaperson_final');
model.vis = @() visualizemodel(model, ...
                  1:2:length(model.rules{model.start}));
test('000061.jpg', model, -0.3);

load('INRIA/inriaperson_final');
model.vis = @() visualizemodel(model, ...
                  1:2:length(model.rules{model.start}));
test('000061.jpg', model, -0.3);

for rotateIndex = 10:10:350
    load('VOC2007/person_grammar_final');
    model.class = 'person grammar';
    model.vis = @() visualize_person_grammar_model(model, 6);
    test(['000061-' num2str(rotateIndex) '.jpg'], model, -0.6);
end

load('VOC2007/bicycle_final');
model.vis = @() visualizemodel(model, ...
                  1:2:length(model.rules{model.start}));
test('000084.jpg', model, -0.3);

function test(imname, model, thresh)
cls = model.class;
fprintf('///// Running demo for %s /////\n\n', cls);

% load and display image
im = imread(imname);
clf;
figure(1); % CHARENCE
image(im);
axis equal; 
axis on;
disp('input image');
disp('press any key to continue'); pause;
disp('continuing...');

% load and display model
figure(1); % CHARENCE
model.vis();
disp([cls ' model visualization']);
disp('press any key to continue'); pause;
disp('continuing...');

% detect objects
[ds, bs] = imgdetect(im, model, thresh);
top = nms(ds, 0.5);
clf;
if model.type == model_types.Grammar
  bs = [ds(:,1:4) bs];
end
if length(bs) > 0 % CHARENCE
  showboxes(im, reduceboxes(model, bs(top,:)));
  disp('detections');
  disp('press any key to continue'); pause;
  disp('continuing...');

  if model.type == model_types.MixStar
    % get bounding boxes
    bbox = bboxpred_get(model.bboxpred, ds, reduceboxes(model, bs));
    bbox = clipboxes(im, bbox);
    top = nms(bbox, 0.5);
    clf;
    showboxes(im, bbox(top,:));
    disp('bounding boxes');
    disp('press any key to continue'); pause;
  end
else
    fprintf('Nothing found\n');
end

fprintf('\n');
