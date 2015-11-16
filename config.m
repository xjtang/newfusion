% config.m
% Version 1.1.10
% Configuration File
%
% Project: New Fusion
% By xjtang
% Created On: 7/2/2015
% Last Update: 11/16/2015
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
% Updates of Version 1.1.6 - 9/17/2015
%   1.Added a threhold for detecting water body.
%   2.Adjusted default values.
%   3.Removed mapType setting, generates all maps now.
%
% Updates of Version 1.1.7 - 9/24/2015
%   1.Added version control for the config file.
%   2.Adjusted default value.
%
% Updates of Version 1.1.8 - 10/16/2015
%   1.Added a alpha term for chi-square test.
%   2.Removed un-used parameters.
%   3.Adjust default values.
%
% Updates of Version 1.1.9 - 11/2/2015
%   1.Added a date control system.
%   2.Fixed a variable name that will cause error.
%   3.Updated comments.
%
% Updates of Version 1.1.10 - 11/16/2015
%   1.Added new thresholds for change detection.
%   2.Updated version system.
%   3.Adjusted default values.
%
% Released on Github on 7/3/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------
%
% project information
    configVer = 10110;                % config file version DO NOT CHANGE THIS!!!
    modisPlatform = 'MOD';          % MOD for Terra, MYD for Aqua
    landsatScene = [227,65];        % Landsat path and row
    dataPath = '/projectnb/landsat/projects/fusion/amz_site/data/modis/';
                                    % data path
                                            
% main settings
    BRDF = 0;                       % BRDF correction switch
    BIAS = 1;                       % bias correction switch
    discardRatio = 0;               % portion of Landsat pixel to be excluded on the edge
    diffMethod = 1;                 % method used in difference calculation, max(0) or mean(1)
    cloudThres = 80;                % A threshold on percent cloud cover for data filtering.
    startDate = 2013001;            % start date of this analysis
    endDate = 2015001;              % end date of this analysis
    nrtDate = 2014001;              % start date of the near real time change detection
    
% model parameters
    minNoB = 40;                    % minimum number of valid observation
    initNoB = 20;                   % number of observation or initialization
    nStandDev = 3;                % number of standard deviation to flag a suspect
    nConsecutive = 6;               % number of consecutive observation to detect change
    nSuspect = 4;                   % number of suspect to confirm a change
    outlierRemove = 2;              % switch for outlier removing in initialization
    thresNonFstMean = 200;          % threshold of mean for non-forest detection
    thresNonFstStd = 200;           % threshold of std for non-forest detection
    thresNonFstSlp = 200;           % threshold of slope for non-forest detection
    thresNonFstR2 = 30;            % threshold of r2 for non-forest detection
    thresSpecEdge = 100;            % spectral threshold for edge detecting
    thresChgEdge = 0.65;            % threshold of detecting change edging pixel
    thresNonFstEdge = 0.35;         % threshold of detecting non-forest edging pixel
    thresProbChange = 8;            % threshold for n observation after change to confirm change
    bandIncluded = [7,8];           % bands to be included in change detection (band 7/8 are 250m)
    bandWeight = [1,1];             % weight on each band
    
% done
    
