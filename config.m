% config.m
% Version 1.0
% Configuration File
%
% Project: New Fusion
% By xjtang
% Created On: 7/2/2015
% Last Update: 7/3/2015
%
% Input Arguments: NA
% 
% Output Arguments: NA
%
% Instruction: 
%   1.Customize the inputs and settings for your fusion project.
%   2.Use this config file as input to generate main input structure.
%
% Version 1.0 - 10/8/2014 
%   This is a config file that includes the parameters and settings for your fusion project.
%   The file here is an example using default values.
%   Make a copy of this file and custimize for you specific proiject.
%
% Released on Github on 7/3/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------
%
% project information
    modisPlatform = 'MOD';          % MOD for Terra, MYD for Aqua
    landsatScene = [227,65];        % Landsat path and row
    dataPath = '/projectnb/landsat/projects/fusion/br_site/data/modis/';
                                    % data path
                                            
% main settings
    BRDF = 0;                       % BRDF correction switch
    BIAS = 1;                       % bias correction switch
    discardRatio = 0;               % portion of Landsat pixel to be excluded on the edge
    diffMethod = 0;                 % method used in difference calculation, max(0) or mean(1)

% model parameters
    minNoB = 10;                    % minimun number of valid observation
    initNoB = 5;                    % number of observation or initialization
    nStandDev = 1.5;                % number of standard deviation to flag a suspect
    nConsecutive = 5;               % number of consecutive observation to detect change
    nSuspect = 3;                   % number of suspect to confirm a change
    outlierRemove = 1;              % switch for outlier removing in initialization
    thresNonFstMean = 10;           % threshold of mean for non-forest detection
    thresNonFstStd = 0.3;           % threshold of std for non-forest detection
    thresEdge = 5;                  % thresold of detecting pixel with edging effect
    bandIncluded = [3,4,5];         % bands to be included in change detection
    bandWeight = [1,1,1];           % weight on each band
    
% done
    