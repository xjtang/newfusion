% change.m
% Version 2.6.2
% Core
%
% Project: New fusion
% By xjtang
% Created On: 3/31/2015
% Last Update: 1/13/2016
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
% Updates of Version 2.6 - 11/16/2015
%   1.Redesigned the change detection process.
%   2.Removed water pixel detecting.
%   3.Added linear regression on fusion time series segment.
%   4.Use RMSE and slope to assign classes.
%   5.Read class codes from main input.
%   6.Added study time period control.
%   7.Changed the function of minNoB back to original.
%   8.Adjusted input parameter names.
%   9.Cleaned up the codes.
%   10.Bugs fixed.
%
% Updates of Version 2.6.1 - 1/1/2016
%   1.Bug fix.
%   2.Added a change detection threshold on RMSE.
%
% Updates of Version 2.6.2 - 1/13/2016
%   1.Enhanced performance and speed.
%   2.Implemented the new linear model feature.
%
% Released on Github on 3/31/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function [CHG,COEF] = change(TS,TSD,model,cons,C,NRT)

    % analyse input TS 
    [nband,nob] = size(TS);
    
    % normalize time series date
    TSD = double(TSD);
    TSD = floor(TSD./1000)+rem(TSD,1000)./cons.diy;
    
    % initilize result
    CHG = ones(1,nob)*C.Default;
    COEF = zeros(7,3,nband+1);
    ETS = 1:nob;

    % complie eligible observations   
    neob = max(TS == cons.outna);
    CHG(neob) = C.NA;
    ETS(neob) = [];
    NRT = NRT - sum(neob(1:NRT));
    
    % check total number of eligible observation
    [~,neb] = size(ETS);
    if neb < model.minNoB
        CHG = C.NA;
        return 
    end
        
    % initilization
    mainVec = TS(:,ETS(1:model.initNoB));
    if model.outlr > 0
        for i = 1:model.outlr
            % remove outliers in the initial observations
            initMean = mean(mainVec,2);
            initStd = std(mainVec,0,2);
            mainVecRes = mainVec-repmat(initMean,1,model.initNoB+1-i);
            mainVecNorm = abs(mainVecRes)./repmat(initStd,1,model.initNoB+1-i);
            mainVecDev = model.weight*mainVecNorm;
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
        xDev = model.weight*xNorm;
        
        % check if possible change occured
        if xDev >= model.nSD 
            % check if change already detected
            if CHGFlag == 1
                % set result to changed
                CHG(ETS(i)) = C.Changed;
            else
                % see if this is a break
                if i <= length(ETS)+1-model.nCosc && i > NRT
                    nSusp = 1;
                    for k = (i+1):(i+model.nCosc-1)
                        xk = TS(:,ETS(k));
                        xkRes = abs(xk-initMean);
                        xkNorm = xkRes./initStd;
                        xkDev = model.weight*xkNorm;
                        if xkDev >= model.nSD
                            nSusp = nSusp + 1;
                        end
                    end
                    if nSusp >= model.nSusp
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
                if i > model.initNoB
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
        preBreakD = TSD(CHG==C.Stable);
        postBreak = TS(:,CHG>=C.Break);
        postBreakD = TSD(CHG>=C.Break);
        prePostComb = [preBreak,postBreak];
        prePostCombD = [preBreakD,postBreakD];
        CHGFlag = 1;
    else
        % no break
        preBreak = TS(:,CHG==C.Stable);
        preBreakD = TSD(CHG==C.Stable);
        CHGFlag = 0;
    end
    
    % linear model
    LMCoef = zeros(4,3,nband);
    for i = 1:nband
        if CHGFlag == 1
            LMFit = lm(preBreakD',preBreak(i,:)');
            LMCoef(:,1,i) = [LMFit.b;LMFit.a;LMFit.R2*100;LMFit.RMSE];
            LMFit = lm(postBreakD',postBreak(i,:)');
            LMCoef(:,2,i) = [LMFit.b;LMFit.a;LMFit.R2*100;LMFit.RMSE];
            LMFit = lm(prePostCombD',prePostComb(i,:)');
            LMCoef(:,3,i) = [LMFit.b;LMFit.a;LMFit.R2*100;LMFit.RMSE];
        else
            LMFit = lm(preBreakD',preBreak(i,:)');
            LMCoef(:,1,i) = [LMFit.b;LMFit.a;LMFit.R2*100;LMFit.RMSE];
            LMCoef(:,2,i) = LMCoef(:,1,i);
            LMCoef(:,3,i) = LMCoef(:,1,i);
        end
    end
    
    % record coefficients
    COEF(1,1,:) = [mean(preBreak,2)',model.weight*abs(mean(preBreak,2))];
    COEF(2,1,:) = [std(preBreak,0,2)',model.weight*abs(std(preBreak,0,2))];
    COEF(3,1,:) = size(preBreak,2);
    if CHGFlag == 1
        COEF(1,2,:) = [mean(postBreak,2)',model.weight*abs(mean(postBreak,2))];
        COEF(1,3,:) = [mean([preBreak,postBreak],2)',model.weight*abs(mean([preBreak,postBreak],2))];
        COEF(2,2,:) = [std(postBreak,0,2)',model.weight*abs(std(postBreak,0,2))];
        COEF(2,3,:) = [std([preBreak,postBreak],0,2)',model.weight*abs(std([preBreak,postBreak],0,2))];
        COEF(3,2,:) = size(postBreak,2);
        COEF(3,3,:) = COEF(3,1,1) + COEF(3,2,1)  ;
    else
        COEF(1,2,:) = COEF(1,1,:);
        COEF(1,3,:) = COEF(1,1,:);
        COEF(2,2,:) = COEF(2,1,:);
        COEF(2,3,:) = COEF(2,1,:);
        COEF(3,2,:) = COEF(3,1,:);
        COEF(3,3,:) = COEF(3,1,:);
    end
    COEF(4,:,1:nband) = LMCoef(1,:,:);
    COEF(5,:,1:nband) = LMCoef(2,:,:);
    COEF(6,:,1:nband) = LMCoef(3,:,:);
    COEF(7,:,1:nband) = LMCoef(4,:,:);
    COEF(4,:,nband+1) = model.weight*squeeze(abs(LMCoef(1,:,:)))';
    COEF(5,:,nband+1) = model.weight*squeeze(abs(LMCoef(2,:,:)))';
    COEF(6,:,nband+1) = model.weight*squeeze(abs(LMCoef(3,:,:)))';
    COEF(7,:,nband+1) = model.weight*squeeze(abs(LMCoef(4,:,:)))';
    
    % assign class
    if (COEF(1,1,nband+1)<=model.nonFstMean)&&(COEF(2,1,nband+1)<=model.nonFstStd)...
            &&(COEF(5,1,nband+1)<=model.nonFstSlp)&&(COEF(6,1,nband+1)<=model.nonFstR2)...
            &&(COEF(7,1,nband+1)<=model.nonFstRMSE)
        % pre-break is forest, check if post-break exist
        if CHGFlag == 1
            % check if post is forest
            if (COEF(1,2,nband+1)<=model.nonFstMean)&&(COEF(2,2,nband+1)<=model.nonFstStd)...
                    &&(COEF(5,2,nband+1)<=model.nonFstSlp)&&(COEF(6,2,nband+1)<=model.nonFstR2)...
                    &&(COEF(7,1,nband+1)<=model.nonFstRMSE)
                % post-break is forest, false break
                CHG(CHG==C.Break) = C.Outlier;
                CHG(CHG==C.Changed) = C.Outlier;
                CHG(CHG==C.ChgEdge) = C.Stable;
                % check this pixel as a whole again if this is non-forest
                if ~((COEF(1,3,nband+1)<=model.nonFstMean)&&(COEF(2,3,nband+1)<=model.nonFstStd)...
                        &&(COEF(5,3,nband+1)<=model.nonFstSlp)&&(COEF(6,3,nband+1)<=model.nonFstR2)...
                        &&(COEF(7,1,nband+1)<=model.nonFstRMSE))
                    for i = 1:length(ETS)
                        x = TS(:,ETS(i));
                        if mean(abs(x)) >= model.specEdge
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
            if mean(abs(x)) >= model.specEdge
                CHG(ETS(i)) = C.NonForest;
            else
                CHG(ETS(i)) = C.NFEdge;
            end
        end
    end
    
    % done
    
end
