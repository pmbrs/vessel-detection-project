%% STARTING

% function main
 clear all, close all
 
%importing labels from txt
load vesselLabels.txt;
%vesselsLabels(100,2);

% -------------------- CONST ---------------------- %
RegionBuffer = [];
stepRoi = 5;

%baseBkg = 13; % Initial Frame: 0 %
baseNum = 13;

% To use txt values use nVesselLabels = nFrames + 1 %
% nVesselLabels start in 1 and nFrames starts in 0  %
nTotalFrames = 1533; % Total: 1533
nInitialFrame = 12;  % Initial Boat: 12

thr_global = 150; % 180
thr_diff = 18;    % 18 %60 fails detecting the boat sometimes

minArea = 100;  % 100
maxArea = 1000; % 1000
%alfa = 0.10;    % 0.10

%nFrameBkg = 1000;   

distanceBetweenVessels = 100;
array_inds = [];

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
        % ----------------------------------------------------------- %
        %%%Spacial Validation
        % ----------------------------------------------------------- %
%         for k=1:regnum
%             for m=1:regnum
%                %run all inds to search for inds that are too close
%                vesselAX = regionProps(inds(k)).Centroid(1,1);
%                vesselAY = regionProps(inds(k)).Centroid(1,2);
%                vesselBX = regionProps(inds(m)).Centroid(1,1);
%                vesselBY = regionProps(inds(m)).Centroid(1,2);
%                
%                distBetweenVessels = [vesselAX, vesselAY; ...
%                    vesselBX, vesselBY];
%                pdistBetweenVessels = pdist(distOfNeighborM, 'euclidean');
%                
%                if pdistBetweenVessels < distanceBetweenVessels
%                   %remove inds k and m from inds
%                   
%                   %ind = [1 4 7] ; % indices to be removed
%                   %A(ind) = []; % remove
%                   
%                   for n=1:size(inds)
%                       if inds(n) == k_value;
%                           
%                           
%                           array_inds = [array_inds inds(n)];
%                       end
%                   end
%                   
%                end
%                
%                
%             end
%         end
        
        %%USE if spacial validation is not used
        %array_inds = inds;
        
        % ----------------------------------------------------------- %
        %%%Temporal Buffer
        % ----------------------------------------------------------- %
        %%change buffer lines from 1-14 to 2-15
        %%frame 15 will be overwriten
        
        %doing boxes on approved inds
        for j=1:regnum
            [lin, col]= find(lb == inds(j));
            upLPoint = min([lin col]);
            dWindow  = max([lin col]) - upLPoint + 1;

            rectangle('Position',[fliplr(upLPoint) fliplr(dWindow)],'EdgeColor',[1 1 0],...
                'linewidth',2);
            
            %%%Temporal Buffer
            %%add regionProps to j(index) of the buffer
            
            
            
        end
    end

    drawnow

end
