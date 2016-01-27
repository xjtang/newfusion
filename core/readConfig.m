% readConfig.m
% Version 1.0.1
% Core
%
% Project: New Fusion
% By xjtang
% Created On: 1/11/2016
% Last Update: 1/26/2016
%
% Input Arguments:
%   file (String) - full path and file name to the config file
%
% Output Arguments: 
%   config (Structure) - a structure of all inputs from the config file
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 1.0 - 1/11/2016
%   Function to read config.m file as a text file.
%
% Updates of Version 1.0.1 - 1/26/2016
%   1.Added a new parameter to control the linear model check.
%
% Released on Github on 1/11/2016, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function config = readConfig(file)
    
    % initialize
    config = [];

    % check if file exist
    if ~exist(file,'file') 
        disp('Config file does not exist.');
        return;
    end

    % open file and read line by line
    Fconfig = fopen(file,'r');
    while ~feof(Fconfig)
        
        % read in one line without l/t spaces
        thisLine = strtrim(fgetl(Fconfig));
        
        % check this line
        if isempty(thisLine)
            continue;
        elseif strcmp(thisLine(1),'%')
            continue;
        end
            
        % parse this line
        [trueLine,~] = strtok(thisLine,'%;');
        [keyName,rem] = strtok(trueLine,'=');
        [keyString,~] = strtok(rem,'=');
        keyName = strtrim(keyName);
        keyString = strtrim(keyString);
        
        % parse keyString
        if strcmp(keyString(1),'''')
            % is string
            keyValue = strrep(keyString,'''','');
        elseif strcmp(keyString(1),'[')
            % is vector
            keyValue = str2num(keyString);
        else
            % is number 
            keyValue = str2double(keyString);
        end
        
        % assign this key
        config.(keyName) = keyValue;
        
    end
    fclose(Fconfig);
    
    % check version config file
    curVersion = 10113;
    if ~isfield(config,'configVer')
        disp('WARNING!!!!');
        disp('Unknown config file version, unexpected error may occur.');
        disp('WARNING!!!!');
        config.configVer = 0;
    elseif config.configVer < curVersion
        disp('WARNING!!!!');
        disp('You are using older version of config file, unexpected error may occur.');
        disp('WARNING!!!!');
    end
    
    % check if all parameters exist in config file
        % project information
        % data path
        if ~isfield(config,'dataPath')
            config.dataPath = '/projectnb/landsat/projects/fusion/amz_site/data/modis/';
        end
        % landsat path and row
        if ~isfield(config,'landsatScene')
            config.landsatScene = [227,65];
        end
        % modis platform
        if ~isfield(config,'modisPlatform')
            config.modisPlatform = 'ALL';
        end
        
        % main settings
        % BRDF switch
        if ~isfield(config,'BRDF')
            config.BRDF = 0;
        end
        % bias switch
        if ~isfield(config,'BIAS')
            config.BIAS = 1;
        end
        % discard ratio
        if ~isfield(config,'discardRatio')
            config.discardRatio = 0;
        end
        % difference map method
        if ~isfield(config,'diffMethod')
            config.diffMethod = 1;
        end
        % cloud threshold
        if ~isfield(config,'cloudThres')
            config.cloudThres = 80;
        end
        % start date of the study time period
        if ~isfield(config,'startDate')
            config.startDate = 2013001;
        end
        % start date of the study time period
        if ~isfield(config,'endDate')
            config.endDate = 2015001;
        end
        % start date of the near real time change detection
        if ~isfield(config,'nrtDate')
            config.nrtDate = 2014001;
        end
        
        % model parameters
        % number of observation before a break can be detected
        if ~isfield(config,'minNoB')
            config.minNoB = 40;
        end
        % number of observation or initialization
        if ~isfield(config,'initNoB')
            config.initNoB = 20;
        end
        % number of standard deviation to flag a suspect
        if ~isfield(config,'nStandDev')
            config.nStandDev = 3;
        end
        % number of consecutive observation to detect change
        if ~isfield(config,'nConsecutive')
            config.nConsecutive = 6;
        end
        % number of suspect to confirm a change
        if ~isfield(config,'nSuspect')
            config.nSuspect = 4;
        end
        % switch for outlier removing in initialization
        if ~isfield(config,'outlierRemove')
            config.outlierRemove = 2;
        end
        % threshold of mean for non-forest detection
        if ~isfield(config,'thresNonFstMean')
            config.thresNonFstMean = 150;
        end
        % threshold of std for non-forest detection
        if ~isfield(config,'thresNonFstStd')
            config.thresNonFstStd = 250;
        end
        % threshold of slope for non-forest detection
        if ~isfield(config,'thresNonFstSlp')
            config.thresNonFstSlp = 200;
        end
        % threshold of R2 for non-forest detection
        if ~isfield(config,'thresNonFstR2')
            config.thresNonFstR2 = 30;
        end
        % threshold of RMSE for non-forest detection
        if ~isfield(config,'thresNonFstRMSE')
            config.thresNonFstRMSE = 200;
        end
        % threshold of detecting change edging pixel
        if ~isfield(config,'thresChgEdge')
            config.thresChgEdge = 0.65;
        end
        % threshold of detecting non-forest edging pixel
        if ~isfield(config,'thresNonFstEdge')
            config.thresNonFstEdge = 0.35;
        end
        % spectral threshold for edge detecting
        if ~isfield(config,'thresSpecEdge')
            config.thresSpecEdge = 100;
        end
        % threshold for n observation after change to confirm change
        if ~isfield(config,'thresProbChange')
            config.thresProbChange = 8;
        end
        % bands to be included in change detection
        if ~isfield(config,'bandIncluded')
            config.bandIncluded = [7,8];
        end
        % weight on each band
        if ~isfield(config,'bandWeight')
            config.bandWeight = [1,1];
        end
        % weight on each band
        if ~isfield(config,'lmMinNoB')
            config.lmMinNoB = 20;
        end
    
    % done

end
