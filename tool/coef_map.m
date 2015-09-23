% coef_map.m
% Version 1.0
% Tools
%
% Project: New Fusion
% By xjtang
% Created On: 9/17/2015
% Last Update: 9/17/2015
%
% Input Arguments: 
%   file - path to config file
%   
% Output Arguments: NA
%
% Instruction: 
%   1.Finish the change detection process.
%   2.Run this script to generate coefficients maps.
%   
% Created on Github on 9/17/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function coef_map(file)
    
    % check if config file exist
    if exist(file,'file')
        run(file);
    else
        disp('config file does not exist, abort.');
        return;
    end
    
    
    
    % done

end

