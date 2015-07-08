% genMap.m
% Version 1.0
% Core
%
% Project: New fusion
% By xjtang
% Created On: 7/7/2015
% Last Update: 7/8/2015
%
% Input Arguments:
%   X (Vector) - change time series
%   D (Date) - time series dates
%   mapType (Integer) - type of change map
%   edgeThres (Integer) - threshold to determine edge pixel 
%
% Output Arguments: 
%   CLS - change class
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 1.0 - 7/7/2015
%   The script translate change time series to a change class.
%   Only date of change map is available in this version.
%
% Version 1.1 - 7/8/2015
%   1.Added new type of change map.
%   2.Bugs fixed.
%
% Released on Github on 7/7/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function CLS = genMap(X,D,mapType,edgeThres)
    
    % initilize result
    CLS = -9999;

    % different types of map
    if mapType == 2 
        % month of change map
        CLS = -9998;
        
    elseif mapType == 3
        % change only map
        % deal with different types
            % stable forest
            if (max(X)<=2)&&(max(X)>=1)
                CLS = 0;
            end
            % stable non-forest
            if max(X) >= 6
                CLS = 5;
            end
            % confirmed changed
            if max(X==3) == 2
                [~,breakPoint] = max(X==3);
                CLS = 10;
            end
            % could be non-forest edge
            if sum(X==5) >= edgeThres(2)
                CLS = 6;
            end
            % could be change edge
            if sum(X==7) >= edgeThres(1)
                CLS = 11;
            end
    else
        % date of change map (default)
        % deal with different types of change
            % stable forest
            if (max(X)<=2)&&(max(X)>=1)
                CLS = 0;
            end
            % stable non-forest
            if max(X) >= 6
                CLS = 1;
            end
            % confirmed changed
            if max(X==3) == 1
                [~,breakPoint] = max(X==3);
                CLS = D(breakPoint,1);
            end
    end
    
    % done
    
end
