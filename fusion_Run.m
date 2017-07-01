% fusion_Run.m
% Version 1.0.2
% Step 0
% Main Shell
%
% Project: New Fusion
% By xjtang
% Created On: 1/11/2016
% Last Update: 7/1/2017
%
% Input Arguments: 
%   file (String) - full path and file name to the config file
%   job (Integer) - sequnce of current job
%   njob (Integer) - total number of jobs submitted
%   func (String) - funtion to run
% 
% Output Arguments: 
%   main (Structure) - main inputs for the whole fusion process
%
% Instruction: 
%   1.Customize a config file for your project.
%   2.Run this stript with correct inputs.
%
% Version 1.0 - 1/12/2016
%   This script is the wrap-up function to run fusion.
%
% Updates of Version 1.0.1 - 1/17/2016
%   1.Used a switch instead of str2func, better support compiling.
%   2.Added a exit in the end.
%
% Updates of Version 1.0.2 - 7/1/2017
%   1.Added new function for generating csv.
%
% Released on Github on 1/11/2016, check Github Commits for updates afterwards.
%----------------------------------------------------------------
%
function fusion_Run(file,job,njob,func)
    
    % add the fusion package to system path if it is not deployed
    if ~isdeployed 
        addpath(genpath(fileparts(mfilename('fullpath'))));
    end
    
    % correct input argument type if it is deplyed
    if isdeployed 
        job = str2double(job);
        njob = str2double(njob);
    end
    
    % generate input structure
    main = fusion_Inputs(file,[job,njob]);

    % run specific function
    switch func
        case 'SwathSub'
            fusion_SwathSub(main);
        case 'BRDF'
            fusion_BRDF(main);
        case 'Cloud'
            fusion_Cloud(main);
        case 'Fusion'
            fusion_Fusion(main);
        case 'BRDFusion'
            fusion_BRDFusion(main);
        case 'Dif'
            fusion_Dif(main);
        case 'WriteHDF'
            fusion_WriteHDF(main);
        case 'WriteETM'
            fusion_WriteETM(main);
        case 'Cache'
            fusion_Cache(main);
        case 'Change'
            fusion_Change(main);
        case 'GenMap'
            fusion_GenMap(main);  
        case 'WriteCSV'
            fusion_WriteCSV(main);
        otherwise
            disp('can not recognize the function, please check inputs.')
    end
    
    % done
    exit;
    
end
