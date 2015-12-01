% fusion_Inputs.m
% Version 2.3.2
% Step 0
% Main Inputs and Settings
%
% Project: New Fusion
% By xjtang
% Created On: 9/16/2013
% Last Update: 12/1/2015
%
% Input Arguments: 
%   file (String) - full path and file name to the config file
%   job (Vector, Interger) - jobn information e.g. [1 50] means 1st job of total 50 jobs, [0 0] means single job.
% 
% Output Arguments: 
%   main (Structure) - main inputs for the whole fusion process
%
% Instruction: 
%   1.Customize a config file for your project.
%   2.Run this stript with the config file to create a new structure of inputs.
%   3.Use the created inputs as input arguments for other functions.
%
% Version 1.0 - 10/8/2014 
%   This script newly created for Fusion update 6.1
%   This script serves as a single repository for all inputs and settings for the fusion process
%
% Updates of Version 1.1 - 10/14/2014 
%   1.This script now loads the hrf module
%
% Updates of Version 1.1.1 - 11/24/2014 
%   1.Improved main input structure.
%   2.Updated comments.
%   3.Bug fixed.
%
% Updates of Version 1.2 - 11/24/2014 
%   1.Added support for MODIS Aqua.
%
% Updates of Version 1.2.1 - 12/15/2014 
%   1.Added a dump folder for collecting dumped data.
%   2.Added missing ;.
%   3.Removed unused folder.
%
% Updates of Version 1.2.2 - 2/10/2015 
%   1.Added new output folders to hold change and difference maps.
%   2.Adjusted output folders.
%   3.Added a extra parameter for bias correction.
%
% Updates of Version 1.2.3 - 3/31/2015 
%   1.Fixed a bug when MOD09GA is missing.
%   2.Added a new option.
%   3.Renamed the output folder for dif image.
%
% Update of Version 1.3 - 4/3/2015 
%   1.Combined 250m and 500m fusion.
%
% Updates of Version 1.4 - 6/16/2015 
%   1.Added settings and parameters of the change detection model.
%   2.Added support for change detection model.
%
% Updates of Version 1.5 - 7/1/2015 
%   1.Added output folder for cache and change detection results.
%   2.Added new input of path and row of Landsat.
%   3.Implemented new file structure to support multiple Landsat scenes.
%   4.Added output folder for files created by tools.
%   5.Adjusted some names of output folder.
%
% Updates of Version 2.0 - 7/4/2015
%   1.Added a new component that reads an external config file for model settings and parameters.
%   2.Optimized user experience.
%   3.Shrinked the number of input arguments.
%   4.Fixed a bug of two digit landsat scene.
%   5.Other bugs fixded
%
% Updates of Version 2.1 - 7/6/2015
%   1.Optimized the way of splitting jobs.
%   2.Fixed output folder bug for BRDF result.
%   3.Added a change map output folder.
%
% Updates of Version 2.2 - 7/7/2015
%   1.Added a new setting for change map type.
%   2.Split edging threshold into two.
%
% Updates of Version 2.2.1 - 7/16/2015
%   1.Added a spectral threshold for edge detecting. 
%   2.Adjusted default value.
%
% Updates of Version 2.2.2 - 7/18/2015
%   1.Added a probable change threshold.
%   2.Adjusted default values.
%
% Updates of Version 2.2.3 - 7/22/2015
%   1.Threshold for edge finding percentized.
%   2.Adjusted default value.
%   3.Fixed a typo in comment.
%
% Updates of Version 2.2.4 - 8/3/2015
%   1.Adjusted default values.
%
% Updates of Version 2.2.5 - 8/5/2015
%   1.Check if the parent output folder exist.
%   2.Fixed a wrong default value.
%
% Updates of Version 2.2.6 - 8/25/2015
%   1.Added a new cloud threshold.
%   2.Adjusted the default values.
%
% Updates of Version 2.2.7 - 9/18/2015
%   1.Added a threhold for detecting water body.
%   2.Adjusted default value.
%   3.Added a output folder for coefficient maps.
%
% Updates of Version 2.2.8 - 9/24/2015
%   1.Added version control of the config file.
%   2.Adjusted default value.
%
% Updates of Version 2.3 - 10/18/2015
%   1.Added new parameters.
%   2.Remvoed un-used parameters.
%   3.Adjusted default values.
%   4.Added fusion TS segment class codes.
%   5.Added landcover class codes.
%   6.Added model constants.
%
% Updates of Version 2.3.1 - 11/11/2015
%   1.Added new project parameters for study time period control.
%   2.Added new model constants.
%   3.Fixed a variable that may cause error.
%   4.Deleted unused parameters.
%   5.Normalize weight.
%
% Updates of Version 2.3.2 - 12/1/2015
%   1.Adjuste default values.
%   2.Added support for combining Terra and Aqua.
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------
%
function main = fusion_Inputs(file,job)

    % add the fusion package to system path
    addpath(genpath(fileparts(mfilename('fullpath'))));

    % load module
    system('module load hdf/4.2.5');
    system('module load gdal/1.10.0');
    
    % check input argument
    if ~exist('file', 'var')
        file = '/projectnb/landsat/projects/fusion/codes/new_fusion/config.m';
    end
    if (~exist('job', 'var'))||(min(job)<1)||(job(1)>job(2))
        job = [0,0];
    end
    
    % load config file
    if exist(file,'file')
        run(file);
    end
    
    % check version config file
    curVersion = 10110;
    if ~exist('configVer','var')
        disp('WARNING!!!!');
        disp('WARNING!!!!');
        disp('Unknown config file version, unexpected error may occur.');
        disp('WARNING!!!!');
        disp('WARNING!!!!');
        configVer = 0;
    elseif configVer < curVersion
        disp('WARNING!!!!');
        disp('WARNING!!!!');
        disp('You are using older version of config file, unexpected error may occur.');
        disp('WARNING!!!!');
        disp('WARNING!!!!');
    end
    
    % check if all parameters exist in config file
        % project information
        % data path
        if ~exist('dataPath', 'var')
            dataPath = '/projectnb/landsat/projects/fusion/amz_site/data/modis/';
        end
        % landsat path and row
        if ~exist('landsatScene', 'var')
            landsatScene = [227,65];
        end
        % modis platform
        if ~exist('modisPlatform', 'var')
            modisPlatform = 'ALL';
        end
        
        % main settings
        % BRDF switch
        if ~exist('BRDF', 'var')
            BRDF = 0;
        end
        % bias switch
        if ~exist('BIAS', 'var')
            BIAS = 1;
        end
        % discard ratio
        if ~exist('discardRatio', 'var')
            discardRatio = 0;
        end
        % difference map method
        if ~exist('diffMethod', 'var')
            diffMethod = 1;
        end
        % cloud threshold
        if ~exist('cloudThres', 'var')
            cloudThres = 80;
        end
        % start date of the study time period
        if ~exist('startDate', 'var')
            startDate = 2013001;
        end
        % start date of the study time period
        if ~exist('endDate', 'var')
            endDate = 2015001;
        end
        % start date of the near real time change detection
        if ~exist('nrtDate', 'var')
            nrtDate = 2014001;
        end
        
        % model parameters
        % number of observation before a break can be detected
        if ~exist('minNoB', 'var')
            minNoB = 40;
        end
        % number of observation or initialization
        if ~exist('initNoB', 'var')
            initNoB = 20;
        end
        % number of standard deviation to flag a suspect
        if ~exist('nStandDev', 'var')
            nStandDev = 3;
        end
        % number of consecutive observation to detect change
        if ~exist('nConsecutive', 'var')
            nConsecutive = 6;
        end
        % number of suspect to confirm a change
        if ~exist('nSuspect', 'var')
            nSuspect = 4;
        end
        % switch for outlier removing in initialization
        if ~exist('outlierRemove', 'var')
            outlierRemove = 2;
        end
        % threshold of mean for non-forest detection
        if ~exist('thresNonFstMean', 'var')
            thresNonFstMean = 150;
        end
        % threshold of std for non-forest detection
        if ~exist('thresNonFstStd', 'var')
            thresNonFstStd = 250;
        end
        % threshold of slope for non-forest detection
        if ~exist('thresNonFstSlp', 'var')
            thresNonFstSlp = 200;
        end
        % threshold of R2 for non-forest detection
        if ~exist('thresNonFstR2', 'var')
            thresNonFstR2 = 30;
        end
        % threshold of detecting change edging pixel
        if ~exist('thresChgEdge', 'var')
            thresChgEdge = 0.65;
        end
        % threshold of detecting non-forest edging pixel
        if ~exist('thresNonFstEdge', 'var')
            thresNonFstEdge = 0.35;
        end
        % spectral threshold for edge detecting
        if ~exist('thresSpecEdge', 'var')
            thresSpecEdge = 100;
        end
        % threshold for n observation after change to confirm change
        if ~exist('thresProbChange', 'var')
            thresProbChange = 8;
        end
        % bands to be included in change detection
        if ~exist('bandIncluded', 'var')
            bandIncluded = [7,8];
        end
        % weight on each band
        if ~exist('bandWeight', 'var')
            bandWeight = [1,1];
        end
        
    % set project main path
    main.path = dataPath;
    main.outpath = [main.path 'P' num2str(landsatScene(1),'%03d') 'R' num2str(landsatScene(2),'%03d') '/'];
    if exist(main.outpath,'dir') == 0 
        mkdir([main.path 'P' num2str(landsatScene(1),'%03d') 'R' num2str(landsatScene(2),'%03d')]);
    end
    
    % set input data location
        % main inputs:
        % Landsat ETM images to fuse
        main.input.etm = [main.path 'ETMSYN/P' num2str(landsatScene(1),'%03d') 'R' num2str(landsatScene(2),'%03d') '/'];
        % MODIS Surface Reflectance data (swath data)
        main.input.swath = [main.path 'SWATH/'];

        % for BRDF correction process only:
        % daily gridded MODIS suface reflectance data
        main.input.grid = [main.path 'GRID/'];
        % BRDF/Albedo model parameters product
        main.input.brdf = [main.path 'MCD43A1/'];
          
        % for 250m BRDF correction process only:
        % gridded 250m resolution band 1 and 2 surface reflectance data
        main.input.g250m = [main.path 'GRID250/'];
        
    % set output data location (create if not exist)
        % main outputs:
        % MODIS sub image that covers the Landsat ETM area
        main.output.modsub = [main.outpath 'MOD09SUB/'];
        if exist(main.output.modsub,'dir') == 0 
            mkdir([main.outpath 'MOD09SUB']);
        end
        % fused MOD09SUB
        main.output.modsubf = [main.outpath 'MOD09FUS/'];
        if exist(main.output.modsubf,'dir') == 0 
            mkdir([main.outpath 'MOD09FUS']);
        end
        % MOD09SUB with change and difference image
        main.output.modsubd = [main.outpath 'MOD09DIF/'];
        if exist(main.output.modsubd,'dir') == 0 
            mkdir([main.outpath 'MOD09DIF']);
        end
        % fused synthetic MODIS image from ETM image
        main.output.fusion = [main.outpath 'MODFUS/'];
        if exist(main.output.fusion,'dir') == 0 
            mkdir([main.outpath 'MODFUS']);
        end
        % difference between synthetic MODIS and true MODIS
        main.output.dif = [main.outpath 'ETMDIF/'];
        if exist(main.output.dif,'dir') == 0 
            mkdir([main.outpath 'ETMDIF']);
        end
        
        % from BRDF correction
        % BRDF parameters at Landsat scale
        main.output.etmBRDF = [main.outpath 'BRDFETM/'];
        if exist(main.output.etmBRDF,'dir') == 0 
            mkdir([main.outpath 'BRDFETM']);
        end
        % BRDF coefficients grabbed from the BRDF product
        main.output.modBRDF = [main.path 'BRDF/'];
        if exist(main.output.modBRDF,'dir') == 0 
            mkdir([main.path 'BRDF']);
        end
        % fused synthetic MODISimage with BRDF correction
        main.output.modsubbrdf = [main.outpath 'BRDFFUS/'];
        if exist(main.output.modsubbrdf,'dir') == 0 
            mkdir([main.outpath 'BRDFFUS']);
        end
    
        % from change detection
        % cache of fusion time series
        main.output.cache = [main.outpath 'CACHE/'];
        if exist(main.output.cache,'dir') == 0 
            mkdir([main.outpath 'CACHE']);
        end
        % change detection model results in matlab format
        main.output.chgmat = [main.outpath 'CHGMAT/'];
        if exist(main.output.chgmat,'dir') == 0 
            mkdir([main.outpath 'CHGMAT']);
        end
        % change maps
        main.output.chgmap = [main.outpath 'CHGMAP/'];
        if exist(main.output.chgmap,'dir') == 0 
            mkdir([main.outpath 'CHGMAP']);
        end
        % coefficients maps
        main.output.coefmap = [main.outpath 'COEFMAP/'];
        if exist(main.output.coefmap,'dir') == 0 
            mkdir([main.outpath 'COEFMAP']);
        end
        
        % other output folder
        % a dump folder for temporaryly storing dumped data
        main.output.dump = [main.path 'DUMP/'];
        if exist(main.output.dump,'dir') == 0 
            mkdir([main.path 'DUMP']);
        end
        % a folder that contains all files that will be created by tools
        main.output.vault = [main.path 'VAULT/'];
        if exist(main.output.vault,'dir') == 0 
            mkdir([main.path 'VAULT']);
        end

    % model constants
        % NA value for Landsat images
        main.cons.etmna = -9999;
        % scale factor of landsat images
        main.cons.etmsf = 10000;
        % NA value for synthetic images
        main.cons.synna = 0;
        % NA value for MCD43A1 products
        main.cons.mcdna = 30000;
        % scale factor for MCD43A1 products
        main.cons.mcdsf = 1000;
        % scale factor for modis angles
        main.cons.angsf = 100;
        % Na value for outputs
        main.cons.outna = -9999;
        % days in one year
        main.cons.diy = 365.25;
        
    % project information
        % config file version
        main.set.cver = configVer;
        % platform of MODIS
        main.set.plat = modisPlatform;
        % Landsat scene
        main.set.scene = landsatScene;
        % job information
        main.set.job = job;
        
    % settings and parameters
        % apply BRDF correction or not
        main.set.brdf = BRDF;
        % discard ratio of Landsat image (% image discarded on the edge)
        main.set.dis = discardRatio;
        % correct for bias in difference map
        main.set.bias = BIAS;
        % max (0) or mean (1) in calculating difference map
        main.set.dif = diffMethod;
        % a threshold on percent cloud cover for data filtering
        main.set.cloud = cloudThres;
        % start date of the study time period
        main.set.sdate = startDate;
        % end date of the study time period
        main.set.edate = endDate;
        % start date of the near real time change detection
        main.set.cdate = nrtDate;
        
    % settings and parameters for the change detection model
        % number of observation before a break can be detected
        main.model.minNoB = minNoB;
        % number of observations to initialize the model
        main.model.initNoB = initNoB;
        % coefficiant of std in change detection
        main.model.nSD = nStandDev;
        % number of consective observation of detect change
        main.model.nCosc = nConsecutive;
        % number of suspective observation to confirm the change
        main.model.nSusp = nSuspect;
        % number of outlier to remove in initialization
        main.model.outlr = outlierRemove;
        % threshold of mean to detect non-forest pixel
        main.model.nonFstMean = thresNonFstMean;
        % threshold of std to detect non-forest pixel
        main.model.nonFstStd = thresNonFstStd;
        % threshold of slope to detect non-forest pixel
        main.model.nonFstSlp = thresNonFstSlp;
        % threshold of r2 to detect non-forest pixel
        main.model.nonFstR2 = thresNonFstR2;
        % threshold of std to detect non-forest pixel
        main.model.chgEdge = thresChgEdge;
        % threshold of detecting edging pixel in stable non-forest pixel
        main.model.nonFstEdge = thresNonFstEdge;
        % spectral threshold for edge detecting
        main.model.specEdge = thresSpecEdge;
        % threshold for n observation after change to confirm change
        main.model.probThres = thresProbChange;
        % bands used for change detection
        main.model.band = bandIncluded;
        % weight of each band in change detection (normalized)
        main.model.weight = bandWeight./(sum(bandWeight));
        
    % fusion TS segment class codes
        main.TSclass.NA = -1;           % not available
        main.TSclass.Default = 0;       % default
        main.TSclass.Stable = 1;        % stable forest
        main.TSclass.Outlier = 2;       % outlier (e.g. cloud)
        main.TSclass.Break = 3;         % change break
        main.TSclass.Changed = 4;       % changed to non-forest
        main.TSclass.ChgEdge = 5;       % edge of change
        main.TSclass.NonForest = 6;     % stable non-forest
        main.TSclass.NFEdge = 7;        % edge of stable non-forest
        
    % land cover clas codes
        main.LCclass.NA = -9999;        % no data
        main.LCclass.Default = -1;      % default
        main.LCclass.Forest = 0;        % stable forest
        main.LCclass.NonForest = 5;     % stable non-forest
        main.LCclass.NFEdge = 6;        % non-forest edge
        main.LCclass.Change = 10;       % change
        main.LCclass.CEdge = 11;        % edge of change
        main.LCclass.Prob = 12;         % unconfirmed change
        
    % image properties
        % grab the first ETM file
        main.etm.first = dir([main.input.etm '*.hdr']);
        if numel(main.etm.first) == 0 
            main.etm.first = dir([main.input.etm '*.HDR']);
        end
        main.etm.first = [main.input.etm main.etm.first(1).name];
        % read information from the first ETM image in the input folder
        [img.dim,img.ul,img.res,img.utm,img.bands,img.itl] = envihdrread(main.etm.first);
        % ETM geo information
        main.etm.sample = 1:img.dim(1);
        main.etm.line = (1:img.dim(2))';
        main.etm.res = img.res;
        main.etm.band = img.bands;
        main.etm.utm = img.utm;
        main.etm.ulNorth = img.ul(2);
        main.etm.ulEast = img.ul(1);
        main.etm.lrNorth = main.etm.ulNorth-main.etm.res(2)*main.etm.line(end);
        main.etm.lrEast = main.etm.ulEast+main.etm.res(1)*main.etm.sample(end);
        main.etm.interleave = img.itl;
        % ETM subsetting information (discard data on the edge);
        main.etm.discard = [floor(main.etm.sample(end)*main.set.dis) floor(main.etm.line(end)*main.set.dis)];
        main.etm.subSample = (main.etm.discard(1)+1):(main.etm.sample(end)-main.etm.discard(1));
        main.etm.subLine = ((main.etm.discard(2)+1):(main.etm.line(end)-main.etm.discard(2)))';
        main.etm.subULNorth = main.etm.ulNorth-main.etm.res(2)*main.etm.discard(2);
        main.etm.subULEast = main.etm.ulEast+main.etm.res(1)*main.etm.discard(1);
        main.etm.subLRNorth = main.etm.lrNorth+main.etm.res(2)*main.etm.discard(2);
        main.etm.subLREast = main.etm.lrEast-main.etm.res(1)*main.etm.discard(1);
        
    % date information
        % dates of MODIS swath images used for this study
        main.date.swath = getDateList(main.input.swath);
        % dates of Landsat synthetic images used for this study
        main.date.etm = getDateList(main.input.etm);
        if main.set.brdf == 1
            % dates of the MODIS gridded images used for this study
            main.date.grid = getDateList(main.input.grid);
            % dates of the BRDF data used for this study
            main.date.brdf = getDateList(main.input.brdf);
        end
    
    % divide into parts
        if min(job>0)       
            % total number of work load
            total = numel(main.date.swath);
            % subset work load for each job
            main.date.swath = main.date.swath(job(1):job(2):total);
        end
    
    % done

end
