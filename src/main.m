%% STARTING

% function main
 clear all, close all
 
%importing labels from txt
load vesselLabels.txt;
%vesselsLabels(100,2);

% ----------------------- CONST ------------------------- %
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

bufferArr = [];
reglist = [];
rectangleAux = [];
arrAllIndsRectangleAux = [];

mainFigure = figure(1);

%numKeyFrames = 0;

se = strel('disk',3);

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
    numFrameIterations = numFrameIterations + 1; 
    
    imgfrNew = imread(sprintf('../Frames/frame%.4d.jpg', ...
                    baseNum + f));
    disp('-----------------------------------------------------------');
    disp('f');
    disp(f);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % ------------------------------------------------------ %
    % Buffer Shift Lines
    % ------------------------------------------------------ %
    
    % Limit the bigger number
    if maxBufferNum < numFrameIterations
        numFrameIterationsAux = maxBufferNum;
    else
        numFrameIterationsAux = numFrameIterations;
    end
    
    for mb = numFrameIterationsAux : -1 : 2
        bufferStruct.bufferStructNames(mb);
    end
    
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
    disp('f/inds/regnum');
    disp(f);
    disp(inds);
    disp(regnum);
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
        % END Temporal Validation Algorithm
        % ------------------------------------------------------ %
        
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
        
        % NOW allInds have only vessels aproved by spacial validation algoritm
        
        %%USE if spacial validation is not used, to check if is true
        %array_inds = inds;
        
        % ----------------------------------------------------------- %
        %%%Temporal Buffer
        % ----------------------------------------------------------- %
        %%change buffer lines from 1-6 to 2-7
        %%frame 7 will be overwriten
        
%         numSim = 10;
%         your_cell = cell(numSim,1);
%         %Generating data and storing it in a cell array
%         for ii = 1:numSim
%             % insert line col on first and second rows(columns?)
%             temp_mat = randi(100,randi(10,1,2));
%             your_cell{ii} = temp_mat;
%         end
%         %Getting all data in a vector
%         your_result = cell2mat(cellfun(@(x)   x(:),your_cell,'uniformoutput',false));
%         
%         bufferArr(end) = [];        
%         %
        
        
        
        %%% ========================== %%%
%         N = 7;
%         
%         L = 10; % L e C sao as linhas e colunas da imagem lida
%    
%         C = 10;
%         
%         ACC = zeros=(L,C,N);
%         
%         for k = 1 : N
%             Acc(:,:,k) = k * ones(L, C);
%         end
%         
%         %FIFO
%         
%         aux = zeros(size(Acc));
%         
%         
%         for k = 2 : N
%             aux(:,:,k) = Acc(:,:,k);
%         end
%         
%         aux(:,:,1) = %imagem nova
        
        %%% ========================== %%%
        
%         if regnumAllInds
%             arrLineCol = [];
%             for j = 1 : regnumAllInds
%                 arrLineCol = [arrLineCol [lin col]];
%             end
%             bufferArr(1) = arrLineCol;
%         end

        % ------------------------------------------------------ %
        % Temporal Validation Algorithm
        % ------------------------------------------------------ %
        
        % Converting from lin col to rectangle format
        % bufferStruct
        regnumAllInds = length(allInds);
        if regnumAllInds
            arrAllIndsRectangleAux = [];
            for j = 1 : regnumAllInds
                [lin, col] = find(lb == allInds(j));
                upLPoint = min([lin col]);
                dWindow  = max([lin col]) - upLPoint + 1;
                %structBufferLine = []; %% First buffer line TOFIX
                rectangleAux = [fliplr(upLPoint) fliplr(dWindow)];
                
                % add the rectangle aux to arrAllIndsRectangleAux
                arrAllIndsRectangleAux = [arrAllIndsRectangleAux; rectangleAux];
                %%%Temporal Buffer
                %%add regionProps to j(index) of the buffer

            end
            % add the arrAllIndsRectangleAux to buffer first line
            field = 'a';
            %bufferStruct = setfield(bufferStruct, field, arrAllIndsRectangleAux);
            %bufferStruct(1).bufferStructNames(1);
            disp('My Buffer Struct: ');
            disp(bufferStruct);
            
        end
        
        % ------------------------------------------------------ %
        % END Temporal Validation Algorithm
        % ------------------------------------------------------ %

        % ----------------------------------------------------------- %
        %doing boxes on approved inds
        % ----------------------------------------------------------- %
        
        %regnumAllInds = length(allInds); % change variables
    
        if regnumAllInds % change variables
            structBufferLine = [];
            for j=1:regnumAllInds % change variables
%                 [lin, col] = find(lb == allInds(j));
%                 upLPoint = min([lin col]);
%                 dWindow  = max([lin col]) - upLPoint + 1;
                structBufferLine = []; %% First buffer line TOFIX
                
%                 rectangle('Position',[fliplr(upLPoint) fliplr(dWindow)],'EdgeColor',[1 1 0],...
%                     'linewidth',2);
%                 rectangle('Position',structBufferLine,'EdgeColor',[1 1 0],...
%                     'linewidth',2);

                %%%Temporal Buffer
                %%add regionProps to j(index) of the buffer



            end
        else
            reglist = struct([]);
        end
    end

    drawnow

end


