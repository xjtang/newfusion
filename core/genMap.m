% genMap.m
% Version 1.3
% Core
%
% Project: New fusion
% By xjtang
% Created On: 7/7/2015
% Last Update: 1/27/2016
%
% Input Arguments:
%   X (Vector) - change time series
%   D (Date) - time series dates
%   sets (Integer) - model settings
%   C (Structure) - class codes
%   LC (Structure) - land cover class codes
%
% Output Arguments: 
%   LCCLass (Integer) - land cover class
%   CDate (Integer) - date changed
%   DDate (Integer) - date detected
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
% Updates of Version 1.2.4 - 11/11/2015
%   1.Removed the water class.
%   2.Get class codes as input parameters.
%   3.Adjusted the structure of input parameters.
%   4.Adjusted input parameter names.
%   5.Bug fix.
%
% Updates of Version 1.3 - 1/27/2016
%   1.Updated comments and instruction.
%   2.Generates one single structure for outputs.
%   3.Added change detection date as part of the output.
%   4.Bug fix.
%
% Released on Github on 7/7/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function [LCclass,Cdate,Ddate] = genMap(X,D,sets,C,LC)

    % initilize result
    LCclass = LC.NA;
    Cdate = LC.NA;
    Ddate = LC.NA;
    
    % remove invalid observation
    if sum(X~=C.NA) > 0
        D = D(X~=C.NA,:);
        X = X(X~=C.NA);
    else
        return;
    end
        
    % deal with different types
    % stable forest
    if (max(X)==C.Outlier)||(max(X)==C.Stable)
        LCclass = LC.Forest;
        Cdate = LC.Default;
        Ddate = LC.Default;
    end
    % stable non-forest
    if (max(X)==C.NonForest)||(max(X)==C.NFEdge)
        LCclass = LC.NonForest;
        Cdate = LC.Default;
        Ddate = LC.Default;
        % could be non-forest edge
        if sum(X==C.NFEdge)/(sum(X==C.NonForest)+sum(X==C.NFEdge))>=sets.nonFstEdge
            LCclass = LC.NFEdge;
            Cdate = LC.Default;
            Ddate = LC.Default;
        end
    end
    % confirmed changed
    if max(X==C.Break) == 1
        LCclass = LC.Change;
        [~,breakPoint] = max(X==C.Break);
        Cdate = D(breakPoint,1);
        Ddate = D(breakPoint+sets.nCosc-1,1);
        % could be change edge
        if sum(X==C.ChgEdge)/(sum(X==C.Changed)+sum(X==C.ChgEdge)+1)>=sets.chgEdge
            LCclass = LC.CEdge;
        end
        % probable change
        if (sum(X==C.Changed)+sum(X==C.ChgEdge)+1) < sets.probThres
            LCclass = LC.Prob;
        end 
    end

    % done
    
end
