% change.m
% Version 1.0
% Core
%
% Project: Fusion
% By: Xiaojing Tang
% Created On: 3/31/2015
% Last Update: 6/5/2015
%
% Input Arguments:
%   TS (Matrix) - fusion time series of a pixel.
% 
% Output Arguments: 
%   CHG (Matrix) - time series of change.
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 1.0 - 6/5/2015
%   The script fits a time series model to fusion result of a pixel
%
% Released on Github on 3/31/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function CHG = change(TS)
    
    % analyse input TS 
    [nob,nba] = size(TS);
    nba = nba - 1;

    % filter in-eligible observations
    for i = nob:-1:1
        if max(TS(:,i)==-9999)
            TS(:,i) = [];
        end
    end
    
    % check total number of eligible observation
    [neb,~] = size(TS);
    if neb < 10
        CHG = -1;
        return 
    end
        
    % initilize result
    CHG = zeros(2,neb);
    
    % start sequnce
    for i = 1:neb
        
    
    end

    % finalize result
    
    
    
    % done
    
end