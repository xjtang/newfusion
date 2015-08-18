% tune_model.m
% Version 1.0.2
% Tools
%
% Project: New Fusion
% By xjtang
% Created On: 7/29/2015
% Last Update: 8/18/2015
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
% Updates of Version 1.0.1 - 8/18/2015
%   1.Adjusted according to changes in the model.
%
% Created on Github on 7/29/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function [R,Model] = tune_model(var1,var2,var3)

    % initialize
    R = -1;
    Model = -1;

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
        Model.nonfstmean = thresNonFstMean;
        Model.nonfstdev = thresNonFstStd;
        Model.chgedge = thresChgEdge;
        Model.nonfstedge = thresNonFstEdge;
        Model.specedge = thresSpecEdge;
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
        Model.config = file;
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
        thresNonFstMean = Model.nonfstmean;
        thresNonFstStd = Model.nonfstdev;
        thresChgEdge = Model.chgedge;
        thresNonFstEdge = Model.nonfstedge;
        thresSpecEdge = Model.specedge;
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
        file = Model.config;
    else
        disp('invald number of input arguments,abort.');
        return;
    end
    
    % record model parameters
    R.model.minNoB = minNoB;
    R.model.initNoB = initNoB;
    R.model.nSD = nStandDev;
    R.model.nCosc = nConsecutive;
    R.model.nSusp = nSuspect;
    R.model.outlr = outlierRemove;
    R.model.nonfstmean = thresNonFstMean;
    R.model.nonfstdev = thresNonFstStd;
    R.model.chgedge = thresChgEdge;
    R.model.nonfstedge = thresNonFstEdge;
    R.model.specedge = thresSpecEdge;
    R.model.probThres = thresProbChange;
    R.model.band = bandIncluded;
    R.model.weight = bandWeight;
    R.sets.path = dataPath;
    R.sets.scene = landsatScene;
    R.sets.platform = modisPlatform;
    R.sets.BRDF = BRDF;
    R.sets.BIAS = BIAS;
    R.sets.discardRatio = discardRatio;
    R.sets.diffMethod = diffMethod;
    R.sets.config = file;
    
    % check cache files location
    cachePath = [dataPath 'P' num2str(landsatScene(1),'%03d') 'R' num2str(landsatScene(2),'%03d') '/CACHE/'];
    if exist(cachePath,'dir') == 0 
        disp('cache folder does not exist, abort.');
        return;
    end
    
    % find the cache file for this row
    cacheFile = [cachePath 'ts.r' num2str(row) '.cache.mat'];
    if exist(cacheFile,'file') == 0
        disp('cache file does not exist, sbort.');
        return;
    end
    
    % load thetime series of the pixel
    raw = load(cacheFile);
    raw.Data = squeeze(raw.Data(col,:,bandIncluded))';
    raw.Date = raw.Date(:,1)'; 
    
    % remove unavailable observation
    TS = raw.Data(:,max(raw.Data>(-9999)));
    [nband,nob] = size(TS);
    % record raw reflectance data
    R.model.nob = nob;
    R.ts = TS;
    R.date = raw.Date(max(raw.Data>(-9999)));
    
    % break detecting
    
        % initialization
        CHG = zeros(1,nob);
        mainVec = TS(:,1:initNoB);
        bandWeight = bandWeight/sum(bandWeight);
        
        % record initial vector
        R.initVec = mainVec;
        if outlierRemove > 0
            for i = 1:outlierRemove
                % remove outliers in the initial observations
                initMean = mean(mainVec,2);
                mainVecDev = bandWeight*abs(mainVec-repmat(initMean,1,initNoB+1-i));
                [~,TSmaxI] = max(mainVecDev);
                mainVec(:,TSmaxI) = [];
            end
        end
        initMean = mean(mainVec,2);
        initStd = std(mainVec,0,2);
        CHGFlag = 0;
        % record initialization results
        R.initVec2 = mainVec;
        R.mean = initMean;
        R.std = initStd;
        
        % detect break
        for i = 1:nob   
            
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
                    CHG(i) = 4;
                else
                    % see if this is a break
                    if i <= nob+1-nConsecutive
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
                            CHG(i) = 3;
                            CHGFlag = 1;
                        else
                            CHG(i) = 2;
                        end
                    else
                        % this is an outlier
                        CHG(i) = 2;
                    end
                end
            else
                % check if change already detected
                if CHGFlag == 1
                    % set result to edge of change
                    CHG(i) = 5;
                else
                    % set result to stable
                    CHG(i) = 1;
                    % update main vector
                    if i > initNoB
                        mainVec = [mainVec,TS(:,i)];  %#ok<*AGROW>
                        initMean = mean(mainVec,2);
                        initStd = std(mainVec,0,2);
                        % record updated main vector
                        R.mainVec = mainVec;
                        R.mean = [R.mean,initMean];
                        R.std = [R.std,initStd];
                    end
                end
            end
        end
        
        % record break detection result
        R.chg1 = CHG;
        
    % post change detection refining
        % split data into pre-break and post-break
        if max(CHG==3) == 1
            % break exist
            preBreakClean = TS(:,CHG==1);
            preBreak = TS(:,(CHG>0)&(CHG<3));
            postBreak = TS(:,CHG>=3);
            CHGFlag = 1;
            R.preBreak = preBreak;
            R.postBreak = postBreak;
            % remove outliers in post-break
            if outlierRemove > 0
                for i = 1:outlierRemove
                    pMean = mean(postBreak,2);
                    R.postMean1 = pMean;
                    pMeanDev = bandWeight*abs(postBreak-repmat(pMean,1,size(postBreak,2)));
                    [~,TSmaxI] = max(pMeanDev);
                    postBreak(:,TSmaxI) = [];
                end
            end
            R.postBreakClean = postBreak;
        else
            % no break
            preBreakClean = TS(:,CHG==1);
            CHGFlag = 0;
        end
        R.preBreakClean = preBreakClean;
    
        % see if pre-brake is non-forest
        pMean = bandWeight*abs(mean(preBreakClean,2));
        pSTD = bandWeight*abs(std(preBreakClean,0,2));
        R.preMean = pMean;
        R.preSTD = pSTD;
        if pMean >= thresNonFstMean || pSTD >= thresNonFstStd 
            % deal with stable non-forest pixel
            for i = 1:nob
                x = TS(:,i);
                if bandWeight*abs(x) >= thresSpecEdge
                    CHG(i) = 6;
                else
                    CHG(i) = 7;
                end
            end
        else
            % pre-break is forest, check if post-break exist
            if CHGFlag == 1
                % compare pre-break and post-break
                R.manova = manova1([preBreakClean';postBreak'],[ones(size(preBreakClean,2),1);(ones(size(postBreak,2),1)*2)]);
                if R.manova == 0
                    % pre and post are the same, false break
                    CHGFlag = 0;
                else
                    % pre and post different, check if post is non-forest
                    pMean = bandWeight*abs(mean(postBreak,2)-mean(preBreakClean,2));
                    pSTD = bandWeight*abs(std(postBreak,0,2));
                    R.postMean2 = pMean;
                    R.postSTD2 = pSTD;
                    if pMean < thresNonFstMean && pSTD < thresNonFstStd 
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
                    pMean = bandWeight*abs(mean([preBreakClean,postBreak],2));
                    pSTD = bandWeight*abs(std([preBreakClean,postBreak],0,2));
                    R.allMean = pMean;
                    R.allSTD = pSTD;
                    if pMean >= thresNonFstMean || pSTD >= thresNonFstStd
                        for i = 1:nob
                            x = TS(:,i);
                            if bandWeight*abs(x) >= thresSpecEdge
                                CHG(i) = 6;
                            else
                                CHG(i) = 7;
                            end
                        end
                    end
                end
            end
        end
        % record second change array
        R.chg2 = CHG;
     
    % assign class
        % initilize result
        CLS = -1;
        % stable forest
        if (max(CHG)<=2)&&(max(CHG)>=1)
            CLS = 0;
        end
        % stable non-forest
        if max(CHG) >= 6
            CLS = 5;
            % could be non-forest edge
            if sum(CHG==7)/sum(CHG>=6) >= thresNonFstEdge
                CLS = 6;
            end
        end
        % confirmed changed
        if max(CHG==3) == 1
            CLS = 10;
            % could be change edge
            if sum(CHG==5)/sum(CHG>=3) >= thresChgEdge
                CLS = 11;
            end
            % probable change
            if (sum(CHG==4)+sum(CHG==5)+1) < thresProbChange
                CLS = 12;
            end 
        end
        % date of change
        if max(CHG==3) == 1
            [~,breakPoint] = max(CHG==3);
            R.chgDate = raw.Date(breakPoint);
        end
        % record result
        R.class = CLS;
        
    % visualize results
        % calculate y axis
        Y = floor(double(R.date)/1000)+mod(double(R.date),1000)/365.25;
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
            title(['Band ' num2str(bandIncluded(i))]);
            xlim([floor(Y(1)),floor(Y(1))+1]);
            ylim([-2000,2000]);
            set(gca,'XTick',floor(Y(1)):(1/12):(floor(Y(1))+1));
            set(gca,'XTickLabel',{'1','2','3','4','5','6','7','8','9','10','11','12'});
            xlabel('Date');
            ylabel('Fusion');
        end
    
    % done
    
end

