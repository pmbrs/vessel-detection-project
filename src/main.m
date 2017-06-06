%% STARTING

% function main
 clear all, close all
 
    %importing labels from txt
    load vesselLabels.txt;
    
    baseBkg = 13; % Initial Frame: 0 %
    baseNum = 13;
    
    nTotalFrames = 1536; % Total: 1536
    
    thr = 10; % 30
    thr_global = 180;
    thr_diff = 18;
    
    minArea = 100;  % 100
    maxArea = 1000; % 1000
    alfa = 0.10;    % 0.10
    
    nFrameBkg = 1000;
    step = 1;
   
    
    mainFigure = figure(1);
    
    numKeyFrames = 0;
    
    se = strel('disk',3);
    
    % ------------------ END Backgroud ------------------ %

    % --------------------------------------------------- %

    %imgBkgBase = imgUInt8; % Imagem de background

    % -------------------- ROI -------------------------- %
    % Remove object intersection
    % Faz as caixinhas

    stepRoi = 10;
    nFrameROI = nTotalFrames;  % 23354 Frames used to compute background image

    %for k = baseNum : stepRoi : nFrameROI
    for k = 1 : 100  
        imgfrNew = imread(sprintf('../Frames/frame%.4d.jpg', ...
                        baseNum + k));

                    
        if k == 48
            disp('')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        sprintf('ROI %d',k);
        hold off
        
        %imshow(imgfrNew); %% Caminho rectangulos amarelos - Background 
        hold on
        
        imgdif = (abs(double(imgfrNew(:,:,1)))>thr_global) | ...
            (abs(double(imgfrNew(:,:,2))-double(imgfrNew(:,:,1)))>thr_diff) | ...
            (abs(double(imgfrNew(:,:,3))-double(imgfrNew(:,:,1)))>thr_diff);
    
    
        bw = imclose(imgdif,se);
        str = sprintf('Frame: %d',k); title(str);
        
        % ----------------------------------------------------------- %
        imshow(bw);  %%Mete Background preto ao mesmo tempo
        % ----------------------------------------------------------- %
        
        %imshow(bw)
        [lb num]=bwlabel(bw);
        regionProps = regionprops(lb,'area','FilledImage','Centroid');
        
        %inds = find(minArea < [regionProps.Area] < maxArea);
        inds = [];
        for k = 1 : length(regionProps)
            if find([regionProps(k).Area] < maxArea & [regionProps(k).Area] > minArea)
                inds = [ inds k ];
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
        %clf(mainFigure, 'reset');
        
    end
    

% filename = fullfile(matlabroot,'examples','matlab','mydataVesselsC.txt');
% fileID = fopen(filename);
% C = textscan(fileID,'%u %u %u %u %u %u %u');
% fclose(fileID);
% whos C
% celldisp(C)