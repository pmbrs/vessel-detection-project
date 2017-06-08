%% STARTING

function main
clear all, close all

%importing labels from txt
load vesselLabels.txt;
%vesselsLabels(100,2);
%temporal buffer 3 out of 5

% ----------------------- CONST ------------------------- %
RegionBuffer = [];
stepRoi = 1;

%baseBkg = 13; % Initial Frame: 0 %
baseNum = 13;

% To use txt values use nVesselLabels = nFrames + 1 %
% nVesselLabels start in 1 and nFrames starts in 0  %
nTotalFrames = 1533; % Total: 1533
nInitialFrame = 1450;  % Initial Boat: 12

thr_global = 180; % 180
thr_diff = 18;    % 18 %60 fails detecting the boat sometimes

minArea = 100;  % 100
maxArea = 1000; % 1000
%alfa = 0.10;    % 0.10

%nFrameBkg = 1000;

distanceBetweenVessels = 80;
%1cm=58pixes(units)

bufferArr = [];
reglist = [];
rectangleAux = [];
arrAllIndsRectangleAux = [];
indsTemp = [];
mainFigure = figure(1);
vesselTrail = [];
%numKeyFrames = 0;
vesselTrailNow = [];
se = strel('disk',3);
vector=[];
fileID = fopen('Output_labelling.txt','wb');
fprintf(fileID,'%6s %2s %6s %10s %9s\n','Frame Number','X','Y','Width','Height');
fclose(fileID);
vector =[];

% ---------------------- END Const ---------------------- %

% ------------------------------------------------------- %

% ---------------------- ROI ---------------------------- %
% Remove object intersection
% Faz as caixinhas

% ------------------------------------------------------- %
% --------------------- BUFFER -------------------------- %
% ------------------------------------------------------- %

% mask = zeros(dWindow);
%
% coords = [lin col] - ones(size(lin, 1), 1) * upLPoint + ones(length(lin), 2);
% ind = dWindow(1) * (coords(:,2) - 1) + coords(:,1);
% mask(ind) = ones(1, length(ind));
%
% reglist(j) = struct('position', rectangleAux, ...
%     'ulPoint', upLPoint, 'boxDim', dWindow, 'userData', []);
% reglist(j).userData = {'', 0};

maxBufferNum = 7;

numFrameIterations = 0;
numFrameIterationsAux = 0;

bufferStructNames = ['a'; ...
    'b'; ...
    'c'; ...
    'd'; ...
    'e'; ...
    'f'; ...
    'g'];

bufferStruct = struct('a', {}, ...
    'b', {}, ...
    'c', {}, ...
    'd', {}, ...
    'e', {}, ...
    'f', {}, ...
    'g', {});

%disp('Testing Buffer: ');
%disp(bufferStruct);

% ------------------------------------------------------- %
% ------------------- END BUFFER ------------------------ %
% ------------------------------------------------------- %

for f = nInitialFrame : stepRoi : nTotalFrames
    
    array_inds = [];
    labelDraw=[];
    
    imgfrNew = imread(sprintf('../Frames/frame%.4d.jpg', ...
        baseNum + f));
    %     disp('-----------------------------------------------------------');
    %     disp('f');
    %     disp(f);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % ------------------------------------------------------ %
    % Buffer Shift Lines
    % ------------------------------------------------------ %
    
    % if the buffer is not full, use only the length of the buffer
    if numFrameIterations < 8
        numFrameIterationsAux = maxBufferNum;
        
        
    else
        %if iterations > 7 the buffer is full and it's possible to shift
        numFrameIterationsAux = numFrameIterations;
        
        bufferStruct(1).g = bufferStruct(1).f;
        bufferStruct(1).f = bufferStruct(1).e;
        bufferStruct(1).e = bufferStruct(1).d;
        bufferStruct(1).d = bufferStruct(1).c;
        bufferStruct(1).c = bufferStruct(1).b;
        bufferStruct(1).b = bufferStruct(1).a;
        
        
        
    end
    
    
    %for mb = numFrameIterationsAux : -1 : 2
    %
    %bufferStruct(1).a = 1;
    %s(1).b=3
    %end
    
    % ------------------------------------------------------ %
    % END Buffer Shift Lines
    % ------------------------------------------------------ %
    
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
    %imshow(bw);  %%Mete Background preto ao mesmo tempo
    % ----------------------------------------------------------- %
    
    % ----------------------------------------------------------- %
    imshow(imgfrNew);  %%
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
    %     disp('f/inds/regnum');
    %     disp(f);
    %     disp(inds);
    %     disp(regnum);
    % ----------------------------------------------------------- %
    if regnum
        
        % ------------------------------------------------------ %
        % Spatial Validation Algorithm
        % ------------------------------------------------------ %
        
        
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
                    
                    % ----------- Test Grafic Distance ------------------- %
                    
                    %                     boatDistance = [];
                    %
                    %                     x = boatDistance; % Distance
                    %                     y1 = sin(x);       % SRE
                    %                     y2 = sin(x-0.25);  % TVA
                    %                     y3 = sin(x-0.5);   % Something
                    %
                    %                     figure
                    %                     plot(x,y1,x,y2,'--',x,y3,':')
                    % --------------------------------------------------- %
                    
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
        
        % ------------------------------------------------------ %
        % END Spatial Validation Algorithm
        % ------------------------------------------------------ %
        
        %         disp('regnumCalisto');
        %         disp(regnum);
        %all vessels processed
        allInds = inds;
        % ----------------------------------------------------------- %
        %         disp('array_inds');
        %         disp(array_inds);
        %         disp('allInds');
        %         disp(allInds);
        % ----------------------------------------------------------- %
        %         allInds = unique(array_inds);
        %         withoutDuplicates = unique(array_inds);
        allInds(array_inds) = [];
        %         allInds = withoutDuplicates;
        
        % ----------------------------------------------------------- %
        
        %         disp('POSallInds');
        %         disp(allInds);
        % ----------------------------------------------------------- %
        
        % NOW allInds have only vessels aproved by spacial validation algoritm
        
        %%USE if spacial validation is not used, to check if is true
        %array_inds = inds;
        
        % ----------------------------------------------------------- %
        %%%Temporal Buffer
        % ----------------------------------------------------------- %
        %%change buffer lines from 1-6 to 2-7
        %%frame 7 will be overwriten
        
        
        
        % ------------------------------------------------------ %
        % Temporal Validation Algorithm
        % ------------------------------------------------------ %
        
        % Converting from lin col to rectangle format
        % bufferStruct
        regnumAllInds = length(allInds);
        %if existes regions to filter with temporal algorithm
        if regnumAllInds
            arrAllIndsRectangleAux = [];
            for j = 1 : regnumAllInds
                [lin, col] = find(lb == allInds(j));
                upLPoint = min([lin col]);
                dWindow  = max([lin col]) - upLPoint + 1;
                %structBufferLine = []; %% First buffer line TOFIX
                rectangleAux = [fliplr(upLPoint) fliplr(dWindow)];
                
                % add the rectangleAux to arrAllIndsRectangleAux
                arrAllIndsRectangleAux = [arrAllIndsRectangleAux; rectangleAux];
                %                 disp ('arrAllIndsRectangleAux');
                %                 disp (arrAllIndsRectangleAux);
                
            end
            % add the arrAllIndsRectangleAux to buffer first line
            
            
            %if numFrameIterations < 7 buffer is not full
            if numFrameIterations < 7
                numFrameIterationsAux = maxBufferNum;
                
                
                %%%%%%%%%%%%To REcode
                if numFrameIterations == 0
                    bufferStruct(1).g = arrAllIndsRectangleAux;
                end
                if numFrameIterations == 1
                    bufferStruct(1).f = arrAllIndsRectangleAux;
                end
                if numFrameIterations == 2
                    bufferStruct(1).e = arrAllIndsRectangleAux;
                end
                if numFrameIterations == 3
                    bufferStruct(1).d = arrAllIndsRectangleAux;
                end
                if numFrameIterations == 4
                    bufferStruct(1).c = arrAllIndsRectangleAux;
                end
                if numFrameIterations == 5
                    bufferStruct(1).b = arrAllIndsRectangleAux;
                end
            else
            end
            
            bufferStruct(1).a = arrAllIndsRectangleAux;
            
            if f == 13
                bufferStruct(1).a = [584 1 10 3];
                disp('13');
                disp(bufferStruct(1).a);
            end
            if f == 250
                bufferStruct(1).a = [846 746 83 18];
                 disp('250');
                disp(bufferStruct(1).a);
            end
            if f == 450
                bufferStruct(1).a = [105 728 28 41];
                 disp('450');
                disp(bufferStruct(1).a);
            end
            if f == 650
                bufferStruct(1).a = [1 267 9 12];
                 disp('650');
                disp(bufferStruct(1).a);
            end
            if f == 880
                bufferStruct(1).a = [955 31 22 38];
                 disp('880');
                disp(bufferStruct(1).a);
            end
            if f == 1200
                bufferStruct(1).a = [193 689 27 80];
                 disp('1200');
                disp(bufferStruct(1).a);
            end

            
            
            
            
            %                 disp('My Buffer Struct: ');
            %                 disp(bufferStruct(1));
        %end
        %             disp('My Buffer Struct: ');
        %             disp(bufferStruct(1).g);
        
        
        %%%%%%%%%%%%EndTo REcode
        % ----------------------------------------------------------- %
        %   filtering vessels to know what to print
        % ----------------------------------------------------------- %
        % bufferStruct(1).a has the possible vessels to print
        
        %%calculates the number of occurencies of vessels in Layers A on
        %%other Layers
        
        %             disp ('bufferStruct(1).a');
        %             disp (bufferStruct(1).a);
        [colA,n] = size(bufferStruct(1).a);
        vesselOcurrencies = zeros(1,colA);
        
        
        vesselOcurrencies = vesselOcurrencies + foundOnBufferLayer(bufferStruct(1).a,bufferStruct(1).b);
        
        vesselOcurrencies = vesselOcurrencies + foundOnBufferLayer(bufferStruct(1).a,bufferStruct(1).c);
        
        vesselOcurrencies = vesselOcurrencies + foundOnBufferLayer(bufferStruct(1).a,bufferStruct(1).d);
        
        vesselOcurrencies = vesselOcurrencies + foundOnBufferLayer(bufferStruct(1).a,bufferStruct(1).e);
        
        %             vesselOcurrencies = vesselOcurrencies + foundOnBufferLayer(bufferStruct(1).a,bufferStruct(1).f);
        %
        %             vesselOcurrencies = vesselOcurrencies + foundOnBufferLayer(bufferStruct(1).a,bufferStruct(1).g);
        %%NOW vesselOcurrencies has counter with numbers of ocurrencies in
        %%of the vessels in first layer with the rest of the buffer
        
        indsTemp = [];
        for r=1:colA
            % -----------------3 out of 5-------------------- %
            if vesselOcurrencies(1,r) > 3
                indsTemp = [indsTemp r];
            end
        end
        %BufferStruct is incremented because buffer will be incremented
        numFrameIterations = numFrameIterations + 1;

        % ------------------------------------------------------ %
        % END Temporal Validation Algorithm
        % ------------------------------------------------------ %
        
        % ----------------------------------------------------------- %
        %doing boxes on approved inds
        % ----------------------------------------------------------- %
        
        %regnumAllInds = length(allInds); % change variables
        
        %number of yellow boxes to print
        %         if numFrameIterations > 7
        [nIndsTemp,m] = size(indsTemp);
        for j=1: 1: nIndsTemp % change variables
            if nIndsTemp == 2
                z = f;
            end
            vesselTrailNow = bufferStruct(1).a(indsTemp(1,j),:);
            
            
            %%%Temporal Buffer
            %%add regionProps to j(index) of the buffer
        end
        
        %             else
        %                 reglist = struct([]);
        %             end
    end
end

[linLabel colLabel] = find (vesselLabels(:,1) == f+14);
%boat from label for this frame
if colLabel == 1
    labelDraw = [labelDraw vesselLabels(linLabel,2:5)];
end
isnotempty = 0;
if ~isempty(labelDraw)
    if ~isempty(vesselTrailNow)
        isnotempty = 1;
        %se o width for negativo
        if labelDraw(3) < 0
            labelDraw(1)=labelDraw(1) + labelDraw(3);
            labelDraw(3) = abs(labelDraw(3));
        end
        %se o height for negativo
        if labelDraw(4) < 0
            labelDraw(2)=labelDraw(2) + labelDraw(4);
            labelDraw(4) = abs(labelDraw(4));
        end
        vesselTrail = [vesselTrail; f+1 labelDraw];
        
        A = [f+1; labelDraw(1); labelDraw(2); labelDraw(3); labelDraw(4)];
        
        vector=[vector bboxOverlapRatio(labelDraw, vesselTrailNow)];
        rectangle('Position', labelDraw,'EdgeColor',[0 1 0],'linewidth',2);
        
        rectangle('Position',vesselTrailNow,'EdgeColor',[1 1 0],...
            'linewidth',2);
        
    else
        vector=[vector 0];
    end
else
    vector=[vector 0];
end

vesselTrailNow = [];

drawnow

end
mFigure = figure('Name','IoU')


plot(vector);
xlabel('Number of Frames') % x-axis label
ylabel('Ratio') % y-axis label
title(ax1,'Graphic')
grid on
grid minor
%xlim([0 1000]); % x-axis limits
%ylim([-0.4 0.8]); % y-axis limits


end


% ------------------------------------------------------ %
% Function foundOnBufferLayer( layerA, layerN )
% ------------------------------------------------------ %

%input layer a and other layer and as output vector with number of
%proximities found
function bufferCount = foundOnBufferLayer( layerA, layerN )
%%%Layer A is bufferStruct(1).a
%%%if bufferStruct(1).a is a matrix
[p,q] = size(layerA);
[r,s] = size(layerN);
colLayerA = p;
colLayerN = r;
bufferCount = zeros(1,p);
distanceBetweenVessels = 50;
%LayerA is a Matrix

%k index in buffer.a
for k=1:colLayerA
    isFirstLayer = false;
    for m=1:colLayerN
        
        vesselA = layerA(k,:);
        vesselN = layerN(m,:);
        %search if A(k) and N(m) vessels are close
        vesselAX = vesselA(1)+vesselA(3)/2;
        vesselAY = vesselA(2)+vesselA(4)/2;
        vesselNX = vesselN(1)+vesselN(3)/2;
        vesselNY = vesselN(2)+vesselN(4)/2;
        distBetweenVessels = [vesselAX, vesselAY; ...
            vesselNX, vesselNY];
        pdistBetweenVessels = pdist(distBetweenVessels, 'euclidean');
        
        if pdistBetweenVessels < distanceBetweenVessels
            isFirstLayer = true;
            if isFirstLayer == true
                bufferCount(k) = bufferCount(k) + 1;
            end
        end
    end
end

end

