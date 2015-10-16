% change.m
% Version 2.6
% Core
%
% Project: New fusion
% By xjtang
% Created On: 3/31/2015
% Last Update: 10/16/2015
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
% Updates of Version 2.6 - 10/16/2015
%   1.Redesigned the change detection process.
%   2.Removed water pixel detecting.
%   3.Added Chi-Square test.
%   4.Read class codes from main input.
%
% Released on Github on 3/31/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function [CHG,COEF] = change(TS,sets,C)

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
                CHG(ETS(i)) = C.ChgEdge;
            else
                % set result to stable
                CHG(ETS(i)) = C.Stable;
                % update main vector
                if i > sets.initNoB
                    mainVec = [mainVec,TS(:,ETS(i))];  %#ok<*AGROW>
                    initMean = mean(mainVec,2);
                    initStd = std(mainVec,0,2);
                end
            end
        end

    end
    
    % split data into pre and post break
    if max(CHG==C.Break) == 1
        % break exist
        preBreak = TS(:,CHG==C.Stable);
        postBreak = TS(:,CHG>=C.Break);
        CHGFlag = 1;
    else
        % no break
        preBreak = TS(:,CHG==C.Stable);
        postBreak = preBreak;
        CHGFlag = 0;
    end
    
    % record coefficients
    COEF(1,:) = [mean(preBreak,2)',(ones(1,nband)./nband)*abs(mean(preBreak,2))];
    COEF(2,:) = [mean(postBreak,2)',(ones(1,nband)./nband)*abs(mean(postBreak,2))];
    COEF(3,:) = [std(preBreak,0,2)',(ones(1,nband)./nband)*abs(std(preBreak,0,2))];
    COEF(4,:) = [std(postBreak,0,2)',(ones(1,nband)./nband)*abs(std(postBreak,0,2))];
    COEF(5,:) = [prctile(preBreak,95,2)',(ones(1,nband)./nband)*abs(prctile(preBreak,95,2))];
    COEF(6,:) = [prctile(postBreak,95,2)',(ones(1,nband)./nband)*abs(prctile(postBreak,95,2))];
    COEF(7,:) = [prctile(preBreak,5,2)',(ones(1,nband)./nband)*abs(prctile(preBreak,5,2))];
    COEF(8,:) = [prctile(postBreak,5,2)',(ones(1,nband)./nband)*abs(prctile(postBreak,5,2))];
    COEF(9,:) = size(preBreak,2);
    COEF(10,:) = size(postBreak,2);
    COEF(11,:) = [mean([preBreak,postBreak],2)',(ones(1,nband)./nband)*abs(mean([preBreak,postBreak],2))];
    COEF(12,:) = [std([preBreak,postBreak],0,2)',(ones(1,nband)./nband)*abs(std([preBreak,postBreak],0,2))];
    
    % chi square testing
    ChiTest = zeros(3,nband);
    for i =1:nband
        ChiTest(1,i) = chi2gof(preBreak(i,:),'Alpha',sets.alpha);
        ChiTest(2,i) = chi2gof(postBreak(i,:),'Alpha',sets.alpha);
        ChiTest(3,i) = chi2gof([preBreak(i,:),postBreak(i,:)],'Alpha',sets.alpha);
    end
    
    % assign class
    if max(ChiTest(1,:)) < 1 && mean(abs(COEF(1,1:nband))) <= sets.nonfstmean
        % pre-break is forest, check if post-break exist
        if CHGFlag == 1
            % check if post is non-forest
            if max(ChiTest(2,:)) < 1 && mean(abs(COEF(2,1:nband))) <= sets.nonfstmean
                % post-break is forest, false break
                CHGFlag = 0;
            end
            % deal with false break
            if CHGFlag == 0
                % remove change flag
                CHG(CHG==C.Break) = C.Outlier;
                CHG(CHG==C.Changed) = C.Outlier;
                CHG(CHG==C.ChgEdge) = C.Stable;
                % check this pixel as a whole again if this is non-forest
                if max(ChiTest(3,:)) < 1 && mean(abs(COEF(11,1:nband))) <= sets.nonfstmean
                    for i = 1:length(ETS)
                        x = TS(:,ETS(i));
                        if mean(abs(x)) >= sets.specedge
                            CHG(ETS(i)) = C.NonForest;
                        else
                            CHG(ETS(i)) = C.NFEdge;
                        end
                    end
                end
            end
        end
    else
        % pre-break is non-forest, this is non-forest pixel
        for i = 1:length(ETS)
            x = TS(:,ETS(i));
            if mean(abs(x)) >= sets.specedge
                CHG(ETS(i)) = C.NonForest;
            else
                CHG(ETS(i)) = C.NFEdge;
            end
        end
    end
    
    % done
    
end
