%% STARTING

% function main
 clear all, close all
 
%importing labels from txt
load vesselLabels.txt;
%vesselsLabels(100,2);

% -------------------- CONST ---------------------- %
RegionBuffer = [];
stepRoi = 25;

%baseBkg = 13; % Initial Frame: 0 %
baseNum = 13;

% To use txt values use nVesselLabels = nFrames + 1 %
% nVesselLabels start in 1 and nFrames starts in 0  %
nTotalFrames = 1533; % Total: 1533
nInitialFrame = 12;  % Initial Boat: 12

thr_global = 180; % 180
thr_diff = 60;    % 18

minArea = 100;  % 100
maxArea = 1000; % 1000
%alfa = 0.10;    % 0.10

%nFrameBkg = 1000;   

mainFigure = figure(1);

%numKeyFrames = 0;

se = strel('disk',3);

% -------------------- END Const -------------------- %

% --------------------------------------------------- %

% -------------------- ROI -------------------------- %
% Remove object intersection
% Faz as caixinhas

for k = nInitialFrame : stepRoi : nTotalFrames  
    imgfrNew = imread(sprintf('../Frames/frame%.4d.jpg', ...
                    baseNum + k));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    sprintf('ROI %d',k);
    hold off

    % imshow(imgfrNew); %% Real image with rectangles - Background 
    hold on

    imgdif = (abs(double(imgfrNew(:,:,1)))>thr_global) | ...
        (abs(double(imgfrNew(:,:,2))-double(imgfrNew(:,:,1)))>thr_diff) | ...
        (abs(double(imgfrNew(:,:,3))-double(imgfrNew(:,:,1)))>thr_diff);


    bw = imclose(imgdif,se);
    str = sprintf('Frame: %d',k);
    title(str);

    % ----------------------------------------------------------- %
    imshow(bw);  %%Mete Background preto ao mesmo tempo
    % ----------------------------------------------------------- %

    [lb num]=bwlabel(bw);
    regionProps = regionprops(lb,'area','FilledImage','Centroid');

    %inds = find(minArea < [regionProps.Area] < maxArea);
    inds = [];
    for k = 1 : length(regionProps)
        if find([regionProps(k).Area] < maxArea & [regionProps(k).Area] > minArea)
            inds = [inds k];
        end
    end

    regnum = length(inds);

    if regnum
        for j=1:regnum
            [lin, col]= find(lb == inds(j));
            upLPoint = min([lin col]);
            dWindow  = max([lin col]) - upLPoint + 1;

            rectangle('Position',[fliplr(upLPoint) fliplr(dWindow)],'EdgeColor',[1 1 0],...
                'linewidth',2);
        end
    end

    drawnow

end

% function [mask_v, targets] = Vessel_detection(l, SR, R_threshold, dif_threshold)
% 
% % l         input image
% % mask_v    binary mask
% % features  array of regions features
% 
% % vessel detection
% % mask = (max(I, [], 3) > R_threshold) = ([max](I, [], 3) - min(1, [], 3));
% 
% SE = strel('disk', SR);
% mask_v = imdilate(imgdif, SE);
% targets = extract_targets(mask_v); % extract blob features
%     
% end