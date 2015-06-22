% fusion_Cache.m
% Version 1.0
% Step 7
% Write Output
%
% Project: Fusion
% By Xiaojing Tang
% Created On: 6/15/2015
% Last Update: 6/16/2015
%
% Input Arguments: 
%   main (Structure) - main inputs of the fusion process generated by
%     fusion_inputs.m.
%
% Output Arguments: NA
%
% Usage: 
%   1.Customize the main input file (fusion_inputs.m) w     ith proper settings
%       for specific project.
%   2.Run fusion_Inputs() first and get the returned structure of inputs
%   3.Run previous steps first to make sure required data are already
%       generated.
%   4.Run this function with the stucture of inputs as the input argument.
%
% Version 1.0 - 6/16/2015
%   This script caches the Landsat style fusion time series into mat files.
%
% Released on Github on 6/15/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function fusion_Cache(main)

    % get ETM image size
    samp = length(main.etm.sample);
    line = length(main.etm.line);
    nband = main.etm.band;
    
    % calculate the lines that will be processed by this job
    njob = main.set.job(2);
    thisjob = main.set.job(1);
    if njob > 1 && thisjob > 1 
        % subset lines
        start = thisjob;
        stop = floor(line/njob);
        curLine = start:njob:stop;
    end
    
    % find existing fusion time series images
    fusImage = dir([main.output.dif main.set.scene(1) main.set.scene(2) '*']);
    
    % line by line processing
    for i = curLine
        
        % check if this line is already processed
        File.Check = dir([main.output.cache 'ts.r' i '*' '.mat']);
        if numel(File.Check) >= 1
            disp([DayStr ' already exist, skip this line.']);
            continue;
        end
        
        % initialize
        TS = ones(samp,numel(dates),nband)*(-9999);
        
        % loop through images
        for j = i:numel(fusImage)
            
            % get date information
            DayStr = num2str(dates(i));

            % check if image exist
            File.Check = dir([main.output.dif plat '*' DayStr '*']);
            if numel(File.Check) >= 1
                disp([DayStr ' dif image does not exist, skip this date.']);
                continue;
            end
            
            
            
            
        end
        
        
            
            
    end
        

    
end