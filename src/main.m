%% STARTING

function main
    clear
    clc
    close all
    
    imgBkg = imread('../Frames/frame0000.jpg');
    
    baseBkg = 0; % Initial Frame: 0 %
    baseNum = 0;
    
    nTotalFrames = 1536; % Total: 1536
    
    thr = 10;%30
    minArea = 10;%10
    maxArea = 40;%50
    alfa = 0.10;%0.10
    
    nFrameBkg = 1000;
    step = 15;
    Bkg = zeros(size(imgBkg));
    
    mainFigure = figure(1);
    
    numKeyFrames = 0;
    
    se = strel('disk',3);

    for i = 0 : step : nFrameBkg

        imgfr = imread(sprintf('../Frames/frame%.4d.jpg', ...
                        baseNum + i));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        Y = imgfr;
        Bkg = alfa * double(Y) + (1 - alfa) * double(Bkg);

        imgUInt8 = uint8(Bkg);
    end
    
    % ------------------ END Backgroud ------------------ %

    % --------------------------------------------------- %

    imgBkgBase = imgUInt8; % Imagem de background

    % -------------------- ROI -------------------------- %
    % Remove object intersection
    % Faz as caixinhas

    stepRoi = 10;
    nFrameROI = nTotalFrames;  % 23354 Frames used to compute background image

    for i = baseNum : stepRoi : nFrameROI

        imgfrNew = imread(sprintf('../Frames/frame%.4d.jpg', ...
                        baseNum + i));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        sprintf('ROI %d',i);
        hold off
        
        %imshow(imgfrNew); %% Caminho rectangulos amarelos - Background 
        hold on
        
        imgdif = (abs(double(imgBkgBase(:,:,1))-double(imgfrNew(:,:,1)))>thr) | ...
            (abs(double(imgBkgBase(:,:,2))-double(imgfrNew(:,:,2)))>thr) | ...
            (abs(double(imgBkgBase(:,:,3))-double(imgfrNew(:,:,3)))>thr);
    
    
        bw = imclose(imgdif,se);
        str = sprintf('Frame: %d',i); title(str);
        
        % ----------------------------------------------------------- %
        imshow(bw);  %%Mete Background preto ao mesmo tempo
        % ----------------------------------------------------------- %
        
        drawnow
        clf(mainFigure, 'reset');
        
    end
    
end

% filename = fullfile(matlabroot,'examples','matlab','mydata.txt');
% fileID = fopen(filename);
% C = textscan(fileID,'%u %u %u %u %u %u %u','Delimiter','\n');
% fclose(fileID);
% whos C
% celldisp(C)