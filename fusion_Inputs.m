% fusion_Inputs.m
% Version 1.5
% Step 0
% Main Inputs and Settings
%
% Project: New Fusion
% By xjtang
% Created On: 9/16/2013
% Last Update: 7/1/2015
%
% Input Arguments: 
%   iDate (String) - main path to the data.
%   iPlat (String) - platform, MOD for Terra, MYD for Aqua.
%   iBRDF (Integer) - 0: BRDF off; 1: BRDF on.
%   iDis (Double) - Percenatble of data discarded at the edge of Landsat image (0.1 as 10%).
%   iSub (Vector, Interger) - process a subset of the data. e.g. [1 50] means divide into 50 parts and process the 1st. [0 0] means do all in one job.
% 
% Output Arguments: 
%   mainInputs (Structure) - main inputs for the whole fusion process
%
% Instruction: 
%   1.Customize the inputs and settings for your fusion project.
%   2.Run this stript first to create a new structure of all inputs
%   3.Use the created inputs as input arguments for other function
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
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------
%
function main = fusion_Inputs(iData,iPlat,iBRDF,iSub,iScene)

    % check input argument
    if ~exist('iSub', 'var')
        iSub = [0,0];
    end
    if ~exist('iDis', 'var')
        iDis = 0;
    end
    if ~exist('iBRDF', 'var')
        iBRDF = 0;
    end
    if ~exist('iData', 'var')
        iData = '/projectnb/landsat/projects/fusion/srb_site/';
    end
    if ~exist('iPlat', 'var')
        iPlat = 'MOD';
    end
    if ~exist('iScene', 'var')
        iScene = [227,65];
    end 

    % add the fusion package to system path
    addpath(genpath(fileparts(mfilename('fullpath'))));
    
    % load module
    system('module load hdf/4.2.5');
    system('module load gdal/1.10.0');
    
    % set up project main path
    main.path = iData;
    main.outpath = [main.path 'P' iScene(1) 'R' iScene(2) '/'];
    
    % set input data location
        % main inputs:
        % Landsat ETM images to fuse
        main.input.etm = [main.path 'ETMSYN/P' iScene(1) 'R' iScene(2) '/'];
        % MODIS Surface Reflectance data (swath data)
        main.input.swath = [main.path iPlat '09/'];

        % for 250m resolution fusion process only:
        % gridded 250m resolution band 1 and 2 surface reflectance data
        main.input.g250m = [main.path iPlat '09GQ/'];

        % for BRDF correction process only:
        % daily gridded MODIS suface reflectance data
        main.input.grid = [main.path iPlat '09GA/'];
        % BRDF/Albedo model parameters product
        main.input.brdf = [main.path 'MCD43A1/'];

        % for gridding process only:
        % MODIS geolocation data
        main.input.geo = [main.path iPlat '03/'];
        
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
        main.output.fusion = [main.outpath 'ETMFUS/'];
        if exist(main.output.fusion,'dir') == 0 
            mkdir([main.outpath 'ETMFUS']);
        end
        % difference between synthetic MODIS and true MODIS
        main.output.dif = [main.outpath 'ETMDIF/'];
        if exist(main.output.dif,'dir') == 0 
            mkdir([main.outpath 'ETMDIF']);
        end
        % changes detected
        % main.output.change = [main.path 'FUSCHG/'];
        % if exist(main.output.change,'dir') == 0 
        %     mkdir([main.path 'FUSCHG']);
        % end
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
        
        % from BRDF correction
        % BRDF parameters at Landsat scale
        main.output.etmBRDF = [main.path 'BRDFETM/'];
        if exist(main.output.etmBRDF,'dir') == 0 
            mkdir([main.path 'BRDFETM']);
        end
        % BRDF coefficients grabbed from the BRDF product
        main.output.modBRDF = [main.path 'BRDF/'];
        if exist(main.output.modBRDF,'dir') == 0 
            mkdir([main.path 'BRDF']);
        end
        % BRDF corrected and fused MOD09SUB
        main.output.modsubbrdf = [main.outpath 'BRDFSUB/'];
        if exist(main.output.modsubbrdf,'dir') == 0 
            mkdir([main.outpath 'BRDFSUB']);
        end
        % fused synthetic MODISimage with BRDF correction
        main.output.fusionbrdf = [main.outpath 'BRDFFUS/'];
        if exist(main.output.fusionbrdf,'dir') == 0 
            mkdir([main.outpath 'BRDFFUS']);
        end
    
        % from change detection
        % cache of fusion time series
        main.output.cache = [main.outpath 'CACHE/'];
        if exist(main.output.cache,'dir') == 0 
            mkdir([main.outpath 'CACHE']);
        end
        % change detection model results in matlab format
        main.output.chgmat = [main.outpath 'CHG/'];
        if exist(main.output.chgmat,'dir') == 0 
            mkdir([main.outpath 'CHG']);
        end
        
        % from gridding process
        % gridded fusion result
        % main.output.fusGrid = [main.path 'FUSGRID/'];
        % if exist(main.output.fusGrid,'dir') == 0 
        %     mkdir([main.path 'FUSGRID']);
        % end
        % gridding parameters
        % main.output.gridPara = [main.path 'GRIDPARA/'];
        % if exist(main.output.gridPara,'dir') == 0 
        %     mkdir([main.path 'GRIDPARA']);
        % end
          
    % settings and parameters
        % platform of MODIS
        main.set.plat = iPlat;
        % apply BRDF correction or not
        main.set.brdf = iBRDF;
        % discard ratio of Landsat image (% image discarded on the edge)
        main.set.dis = iDis;
        % correct for bias in difference map
        main.set.bias = 1;
        % max (0) or mean (1) in calculating difference map
        main.set.dif = 0;
        % job information
        main.set.job = iSub;
        % Landsat scene
        main.set.scene = iScene;
        
    % settings and parameters for the change detection model
        % minimun number of valid observation
        main.model.minNoB = 10;
        % number of observations to initialize the model
        main.model.initNoB = 5;
        % coefficiant of std in change detection
        main.model.nSD = 1.5;
        % number of consective observation of detect change
        main.model.nCosc = 5;
        % number of suspective observation to confirm the change
        main.model.nSusp = 3;
        % number of outlier to remove in initialization
        main.model.outlr = 1;
        % threshold of mean to detect non-forest pixel
        main.model.nonfstmean = 10;
        % threshold of std to detect non-forest pixel
        main.model.nonfstdev = 0.3;
        % threshold of detecting edging pixel in stable non-forest pixel
        main.model.nonfstedge = 5;
        % bands used for change detection
        main.model.band = [3,4,5];
        % weight of each band in change detection
        main.model.weight = [1,1,1];
        
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
        if min(iSub>0)
        
            % calculate begining and ending
            total = numel(main.date.swath);
            piece = floor(total/iSub(2));
            start = 1+piece*(iSub(1)-1);
            if iSub(1)<iSub(2)
                stop = start+piece-1;
            else
                stop = total;
            end
            
            % subset dates to be processed
            main.date.swath = main.date.swath(start:stop);
            
        end
    
    % done

end
