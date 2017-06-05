filename = fullfile(matlabroot,'examples','matlab','mydataVesselsC.txt');
fileID = fopen(filename);
C = textscan(fileID,'%u %u %u %u %u %u %u');
fclose(fileID);
whos C
celldisp(C)