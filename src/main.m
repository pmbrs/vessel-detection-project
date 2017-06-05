%% STARTING

function main
    clear
    clc
    close all
   
    imgBkg = imread('../Frames/frame0000.jpg');
    
    baseBkg = 0; % Initial Frame: 0 %
    baseNum = 0;
    
    nTotalFrames = 4800; % Total: 1536
    
    thr = 30;
    minArea = 10;
    maxArea = 50;
    alfa = 0.10;
    
    nFrameBkg = 1000;
    step = 10;
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

    stepRoi = 15;
    nFrameROI = nTotalFrames;  % 23354 Frames used to compute background image

    for i = baseNum : stepRoi : nFrameROI

        imgfrNew = imread(sprintf('../Frames/frame%.4d.jpg', ...
                        baseNum + i));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        sprintf('ROI %d',i);
        hold off
        
        imgdif = (abs(double(imgBkgBase(:,:,1))-double(imgfrNew(:,:,1)))>thr) | ...
        (abs(double(imgBkgBase(:,:,2))-double(imgfrNew(:,:,2)))>thr) | ...
        (abs(double(imgBkgBase(:,:,3))-double(imgfrNew(:,:,3)))>thr);
    
    
        bw = imclose(imgdif,se);
        str = sprintf('Frame: %d',i); title(str);
        
        drawnow
        clf(mainFigure, 'reset');
        
    end
    
end