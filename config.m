% config.m
% Version 1.1.6
% Configuration File
%
% Project: New Fusion
% By xjtang
% Created On: 7/2/2015
% Last Update: 9/13/2015
%
% Input Arguments: NA
% 
% Output Arguments: NA
%
% Instruction: 
%   1.Customize the inputs and settings for your fusion project.
%   2.Use this config file as input to generate main input structure.
%
% Version 1.0 - 7/3/2015 
%   This is a config file that includes the parameters and settings for your fusion project.
%   The file here is an example using default values.
%   Make a copy of this file and custimize for you specific proiject.
%
% Updates of Version 1.1 - 7/9/2015
%   1.Added a setting for type of change map to generate.
%   2.Split edging threshold into two.
%
% Updates of Version 1.1.1 - 7/16/2014
%   1.Added a spectral threshold for edge detecting.
%   2.Adjusted default value.
%   
% Updates of Version 1.1.2 - 7/18/2015
%   1.Added a new threshold for probable change detecting.
%   2.Adjusted default value.
%
% Updates of Version 1.1.3 - 7/22/2015
%   1.Threshold for edge finding percentized.
%   2.Adjusted default value.
%
% Updates of Version 1.1.4 - 8/3/2015
%   1.Adjusted default values.
%
% Updates of Version 1.1.5 - 8/25/2015
%   1.Added a paramter for cloud filtering.
%   2.Adjusted default values.
%
% Updates of Version 1.1.6 - 9/13/2015
%   1.Added a threhold for detecting water body.
%   2.Adjusted default values.
%
% Released on Github on 7/3/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------
%
% project information
    modisPlatform = 'MOD';          % MOD for Terra, MYD for Aqua
    landsatScene = [227,65];        % Landsat path and row
    dataPath = '/projectnb/landsat/projects/fusion/br_site/data/modis/fusion/';
                                    % data path
                                            
% main settings
    BRDF = 0;                       % BRDF correction switch
    BIAS = 1;                       % bias correction switch
    discardRatio = 0;               % portion of Landsat pixel to be excluded on the edge
    diffMethod = 0;                 % method used in difference calculation, max(0) or mean(1)
    mapType = 3;                    % type of map to be generated, date(1)/month(2) of change, change only map (3)
    cloudThres = 80;                % A threshold on percent cloud cover for data filtering.
    
% model parameters
    minNoB = 40;                    % number of observation before a break can be detected
    initNoB = 40;                   % number of observation or initialization
    nStandDev = 2.5;                % number of standard deviation to flag a suspect
    nConsecutive = 6;               % number of consecutive observation to detect change
    nSuspect = 4;                   % number of suspect to confirm a change
    outlierRemove = 5;              % switch for outlier removing in initialization
    thresNonFstMean = 225;          % threshold of mean for non-forest detection
    thresNonFstStd = 100;           % threshold of std for non-forest detection
    thresChgEdge = 0.65;            % threshold of detecting change edging pixel
    thresNonFstEdge = 0.35;         % threshold of detecting non-forest edging pixel
    thresSpecEdge = 100;            % spectral threshold for edge detecting
    thresProbChange = 8;            % threshold for n observation after change to confirm change
    bandIncluded = [7,8];           % bands to be included in change detection (band 7/8 are 250m)
    bandWeight = [1,1];             % weight on each band
    
% done
    
