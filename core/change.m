% change.m
% Version 2.6
% Core
%
% Project: New fusion
% By xjtang
% Created On: 3/31/2015
% Last Update: 10/12/2015
%
% Input Arguments:
%   TS (Matrix) - fusion time series of a pixel.
% 
% Output Arguments: 
%   CHG (Vector) - time series of change.
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 1.0 - 6/15/2015
%   The script fits a time series model to fusion result of a pixel.
%
% Updates of Version 1.1 - 6/17/2015
%   1.Added classification scheme into comments.
%   2.Optimazed the model for real data.
%   3.Added weighting system.
%
% Updates of Version 1.1.1 - 7/6/2015
%   1.Bugs fixed.
%   2.Tested.
%   3.Fixed a dimension bug.
%
% Updates of Version 2.0 - 7/12/2015
%   1.Completely redesigned the algorithm.
%   2.Fixed a major bug.
%
% Updates of Version 2.1 - 7/15/2015
%   1.Adjusted non-forest detection.
%   2.Added post change detection filtering.
%   3.Bug fixed.
%
% Updates of Version 2.1.1 - 7/16/2015
%   1.Added a spectral threshold for edge detecting.
%
% Updates of Version 2.2 - 7/18/2015
%   1.Added another mechanism to check if a false break pixel is non-forest.
%   2.Removed a unused variable.
%
% Updates of Version 2.3 - 7/28/2015
%   1.Optimize the outlier removing process in initialization.
%   2.Added a machanism to check whether post-break is non-forest.
%   3.Added a outlier removing process for post-break check.
%   4.Bug fix.
%
% Updates of Version 2.3.1 - 7/30/2015
%   1.Make sure the pixel is checked as whole after removal of false break.
%   2.Added outlier removing for post-break vector.
%   3.Bug fix.
%
% Updates of Version 2.3.2 - 8/6/2015
%   1.Use relative mean to prebreak when checking the post-break vector.
%
% Updates of Version 2.3.3 - 8/18/2015
%   1.Fixed a minor bug that leaves out the last observation.
%   2.Fixeda bug that miss counts number of eligible observation.
%
% Updates of Version 2.4 - 8/30/2015
%   1.Changed the function of minNoB to control the earliest detectable break.
%
% Updates of Version 2.5 - 9/25/2015
%   1.Added a mechanism for detecting water body.
%   2.Fixed a bug.
%   3.Returns model coefficients.
%
% Updates of Version 2.6 - 10/12/2015
%   1.Redesigned the change detection process.
%
% Released on Github on 3/31/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

% Classification Scheme
%  -1 - Ineligible Observation
%   0 - Default Value
%   1 - Stable Forest
%   2 - Outlier (Cloud, Shadow ...)
%   3 - Break
%   4 - Changed
%   5 - Edge of change
%   6 - Stable Non-forest
%   7 - Edge of Non-forest
%   8 - Water or ribarian area

function [CHG,COEF] = change(TS,sets)
    
    % assign class values
    C.NA = -1;
    C.Default = 0;
    C.Stable = 1;
    C.Outlier = 2;
    C.Break = 3;
    C.Changed = 4;
    C.ChgEdge = 5;
    C.NonForest = 6;
    C.NFEdge = 7;
    C.Water = 8;

    % analyse input TS 
    [nband,nob] = size(TS);
    
    % initilize result
    CHG = ones(1,nob)*C.Default;
    COEF = zeros(12,length(sets.band)+1);
    ETS = 1:nob;

    % complie eligible observations
    for i = nob:-1:1
        if max(TS(:,i)==-9999)
            CHG(i) = C.NA;
            ETS(i) = [];
        end
    end
    
    % check total number of eligible observation
    [~,neb] = size(ETS);
    if neb < sets.initNoB
        CHG = C.NA;
        return 
    end
    
    % calculate weight
    TSStd = (std(TS(:,ETS),0,2))';
    weight = TSStd./(sum(TSStd));
        
    % initilization
    mainVec = TS(:,ETS(1:sets.initNoB));
    if sets.outlr > 0
        for i = 1:sets.outlr
            % remove outliers in the initial observations
            initMean = mean(mainVec,2);
            initStd = std(mainVec,0,2);
            mainVecRes = mainVec-repmat(initMean,1,sets.initNoB+1-i);
            mainVecDev = ((1./(initStd)')*abs(mainVecRes))./nband;
            [~,TSmaxI] = max(mainVecDev);
            mainVec(:,TSmaxI) = [];
        end
    end
    initMean = mean(mainVec,2);
    initStd = std(mainVec,0,2);
    CHGFlag = 0;
    
    % detect break
    for i = 1:length(ETS)
        
        % calculate metrics
        x = TS(:,ETS(i));
        xRes = abs(x-initMean);
        xNorm = xRes./initStd;
        xDev = (ones(1,nband)./nband)*xNorm;
        
        % check if possible change occured
        if xDev >= sets.nSD 
            % check if change already detected
            if CHGFlag == 1
                % set result to changed
                CHG(ETS(i)) = C.Changed;
            else
                % see if this is a break
                if i <= length(ETS)+1-sets.nCosc && i > sets.minNoB
                    nSusp = 1;
                    for k = (i+1):(i+sets.nCosc-1)
                        xk = TS(:,ETS(k));
                        xkRes = abs(xk-initMean);
                        xkNorm = xkRes./initStd;
                        xkDev = (ones(1,nband)./nband)*xkNorm;
                        if xkDev >= sets.nSD
                            nSusp = nSusp + 1;
                        end
                    end
                    if nSusp >= sets.nSusp
                        CHG(ETS(i)) = C.Break;
                        CHGFlag = 1;
                    else
                        CHG(ETS(i)) = C.Outlier;
                    end
                else
                    % this is an outlier
                    CHG(ETS(i)) = C.Outlier;
                end
            end
        else
            % check if change already detected
            if CHGFlag == 1
                % set result to edge of change
                CHG(ETS(i)) = 5;
            else
                % set result to stable
                CHG(ETS(i)) = 1;
                % update main vector
                if i > sets.initNoB
                    mainVec = [mainVec,TS(:,ETS(i))];  %#ok<*AGROW>
                    initMean = mean(mainVec,2);
                    initStd = std(mainVec,0,2);
                end
            end
        end

    end
    
    % grab coefficients
    if max(CHG==C.Break) == 1
        % split data into pre-break and post-break
        preBreak = TS(:,CHG==C.Stable);
        postBreak = TS(:,CHG>=C.Break);
        CHGFlag = 1;
    else
        % no break
        preBreak = TS(:,CHG==1);
        postBreak = preBreak;
        CHGFlag = 0;
    end
    
    % record coefficients
    for i = 1:nband
        % coefficients for each band
        COEF(1,i) = [mean(preBreak,2)',sets.weight*abs(mean(preBreak,2))];
        COEF(2,i) = [std(preBreakClean,0,2)',sets.weight*abs(std(preBreakClean,0,2))];
        COEF(3,i) = [mean(postBreak,2)',sets.weight*abs(mean(postBreak,2))];
        COEF(4,i) = [std(postBreak,0,2)',sets.weight*abs(std(postBreak,0,2))];
        COEF(5,i) = [mean([preBreakClean,postBreak],2)',sets.weight*abs(mean([preBreakClean,postBreak],2))];
        COEF(6,i) = [std([preBreakClean,postBreak],0,2)',sets.weight*abs(std([preBreakClean,postBreak],0,2))];
    end
    % overall coefficients
    COEF(1,nband+1) = [mean(preBreakClean,2)',sets.weight*abs(mean(preBreakClean,2))];
    COEF(2,nband+1) = [std(preBreakClean,0,2)',sets.weight*abs(std(preBreakClean,0,2))];
    COEF(3,nband+1) = [mean(postBreak,2)',sets.weight*abs(mean(postBreak,2))];
    COEF(4,nband+1) = [std(postBreak,0,2)',sets.weight*abs(std(postBreak,0,2))];
    COEF(5,nband+1) = [mean([preBreakClean,postBreak],2)',sets.weight*abs(mean([preBreakClean,postBreak],2))];
    COEF(6,nband+1) = [std([preBreakClean,postBreak],0,2)',sets.weight*abs(std([preBreakClean,postBreak],0,2))];
    
    
    % see if pre-brake is non-forest
    pMean = sets.weight*abs(mean(preBreakClean,2));
    pSTD = sets.weight*abs(std(preBreakClean,0,2));
    if pMean >= sets.nonfstmean || pSTD >= sets.nonfstdev 
        % deal with stable non-forest pixel
        for i = 1:length(ETS)
            x = TS(:,ETS(i));
            if sets.weight*abs(x) >= sets.specedge
                CHG(ETS(i)) = 6;
            else
                CHG(ETS(i)) = 7;
            end
        end
    else
        % pre-break is forest, check if post-break exist
        if CHGFlag == 1
            % compare pre-break and post-break
            if manova1([preBreakClean';postBreak'],[ones(size(preBreakClean,2),1);(ones(size(postBreak,2),1)*2)]) == 0
                % pre and post are the same, false break
                CHGFlag = 0;
            else
                % pre and post different, check if post is non-forest
                % use relative mean to pre-break
                pMean = sets.weight*abs(mean(postBreak,2)-mean(preBreakClean,2));
                pSTD = sets.weight*abs(std(postBreak,0,2));
                if pMean < sets.nonfstmean && pSTD < sets.nonfstdev 
                    % post-break is not non-forest, false break
                    CHGFlag = 0;
                end
            end
            % deal with false break
            if CHGFlag == 0
                % remove change flag
                CHG(CHG==3) = 2;
                CHG(CHG==4) = 2;
                CHG(CHG==5) = 1;
                % check this pixel as a whole again if this is non-forest
                pMean = sets.weight*abs(mean([preBreakClean,postBreak],2));
                pSTD = sets.weight*abs(std([preBreakClean,postBreak],0,2));
                if pMean >= sets.nonfstmean || pSTD >= sets.nonfstdev 
                    for i = 1:length(ETS)
                        x = TS(:,ETS(i));
                        if sets.weight*abs(x) >= sets.specedge
                            CHG(ETS(i)) = 6;
                        else
                            CHG(ETS(i)) = 7;
                        end
                    end
                end
            end
        end
    end
    
    % see if this is a water pixel
    if CHGFlag == 0
        pMean = sets.weight*mean(preBreakClean,2);
    else
        pMean = sets.weight*mean([preBreakClean,postBreak],2);
    end
    if pMean < sets.water
        % deal with water pixel
        for i = 1:length(ETS)
            x = TS(:,ETS(i));
            if sets.weight*abs(x) >= sets.specedge
                CHG(ETS(i)) = 8;
            else
                CHG(ETS(i)) = 7;
            end
        end
    end
    
    % done
    
end
