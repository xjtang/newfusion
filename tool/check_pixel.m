% check_pixel.m
% Version 1.0
% Tools
%
% Project: New Fusion
% By xjtang
% Created On: 7/22/2015
% Last Update: 7/22/2015
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
% Version 1.0 - 7/22/2015
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
        disp('config file does not exist, abort.')
        return;
    end
    
    % check cache files location
    cachePath = [dataPath 'P' num2str(landsatScene(1),'%03d') 'R' num2str(landsatScene(2),'%03d') '/CACHE/'];
    if exist(cachePath,'dir') == 0 
        disp('cache folder does not exist, abort.')
        return;
    end
    
    
    

end

