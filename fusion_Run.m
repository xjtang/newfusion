% fusion_Run.m
% Version 1.0
% Step 0
% Main Shell
%
% Project: New Fusion
% By xjtang
% Created On: 1/11/2016
% Last Update: 1/12/2016
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
    func2 = str2func(['fusion_',func]);
    func2(main);
    
    % done
    
end