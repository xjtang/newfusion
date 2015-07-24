% check_pixel.m
% Version 1.0
% Tools
%
% Project: New Fusion
% By xjtang
% Created On: 7/22/2015
% Last Update: 7/24/2015
%
% Input Arguments: 
%   file - path to config file
%   row - row number of the pixel
%   col - column number of the pixel
%   
% Output Arguments: 
%   R (Structure) - outputs of each step in change detection.
%
% Instruction: 
%   1.Generate cache files of fusion time series.
%   2.Run this script with correct input arguments.
%
% Version 1.0 - 7/24/2015
%   This script gathers intermediate outputs of change detection on individual pixel.
%
% Created on Github on 7/22/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function R = check_pixel(file,row,col)
    
    % initialize
    R = -1;

    % load config file
    if exist(file,'file')
        run(file);
    else
        disp('config file does not exist, abort.');
        return;
    end
    
    % grab model parameters
    R.model.minNoB = minNoB;
    R.model.initNoB = initNoB;
    R.model.nSD = nStandDev;
    R.model.nCosc = nConsecutive;
    R.model.nSusp = nSuspect;
    R.model.outlr = outlierRemove;
    R.model.nonfstmean = thresNonFstMean;
    R.model.nonfstdev = thresNonFstStd;
    R.model.chgedge = thresChgEdge;
    R.model.nonfstedge = thresNonFstEdge;
    R.model.specedge = thresSpecEdge;
    R.model.probThres = thresProbChange;
    R.model.band = bandIncluded;
    R.model.weight = bandWeight/sum(bandWeight);
    
    % check cache files location
    cachePath = [dataPath 'P' num2str(landsatScene(1),'%03d') 'R' num2str(landsatScene(2),'%03d') '/CACHE/'];
    if exist(cachePath,'dir') == 0 
        disp('cache folder does not exist, abort.');
        return;
    end
    
    % find the cache file for this row
    cacheFile = [cachePath 'ts.r' num2str(row) '.cache.mat'];
    if exist(cacheFile,'file') == 0
        disp('cache file does not exist, sbort.');
        return;
    end
    
    % load thetime series of the pixel
    raw = load(cacheFile);
    raw.Data = squeeze(raw.Data(col,:,R.model.band))';
    raw.Date = raw.Date(:,1)';
    
    % remove unavailable observation
    R.ts = raw.Data(:,max(raw.Data>(-9999)));
    R.date = raw.Date(max(raw.Data>(-9999)));
    [~,R.model.nob] = size(R.ts); 
    
    % break detecting
    R.chg1 = zeros(1,R.model.nob);
    
    
    
    
    % assign class
    R.chg2 = zeros(1,R.model.nob);
    
    
    
    
    % visualize results
    
    
    
    
    
    % done
    
end

