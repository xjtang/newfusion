% fusion_Inputs.m
% Version 6.1
% Step 0
% Main Inputs and Settings
%
% Project: Fusion
% By Xiaojing Tang
% Created On: 9/16/2013
% Last Update: 10/14/2014
%
% Input Arguments: 
%   iDate (String) - main path to the data.
%   iBRDF (Integer) - 0: BRDF off; 1: BRDF on.
%   iRes (Integer) - resolusion 500/250.
%   iDis (Double) - Percenatble of data discarded at the edge of Landsat
%       image (0.1 as 10%).
%   iSub (Vector, Interger) - process a subset of the data.
%       e.g. [1 50] means divide into 50 parts and process the 1st. 
%       [0 0] means do all in one job.
% 
% Output Arguments: 
%   mainInputs (Structure) - main inputs for the whole fusion process
%
% Usage: 
%   1.Customize the inputs and settings for your fusion project.
%   2.Run this stript first to create a new structure of all inputs
%   3.Use the created inputs as input arguments for other function
%
% Version 6.0 - 10/8/2014 (by Xiaojing Tang)
%   This script newly created for Fusion update 6.1
%   This script serves as a single repository for all inputs and settings
%       for the fusion process
%
% Update of Version 6.1 - 10/14/2014 (by Xiaojing Tang)
%   1.This script now loads the hrf module
%
%----------------------------------------------------------------
%
function main = fusion_Inputs(iData,iBRDF,iRes,iDis,iSub)

    % check input argument
    if ~exist('iSub', 'var')
        iSub = [0,0];
    end
    if ~exist('iDis', 'var')
        iDis = 0.1;
    end
    if ~exist('iRes', 'var')
        iRes = 500;
    end
    if ~exist('iBRDF', 'var')
        iBRDF = 0;
    end
    if ~exist('iData', 'var')
        iData = '/projectnb/landsat/projects/fusion/srb_site/';
    end

    % add the fusion package to system path
    addpath(genpath(fileparts(mfilename('fullpath'))));
    
    % load module
    system('module load hdf/4.2.5');
    system('module load gdal/1.10.0');
    
    % set up project main path
    main.path = iData;
    
    % set input data location
        % main inputs:
        % Landsat ETM images to fuse
        main.input.etm = [main.path 'MOD09ETM/'];
        % MODIS Surface Reflectance data (swath data)
        main.input.swath = [main.path 'MOD09/'];

        % for 250m resolution fusion process only:
        % gridded 250m resolution band 1 and 2 surface reflectance data
        main.input.g250m = [main.path 'MOD09GQ/'];

        % for BRDF correction process only:
        % daily gridded MODIS suface reflectance data
        main.input.grid = [main.path 'MOD09GA/'];
        % BRDF/Albedo model parameters product
        main.input.brdf = [main.path 'MCD43A1/'];

        % for gridding process only:
        % MODIS geolocation data
        main.input.geo = [main.path 'MOD03/'];
        
    % set output data location (create if not exist)
        % main outputs:
        % MODIS sub image that covers the Landsat ETM area
        main.output.modsub = [main.path 'MOD09SUB/'];
        if exist(main.output.modsub,'dir') == 0 
            mkdir([main.path 'MOD09SUB'])
        end
        % fused MOD09SUB
        main.output.modsubf = [main.path 'MOD09SUBF/'];
        if exist(main.output.modsubf,'dir') == 0 
            mkdir([main.path 'MOD09SUBF'])
        end
        % fused synthetic MODIS image from ETM image
        main.output.fusion = [main.path 'FUS09/'];
        if exist(main.output.fusion,'dir') == 0 
            mkdir([main.path 'FUS09'])
        end
        % changes between synthetic MODIS and true MODIS
        main.output.change = [main.path 'FUSCHG/'];
        if exist(main.output.change,'dir') == 0 
            mkdir([main.path 'FUSCHG'])
        end
        
        % from BRDF correction
        % BRDF parameters at Landsat scale
        main.output.etmBRDF = [main.path 'ETMBRDF/'];
        if exist(main.output.change,'dir') == 0 
            mkdir([main.path 'ETMBRDF'])
        end
        % BRDF coefficients grabbed from the BRDF product
        main.output.modBRDF = [main.path 'MOD09B/'];
        if exist(main.output.modBRDF,'dir') == 0 
            mkdir([main.path 'MOD09B'])
        end
        % BRDF corrected and fused MOD09SUB
        main.output.modsubbrdf = [main.path 'MOD09SUBBRDF/'];
        if exist(main.output.modsubbrdf,'dir') == 0 
            mkdir([main.path 'MOD09SUBBRDF'])
        end
        % fused synthetic MODISimage with BRDF correction
        main.output.fusionbrdf = [main.path 'FUS09B/'];
        if exist(main.output.fusionbrdf,'dir') == 0 
            mkdir([main.path 'FUS09B'])
        end
    
        % from gridding process
        % gridded fusion result
        main.output.fusGrid = [main.path 'FUSGRID/'];
        if exist(main.output.fusGrid,'dir') == 0 
            mkdir([main.path 'FUSGRID'])
        end
        % gridding parameters
        main.output.gridPara = [main.path 'GRIDPARA/'];
        if exist(main.output.gridPara,'dir') == 0 
            mkdir([main.path 'GRIDPARA'])
        end
          
    % settings and parameters
        % apply BRDF correction or not
        main.set.brdf = iBRDF;
        % resolution (500 or 250)
        main.set.res = iRes;
        % discard ratio of Landsat image (% image discarded on the edge)
        main.set.dis = iDis;
        
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
        main.etm.subULNorth = main.etm.ulNorth-main.etm.res(2)*main.etm.subLine(1);
        main.etm.subULEast = main.etm.ulEast+main.etm.res(1)*main.etm.subSample(1);
        main.etm.subLRNorth = main.etm.ulNorth-main.etm.res(2)*main.etm.subLine(end);
        main.etm.subLREast = main.etm.ulEast+main.etm.res(1)*main.etm.subSample(end);
        
    % date information
        % dates of MODIS swath images used for this study
        main.date.swath = getDateList(main.input.swath);
        % dates of Landsat synthetic images used for this study
        main.date.etm = getDateList(main.input.etm);
        % dates of the MODIS gridded images used for this study
        main.date.grid = getDateList(main.input.grid);
        % dates of the BRDF data used for this study
        main.date.brdf = getDateList(main.input.brdf);
    
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
