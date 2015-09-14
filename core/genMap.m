% genMap.m
% Version 1.2.3
% Core
%
% Project: New fusion
% By xjtang
% Created On: 7/7/2015
% Last Update: 9/13/2015
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
% Updates of Version 1.1 - 7/8/2015
%   1.Added new type of change map.
%   2.Bugs fixed.
%
% Updates of Version 1.1.1 - 7/13/2015
%   1.Added a new type of change map.
%
% Updates of Version 1.2 - 7/19/2015
%   1.Added a filtering mechanism for pixel that have a very late break.
%   2.Added a new class for probable changed pixel.
%   3.Removed a unnecessary line.
%   4.Added explaination of classes.
%   5.Fixed a bug.
%
% Updates of Version 1.2.1 - 7/22/2015
%   1.Threshold for edge finding percentized.
%   2.Adjusted layout of day of change map.
%   3.Make sure classes don't overlap.
%
% Updates of Version 1.2.2 - 8/18/2015
%   1.Make probabaly change on top of other change.
%
% Updates of Version 1.2.3 - 9/13/2015
%   1.Added a water detecting mechanism.
%
% Released on Github on 7/7/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------
%
% Change Map Types
%   1 - day of change
%   2 - month of change
%   3 - class map
%   4 - change only
%
% Classes
%   -9999 - no data
%   -1 - initial value
%   0 - stable
%   2 - water
%   3 - riparian area
%   5 - stable non-forest
%   6 - stable non-forest edge
%   10 - change
%   11 - change edge
%   12 - probable change

function CLS = genMap(X,D,mapType,edgeThres,probThres)
    
    % initilize result
    CLS = -1;

    % different types of map
    if mapType == 2 
        % month of change map
        CLS = -9998;
        
    elseif mapType == 3
        % class map
        % deal with different types
            % stable forest
            if (max(X)<=2)&&(max(X)>=1)
                CLS = 0;
            end
            % stable non-forest
            if (max(X)>=6)&&(max(X)<=7)
                CLS = 5;
                % could be non-forest edge
                if sum(X==7)/sum(X>=6) >= edgeThres(2)
                    CLS = 6;
                end
            end
            % water pixel
            if max(X) >= 8
                CLS = 2;
                % could be non-forest edge
                if sum(X==7)/sum(X>=8) >= edgeThres(2)
                    CLS = 3;
                end
            end
            % confirmed changed
            if max(X==3) == 1
                CLS = 10;
                % could be change edge
                if sum(X==5)/sum(X>=3) >= edgeThres(1)
                    CLS = 11;
                end
                % probable change
                if (sum(X==4)+sum(X==5)+1) < probThres
                    CLS = 12;
                end 
            end

    elseif mapType == 4
        % change only map
        % confirmed changed
        if max(X==3) == 1
            CLS = 10;
            % could be change edge
            if sum(X==5)/sum(X>=3) >= edgeThres(1)
                CLS = 11;
            end
            % probable change
            if (sum(X==4)+sum(X==5)+1) < probThres
                CLS = 12;
            end   
        else
            CLS = 0;
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
            CLS = 0;
        end
        % confirmed changed
        if (max(X==3) == 1)
            [~,breakPoint] = max(X==3);
            CLS = D(breakPoint,1);
            % could be change edge
            if sum(X==5)/sum(X>=3) >= edgeThres(1)
                CLS = 0;
            end
            % probable change
            if (sum(X==4)+sum(X==5)+1) < probThres
                CLS = 0;
            end 
        end
    end
    
    % done
    
end
