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

distanceBetweenVessels = 80;
%1cm=58pixes(units)


mainFigure = figure(1);

%numKeyFrames = 0;

se = strel('disk',3);

% -------------------- END Const -------------------- %

% --------------------------------------------------- %

% -------------------- ROI -------------------------- %
% Remove object intersection
% Faz as caixinhas

for f = nInitialFrame : stepRoi : nTotalFrames 
    array_inds = [];
    
    imgfrNew = imread(sprintf('../Frames/frame%.4d.jpg', ...
                    baseNum + f));
    disp('-----------------------------------------------------------');
    disp('f');
    disp(f);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    sprintf('ROI %d',f);
    hold off

    % imshow(imgfrNew); %% Real image with rectangles - Background 
    hold on

    imgdif = (abs(double(imgfrNew(:,:,1)))>thr_global) | ...
        (abs(double(imgfrNew(:,:,2))-double(imgfrNew(:,:,1)))>thr_diff) | ...
        (abs(double(imgfrNew(:,:,3))-double(imgfrNew(:,:,1)))>thr_diff);


    bw = imclose(imgdif,se);
    str = sprintf('Frame: %d',f);
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
    % ----------------------------------------------------------- %
    disp('f/inds/regnum');
    disp(f);
    disp(inds);
    disp(regnum);
    % ----------------------------------------------------------- %
    if regnum
        % ----------------------------------------------------------- %
        %%%Spacial Validation
        % ----------------------------------------------------------- %

            
        for k=1:regnum
            for m=1:regnum
               if k ~= m
                   %run all inds to search for inds that are too close
                   vesselAX = regionProps(inds(k)).Centroid(1,1);
                   vesselAY = regionProps(inds(k)).Centroid(1,2);
                   vesselBX = regionProps(inds(m)).Centroid(1,1);
                   vesselBY = regionProps(inds(m)).Centroid(1,2);

                   distBetweenVessels = [vesselAX, vesselAY; ...
                       vesselBX, vesselBY];
                   pdistBetweenVessels = pdist(distBetweenVessels, 'euclidean');
%                    disp('dist');
%                    disp(pdistBetweenVessels);

                   if pdistBetweenVessels < distanceBetweenVessels
                       %disp('entrou');
                       %remove inds k and m from inds
                       
                       %ind = [1 4 7] ; % indices to be removed
                       %A(ind) = []; % remove
                       
                       %array_inds array to put vessels that are too close
                       %to other vessels
                       
                       %detecting if k and m are in array_inds
                       arrayDetection = ismember([k m],array_inds);
                       if f == 82
                        f=f;    
                       end
                       %k is not find on array_inds
                       if arrayDetection(1,1) == 0
                           array_inds = [array_inds k];
                       end
                       
                       %m is not find on array_inds
                       if arrayDetection(1,2) == 0
                           array_inds = [array_inds m];
                       end
                   end                   
               end
            end         
        end
        disp('regnumCalisto');
        disp(regnum);
        %all vessels processed
        allInds = inds;
         % ----------------------------------------------------------- %
        disp('array_inds');
        disp(array_inds);
        disp('allInds');
        disp(allInds);
        % ----------------------------------------------------------- %
%         allInds = unique(array_inds);
%         withoutDuplicates = unique(array_inds);
        allInds(array_inds) = [];
%         allInds = withoutDuplicates;
        
        % ----------------------------------------------------------- %
        
        disp('POSallInds');
        disp(allInds);
        % ----------------------------------------------------------- %
        
        %now allInds have only vessels aproved by spacial validation algoritm
        
        %%USE if spacial validation is not used, to check if is true
        %array_inds = inds;
        
        % ----------------------------------------------------------- %
        %%%Temporal Buffer
        % ----------------------------------------------------------- %
        %%change buffer lines from 1-14 to 2-15
        %%frame 15 will be overwriten
        
        
        % ----------------------------------------------------------- %
        %doing boxes on approved inds
        % ----------------------------------------------------------- %
        regnumAllInds = length(allInds);
    
        if regnumAllInds
            for j=1:regnumAllInds
                [lin, col]= find(lb == allInds(j));
                upLPoint = min([lin col]);
                dWindow  = max([lin col]) - upLPoint + 1;

                rectangle('Position',[fliplr(upLPoint) fliplr(dWindow)],'EdgeColor',[1 1 0],...
                    'linewidth',2);

                %%%Temporal Buffer
                %%add regionProps to j(index) of the buffer



            end
        end

    end

    drawnow

end
