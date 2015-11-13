% tune_model.m
% Version 1.1
% Tools
%
% Project: New Fusion
% By xjtang
% Created On: 7/29/2015
% Last Update: 11/13/2015
%
% Input Arguments: 
%   var1 - file - path to config file
%        - model - model structure
%   var2 - row number of the pixel
%   var3 - column number of the pixel
%   
% Output Arguments: 
%   R (Structure) - outputs of each step in change detection.
%
% Instruction: 
%   1.Generate cache files of fusion time series.
%   2.Run this script with one input argument to generate model.
%   3.Run this script with 3 input arguments to check results.
%
% Version 1.0 - 7/30/2015
%   This script is used to test different model parameters on single pixel.
%
% Updates of Version 1.0.1 - 8/6/2015
%   1.Adjusted according to changes in the model.
%
% Updates of Version 1.0.2 - 8/18/2015
%   1.Adjusted according to changes in the model.
%
% Updates of Version 1.0.3 - 8/26/2015
%   1.Adjusted x axis label for multi-year data.
%
% Updates of Version 1.0.4 - 9/9/2015
%   1.Adjusted according to changes in the model.
%   2.Fixed a bug.
%   3.Fixed a bug.
%
% Updates of Version 1.0.5 - 9/17/2015
%   1.Adjusted according to changes in the model.
%
% Updates of Version 1.1 - 11/13/2015
%   1.Adjusted according to a major change in the model.
%   2.Parameterize class codes.
%   3.Added the std lines in the plots.
%   4.Fixed a variable that may cause error.
%   5.Added study time period control.
%   6.Bug fix.
%
% Created on Github on 7/29/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function [R,Model] = tune_model(var1,var2,var3)

    % check input arguments
    if nargin == 1 
        % read config file and generate a model for return
        file = var1;
        % load config file
        if exist(file,'file')
            run(file);
        else
            disp('config file does not exist, abort.');
            return;
        end
        % assign model parameters and return
        Model.minNoB = minNoB;
        Model.initNoB = initNoB;
        Model.nSD = nStandDev;
        Model.nCosc = nConsecutive;
        Model.nSusp = nSuspect;
        Model.outlr = outlierRemove;
        Model.nonFstMean = thresNonFstMean;
        Model.nonFstStd = thresNonFstStd;
        Model.nonFstSlp = thresNonFstSlp;
        Model.nonFstR2 = thresNonFstR2;
        Model.chgEdge = thresChgEdge;
        Model.nonFstEdge = thresNonFstEdge;
        Model.specEdge = thresSpecEdge;
        Model.probThres = thresProbChange;
        Model.band = bandIncluded;
        Model.weight = bandWeight;   
        Model.path = dataPath;
        Model.scene = landsatScene;
        Model.platform = modisPlatform;
        Model.BRDF = BRDF;
        Model.BIAS = BIAS;
        Model.discardRatio = discardRatio;
        Model.diffMethod = diffMethod;
        Model.startDate = startDate;
        Model.endDate = endDate;
        Model.nrtDate = nrtDate;
        Model.config = file;
        R = -1;
        return;
    elseif nargin == 3
        % assign model parameters and continue
        Model = var1;
        row = var2;
        col = var3;
        minNoB = Model.minNoB;
        initNoB = Model.initNoB;
        nStandDev = Model.nSD;
        nConsecutive = Model.nCosc;
        nSuspect = Model.nSusp;
        outlierRemove = Model.outlr;
        thresNonFstMean = Model.nonFstMean;
        thresNonFstStd = Model.nonFstStd;
        thresNonFstSlp = Model.nonFstSlp;
        thresNonFstR2 = Model.nonFstR2;
        thresChgEdge = Model.chgEdge;
        thresNonFstEdge = Model.nonFstEdge;
        thresSpecEdge = Model.specEdge;
        thresProbChange = Model.probThres;
        bandIncluded = Model.band;
        bandWeight = Model.weight;
        dataPath = Model.path;
        landsatScene = Model.scene;
        modisPlatform = Model.platform;
        BRDF = Model.BRDF;
        BIAS = Model.BIAS;
        discardRatio = Model.discardRatio;
        diffMethod = Model.diffMethod;
        startDate = Model.startDate;
        endDate = Model.endDate;
        nrtDate = Model.nrtDate;
        file = Model.config;
    else
        disp('invald number of input arguments,abort.');
        return;
    end
    
    % normalize weight
    bandWeight = bandWeight./(sum(bandWeight));
    Model.weight = bandWeight; 
    
    % record model parameters
    R.Model = Model;
    R.Pixel = [row,col];
    
    % fusion TS segment class code
    C.NA = -1;              % not available
    C.Default = 0;          % default
    C.Stable = 1;           % stable forest
    C.Outlier = 2;          % outlier (e.g. cloud)
    C.Break = 3;            % change break
    C.Changed = 4;          % changed to non-forest
    C.ChgEdge = 5;          % edge of change
    C.NonForest = 6;        % stable non-forest
    C.NFEdge = 7;           % edge of stable non-forest
    R.TSclass = C;          % record class codes
    
    % land cover clas codes
    LC.NA = -9999;          % no data
    LC.Default = -1;        % default
    LC.Forest = 0;          % stable forest
    LC.NonForest = 5;       % stable non-forest
    LC.NFEdge = 6;          % non-forest edge
    LC.Change = 10;         % change
    LC.CEdge = 11;          % edge of change
    LC.Prob = 12;           % unconfirmed change
    R.LCclass = LC;         % record class codes
    
    % check cache files location
    cachePath = [dataPath 'P' num2str(landsatScene(1),'%03d') 'R' num2str(landsatScene(2),'%03d') '/CACHE/'];
    if exist(cachePath,'dir') == 0 
        disp('cache folder does not exist, abort.');
        return;
    end
    
    % find the cache file for this row
    cacheFile = [cachePath 'ts.r' num2str(row) '.cache.mat'];
    if exist(cacheFile,'file') == 0
        disp('cache file does not exist, abort.');
        return;
    end
    
    % load the time series of the pixel
    raw = load(cacheFile);
    raw.Data = squeeze(raw.Data(col,:,bandIncluded))';
    raw.Date = raw.Date(:,1)'; 
    
    % remove unavailable observation
    TS = raw.Data(:,max(raw.Data>(-9999)));
    TSD = double(raw.Date(max(raw.Data>(-9999))));
    [nband,nob] = size(TS);
    % record raw reflectance data
    R.nob = nob;
    R.nbanb = nband;
    R.fullTS = TS;
    R.fullDate = TSD;
    
    % study time period control
    TS = TS(:,TSD>=startDate);
    TSD = TSD(TSD>=startDate);
    TS = TS(:,TSD<=endDate);
    TSD = TSD(TSD<=endDate);
    NRT = sum(TSD<nrtDate);
    [~,neb] = size(TS);
    % record study time period controled time series
    R.TS = TS;
    R.Date = TSD;
    R.neb = neb;
    R.Model.NRT = NRT;
    
    % break detecting   
    
        % check if we have enough observation
        if neb < minNoB
            R.CHG = C.NA;
            return 
        end
        
        % initialization
        CHG = zeros(1,neb);
        COEF = zeros(7,3,nband+1);
        mainVec = TS(:,1:initNoB);
        
        % record initial vector
        R.initVec = mainVec;
        if outlierRemove > 0
            for i = 1:outlierRemove
                % remove outliers in the initial observations
                initMean = mean(mainVec,2);
                initStd = std(mainVec,0,2);
                mainVecRes = mainVec-repmat(initMean,1,initNoB+1-i);
                mainVecNorm = abs(mainVecRes)./repmat(initStd,1,initNoB+1-i);
                mainVecDev = bandWeight*mainVecNorm;
                [~,TSmaxI] = max(mainVecDev);
                mainVec(:,TSmaxI) = [];
            end
        end
        initMean = mean(mainVec,2);
        initStd = std(mainVec,0,2);
        CHGFlag = 0;
        % record initialization results
        R.initVecClean = mainVec;
        R.initMean = initMean;
        R.initStd = initStd;
        R.Mean = initMean;
        R.Std = initStd;
        
        % detect break
        for i = 1:neb   
            
            % calculate metrics
            x = TS(:,i);
            xRes = abs(x-initMean);
            xNorm = xRes./initStd;
            xDev = bandWeight*xNorm;
            
            % record result of this pixel
            if i == 1 
                R.xRes = xRes;
                R.xNorm = xNorm;
                R.xDev = xDev;
            else
                R.xRes = [R.xRes,xRes];
                R.xNorm = [R.xNorm,xNorm];
                R.xDev = [R.xDev,xDev];
            end
            
            % check if possible change occured
            if xDev >= nStandDev 
                % check if change already detected
                if CHGFlag == 1
                    % set result to changed
                    CHG(i) = C.Changed;
                else
                    % see if this is a break
                    if i <= neb+1-nConsecutive && i > NRT
                        nSusp = 1;
                        for k = (i+1):(i+nConsecutive-1)
                            xk = TS(:,k);
                            xkRes = abs(xk-initMean);
                            xkNorm = xkRes./initStd;
                            xkDev = bandWeight*xkNorm;
                            if xkDev >= nStandDev
                                nSusp = nSusp + 1;
                            end
                        end
                        if nSusp >= nSuspect
                            CHG(i) = C.Break;
                            CHGFlag = 1;
                        else
                            CHG(i) = C.Outlier;
                        end
                    else
                        % this is an outlier
                        CHG(i) = C.Outlier;
                    end
                end
            else
                % check if change already detected
                if CHGFlag == 1
                    % set result to edge of change
                    CHG(i) = C.ChgEdge;
                else
                    % set result to stable
                    CHG(i) = C.Stable;
                    % update main vector
                    if i > initNoB
                        mainVec = [mainVec,TS(:,i)];  %#ok<*AGROW>
                        initMean = mean(mainVec,2);
                        initStd = std(mainVec,0,2);
                        % record updated main vector
                        R.mainVec = mainVec;
                        R.Mean = [R.Mean,initMean];
                        R.Std = [R.Std,initStd];
                    end
                end
            end
        end
        
        % record break detection result
        R.CHG1 = CHG;
        
    % fusion time series segment classification
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
            R.preBreak = preBreak;
            R.preBreakD = preBreakD;
            R.postBreak = postBreak;
            R.postBreakD = postBreakD;
            R.prePostComb = prePostComb;
            R.prePostCombD = prePostCombD;
        else
            % no break
            preBreak = TS(:,CHG==C.Stable);
            preBreakD = TSD(CHG==C.Stable);
            CHGFlag = 0;
            R.preBreak = preBreak;
            R.preBreakD = preBreakD;
        end
        
        % linaer model
        LMCoef = zeros(4,3,nband);
        for i = 1:nband
            if CHGFlag == 1
                LMFit = LinearModel.fit(preBreakD',preBreak(i,:)');
                LMCoef(:,1,i) = [LMFit.Coefficients.Estimate;LMFit.Rsquared.Adjusted*100;LMFit.RMSE];
                R.LMFit1 = LMFit;
                LMFit = LinearModel.fit(postBreakD',postBreak(i,:)');
                LMCoef(:,2,i) = [LMFit.Coefficients.Estimate;LMFit.Rsquared.Adjusted*100;LMFit.RMSE];
                R.LMFit2 = LMFit;
                LMFit = LinearModel.fit(prePostCombD',prePostComb(i,:)');
                LMCoef(:,3,i) = [LMFit.Coefficients.Estimate;LMFit.Rsquared.Adjusted*100;LMFit.RMSE];
                R.LMFit3 = LMFit;
            else
                LMFit = LinearModel.fit(preBreakD',preBreak(i,:)');
                LMCoef(:,1,i) = [LMFit.Coefficients.Estimate;LMFit.Rsquared.Adjusted*100;LMFit.RMSE];
                LMCoef(:,2,i) = LMCoef(:,1,i);
                LMCoef(:,3,i) = LMCoef(:,1,i);
                R.LMFit1 = LMFit;
            end
        end
        R.LMCoef = LMCoef;
        
        % record coefficients
        COEF(1,1,:) = [mean(preBreak,2)',bandWeight*abs(mean(preBreak,2))];
        COEF(2,1,:) = [std(preBreak,0,2)',bandWeight*abs(std(preBreak,0,2))];
        COEF(3,1,:) = size(preBreak,2);
        if CHGFlag == 1
            COEF(1,2,:) = [mean(postBreak,2)',bandWeight*abs(mean(postBreak,2))];
            COEF(1,3,:) = [mean([preBreak,postBreak],2)',bandWeight*abs(mean([preBreak,postBreak],2))];
            COEF(2,2,:) = [std(postBreak,0,2)',bandWeight*abs(std(postBreak,0,2))];
            COEF(2,3,:) = [std([preBreak,postBreak],0,2)',bandWeight*abs(std([preBreak,postBreak],0,2))];
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
        COEF(4,:,nband+1) = bandWeight*squeeze(abs(LMCoef(1,:,:)))';
        COEF(5,:,nband+1) = bandWeight*squeeze(abs(LMCoef(2,:,:)))';
        COEF(6,:,nband+1) = bandWeight*squeeze(abs(LMCoef(3,:,:)))';
        COEF(7,:,nband+1) = bandWeight*squeeze(abs(LMCoef(4,:,:)))';
        R.Coef = COEF;
        
        % assign class to each segment in fusion TS
        if (COEF(1,1,nband+1)<=thresNonFstMean)&&(COEF(2,1,nband+1)<=thresNonFstStd)...
                &&(COEF(5,1,nband+1)<=thresNonFstSlp)&&(COEF(6,1,nband+1)<=thresNonFstR2)
            % pre-break is forest, check if post-break exist
            if CHGFlag == 1
                % check if post is non-forest
                if (COEF(1,1,nband+1)<=thresNonFstMean)&&(COEF(2,1,nband+1)<=thresNonFstStd)...
                        &&(COEF(5,1,nband+1)<=thresNonFstSlp)&&(COEF(6,1,nband+1)<=thresNonFstR2)
                    % ppost-break is forest, false break
                    CHGFlag = 0;
                end
                % deal with false break
                if CHGFlag == 0
                    % remove change flag
                    CHG(CHG==C.Break) = C.Outlier;
                    CHG(CHG==C.Changed) = C.Outlier;
                    CHG(CHG==C.ChgEdge) = C.Stable;
                    % check this pixel as a whole again if this is non-forest
                    if (COEF(1,1,nband+1)<=thresNonFstMean)&&(COEF(2,1,nband+1)<=thresNonFstStd)...
                            &&(COEF(5,1,nband+1)<=thresNonFstSlp)&&(COEF(6,1,nband+1)<=thresNonFstR2)
                        for i = 1:neb
                            x = TS(:,i);
                            if mean(abs(x)) >= thresSpecEdge
                                CHG(i) = C.NonForest;
                            else
                                CHG(i) = C.NFEdge;
                            end
                        end
                    end
                end
            end
        else
            % pre-break is non-forest, this is non-forest pixel        
            for i = 1:neb
                x = TS(:,i);
                if mean(abs(x)) >= thresSpecEdge
                    CHG(i) = C.NonForest;
                else
                    CHG(i) = C.NFEdge;
                end
            end
        end
        
        % record second change array
        R.CHG2 = CHG;
     
    % assign class
        % initilize result
        CLS = LC.Default;
        % stable forest
        if (max(CHG)<=C.Outlier)&&(max(CHG)>=C.Stable)
            CLS = LC.Forest;
        end
        % stable non-forest
        if max(CHG) >= C.NonForest
            CLS = LC.NonForest;
            % could be non-forest edge
            if sum(CHG==C.NFEdge)/sum(CHG>=C.NonForest) >= thresNonFstEdge
                CLS = LC.NFEdge;
            end
        end
        % confirmed changed
        if max(CHG==C.Break) == 1
            CLS = LC.Change;
            % could be change edge
            if sum(CHG==C.ChgEdge)/sum(CHG>=C.Break) >= thresChgEdge
                CLS = LC.CEdge;
            end
            % probable change
            if (sum(CHG==C.Changed)+sum(CHG==C.ChgEdge)+1) < thresProbChange
                CLS = LC.Prob;
            end 
        end
        % date of change
        if max(CHG==C.Break) == 1
            [~,breakPoint] = max(CHG==C.Break);
            R.chgDate = R.Date(breakPoint);
        end
        % record result
        R.Class = CLS;
        
    % visualize results
        % calculate y axis
        Y = floor(double(R.Date)/1000)+mod(double(R.Date),1000)/365.25;
        % make plot
        figure();
        for i = 1:nband
            subplot(nband,1,i);
            hold on;
            if max(CHG==1) == 1
                plot(Y(CHG==1),TS(i,CHG==1),'g.','MarkerSize',15);
            end
            if max(CHG==2) == 1
                plot(Y(CHG==2),TS(i,CHG==2),'k.','MarkerSize',15);
            end
            if max(CHG==3) == 1
                plot(Y(CHG==3),TS(i,CHG==3),'r.','MarkerSize',15);
            end
            if max(CHG==4) == 1
                plot(Y(CHG==4),TS(i,CHG==4),'b.','MarkerSize',15);
            end
            if max(CHG==5) == 1
                plot(Y(CHG==5),TS(i,CHG==5),'c.','MarkerSize',15);
            end
            if max(CHG==6) == 1
                plot(Y(CHG==6),TS(i,CHG==6),'b.','MarkerSize',15);
            end
            if max(CHG==7) == 1
                plot(Y(CHG==7),TS(i,CHG==7),'c.','MarkerSize',15);
            end
            if max(CHG==8) == 1
                plot(Y(CHG==7),TS(i,CHG==7),'y.','MarkerSize',15);
            end
            stdline1 = refline(0,COEF(1,i)+nStandDev*COEF(3,i));
            set(stdline1,'Color','r');
            stdline2 = refline(0,COEF(1,i)-nStandDev*COEF(3,i));
            set(stdline2,'Color','r');
            title(['Band ' num2str(bandIncluded(i))]);
            xlim([floor(Y(1)),floor(Y(end))+1]);
            ylim([-2000,2000]);
            set(gca,'XTick',floor(Y(1)):(floor(Y(end))+1));
            xlabel('Date');
            ylabel('Fusion');
        end
    
    % done
    
end

