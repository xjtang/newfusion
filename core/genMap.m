% genMap.m
% Version 1.2.4
% Core
%
% Project: New fusion
% By xjtang
% Created On: 7/7/2015
% Last Update: 10/29/2015
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
% Updates of Version 1.2.3 - 9/17/2015
%   1.Added a water detecting mechanism.
%
% Updates of Version 1.2.4 - 10/29/2015
%   1.Removed the water class.
%   2.Get class codes as input parameters.
%   3.Adjusted the structure of input parameters.
%   4.Bug fix.
%
% Released on Github on 7/7/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function CLS = genMap(X,D,mapType,sets,C,LC)
    
    % initilize result
    CLS = LC.Default;

    % different types of map
    if mapType == 2 
        % month of change map
        CLS = LC.NA;
        
    elseif mapType == 3
        % class map
        % deal with different types
            % stable forest
            if (max(X)==C.Outlier)||(max(X)==C.Stable)
                CLS = LC.Forest;
            end
            % stable non-forest
            if (max(X)==C.NonForest)||(max(X)==C.NFEdge)
                CLS = LC.NonForest;
                % could be non-forest edge
                if sum(X==C.NFEdge)/(sum(X==C.NonForest)+sum(X==C.NFEdge))>=sets.thresNonFstEdge
                    CLS = LC.NFEdge;
                end
            end
            % confirmed changed
            if max(X==C.Break) == 1
                CLS = LC.Change;
                % could be change edge
                if sum(X==C.ChgEdge)/(sum(X==C.Changed)+sum(X==C.ChgEdge)+1)>=sets.thresChgEdge
                    CLS = LC.CEdge;
                end
                % probable change
                if (sum(X==C.Changed)+sum(X==C.ChgEdge)+1) < sets.thresProbChange
                    CLS = LC.Prob;
                end 
            end

    elseif mapType == 4
        % change only map
        % confirmed changed
        if max(X==C.Break) == 1
            CLS = LC.Change;
            % could be change edge
            if sum(X==C.ChgEdge)/(sum(X==C.Changed)+sum(X==C.ChgEdge)+1)>=sets.thresChgEdge
                CLS = LC.CEdge;
            end
            % probable change
            if (sum(X==C.Changed)+sum(X==C.ChgEdge)+1) < sets.thresProbChange
                CLS = LC.Prob;
            end   
        else
            CLS = LC.NA;
        end
    else
        % date of change map (default)
        % deal with different types of change
        % stable forest
        if (max(X)==C.Stable)||(max(X)==C.Outlier)
            CLS = LC.NA;
        end
        % stable non-forest
        if (max(X)==C.NonForest)||(max(X)==C.NFEdge)
            CLS = LC.NA;
        end
        % confirmed changed
        if max(X==C.Break) == 1
            [~,breakPoint] = max(X==C.Break);
            CLS = D(breakPoint,1);
            % could be change edge
            if sum(X==C.ChgEdge)/(sum(X==C.Changed)+sum(X==C.ChgEdge)+1)>=sets.thresChgEdge
                CLS = LC.NA;
            end
            % probable change
            if (sum(X==C.Changed)+sum(X==C.ChgEdge)+1) < sets.thresProbChange
                CLS = LC.NA;
            end 
        end
    end
    
    % done
    
end
