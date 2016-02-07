% tune_model.m
% Version 1.2.3
% Tools
%
% Project: New Fusion
% By xjtang
% Created On: 7/29/2015
% Last Update: 2/5/2016
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
% Updates of Version 1.1 - 11/19/2015
%   1.Adjusted according to a major change in the model.
%   2.Parameterize class codes.
%   3.Added the std lines in the plots.
%   4.Fixed a variable that may cause error.
%   5.Added study time period control.
%   6.Plot the linear model.
%   7.Bug fix.
%
% Updates of Version 1.1.1 - 1/1/2016
%   1.Added support for combining terra and aqua.
%   2.Bug fix.
%   3.Added a change detection threshold on RMSE.
%
% Updates of Version 1.2 - 1/19/2016
%   1.Added sub function for linear model.
%   2.Added sub function for reading config file in text format.
%   3.Implemented the sub functions in the main function.
%   4.Removed unnecessary codes.
%
% Updates of Version 1.2.1 - 1/26/2016
%   1.Adjusted according to a major change in the model.
%   2.Added nob check for linear model check.
%   3.Used abs slope instead of slope.
%   4.Record detection date in results.
%
% Updates of Version 1.2.2 - 2/2/2016
%   1.Adjusted according to a major change in the model.
%   2.Improve the false break removal process.
%   3.Improve outlier removal process in change detection.
%
% Updates of Version 1.2.3 - 2/5/2016
%   1.Adjusted according to a major change in the model.
%   2.Added false break check. 
%   3.Added new parameters for false break check.
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
            Model = readConfig(file);
        else
            disp('config file does not exist, abort.');
            return;
        end
        % assign model parameters and return
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
        nStandDev = Model.nStandDev;
        nConsecutive = Model.nConsecutive;
        nSuspect = Model.nSuspect;
        outlierRemove = Model.outlierRemove;
        thresNonFstMean = Model.thresNonFstMean;
        thresNonFstStd = Model.thresNonFstStd;
        thresNonFstSlp = Model.thresNonFstSlp;
        thresNonFstR2 = Model.thresNonFstR2;
        thresNonFstRMSE = Model.thresNonFstRMSE;
        thresChgEdge = Model.thresChgEdge;
        thresNonFstEdge = Model.thresNonFstEdge;
        thresSpecEdge = Model.thresSpecEdge;
        thresProbChange = Model.thresProbChange;
        bandIncluded = Model.bandIncluded;
        bandWeight = Model.bandWeight;
        dataPath = Model.dataPath;
        landsatScene = Model.landsatScene;
        modisPlatform = Model.modisPlatform;
        startDate = Model.startDate;
        endDate = Model.endDate;
        nrtDate = Model.nrtDate;
        lmMinNoB = Model.lmMinNoB;
        thresFlsBreak = Model.thresFlsBreak;
    else
        disp('invald number of input arguments,abort.');
        return;
    end
    
    % normalize weight
    bandWeight = bandWeight./(sum(bandWeight));
    Model.bandWeight = bandWeight; 
    
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
    TSP = raw.Plat(max(raw.Data>(-9999)));
    [nband,nob] = size(TS);
    % record raw reflectance data
    R.nob = nob;
    R.nbanb = nband;
    R.fullTS = TS;
    R.fullDate = TSD;
    R.fullPlat= TSP;
    
    % platform control
    if strcmp(modisPlatform,'MOD')
        TSD = TSD(TSP==1,:);
        TS = TS(:,TSP==1);
        TSP = TSP(TSP==1);
    elseif strcmp(modisPlatform,'MYD')
        TSD = TSD(TSP==2,:);
        TS = TS(:,TSP==2);
        TSP = TSP(TSP==2);
    end
    R.platTS = TS;
    R.platDate = TSD;
    R.platPlat= TSP;
    
    % study time period control
    TS = TS(:,TSD>=startDate);
    TSD = TSD(TSD>=startDate);
    TSP = TSP(TSD>=startDate);
    TS = TS(:,TSD<=endDate);
    TSD = TSD(TSD<=endDate);
    TSP = TSP(TSD<=endDate);
    NRT = sum(TSD<nrtDate);
    [~,neb] = size(TS);
    % record study time period controled time series
    R.TS = TS;
    R.Date = TSD;
    R.Plat = TSP;
    R.neb = neb;
    R.Model.NRT = NRT;
    % normalize time series date
    TSD = floor(TSD./1000)+rem(TSD,1000)./356.25;
    
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
        % remove outliers in the initial vector
        if outlierRemove > 0
                initMean = mean(mainVec,2);
                initStd = std(mainVec,0,2);
                mainVecRes = mainVec-repmat(initMean,1,initNoB+1-i);
                mainVecNorm = abs(mainVecRes)./repmat(initStd,1,initNoB+1-i);
                mainVecDev = bandWeight*mainVecNorm;
            for i = 1:outlierRemove
                [~,TSmaxI] = max(mainVecDev);
                mainVec(:,TSmaxI) = -9999;
                mainVecDev(TSmaxI) = -9999;
            end
            mainVec = mainVec(mainVec(1,:)>-9999);
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
            % false break check
            if (sum(CHG==C.ChgEdge)/(sum(CHG>=C.Break)-nSuspect)) >= thresFlsBreak
                postBreak = TS(:,CHG==C.ChgEdge);
                postBreakD = TSD(CHG==C.ChgEdge);
                prePostComb = [preBreak,postBreak];
                prePostCombD = [preBreakD,postBreakD];
                R.postBreak2 = postBreak;
                R.postBreakD2 = postBreakD;
                R.prePostComb2 = prePostComb;
                R.prePostCombD2 = prePostCombD;
            end
        else
            % no break
            preBreak = TS(:,CHG==C.Stable);
            preBreakD = TSD(CHG==C.Stable);
            CHGFlag = 0;
            R.preBreak = preBreak;
            R.preBreakD = preBreakD;
        end
        
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
            COEF(3,3,:) = COEF(3,1,1) + COEF(3,2,1);
        else
            COEF(1,2,:) = COEF(1,1,:);
            COEF(1,3,:) = COEF(1,1,:);
            COEF(2,2,:) = COEF(2,1,:);
            COEF(2,3,:) = COEF(2,1,:);
            COEF(3,2,:) = COEF(3,1,:);
            COEF(3,3,:) = COEF(3,1,:);
        end
        
        % linaer model
        LMCoef = zeros(4,3,nband);
        for i = 1:nband
            if CHGFlag == 1
                if COEF(3,1,3) >= lmMinNoB
                    LMFit = lm(preBreakD',preBreak(i,:)');
                    LMCoef(:,1,i) = [LMFit.b;LMFit.a;LMFit.R2*100;LMFit.RMSE];
                    R.LMFitPre.(['Band' num2str(i)]) = LMFit;
                end
                if COEF(3,2,3) >= lmMinNoB
                    LMFit = lm(postBreakD',postBreak(i,:)');
                    LMCoef(:,2,i) = [LMFit.b;LMFit.a;LMFit.R2*100;LMFit.RMSE];
                    R.LMFitPost.(['Band' num2str(i)]) = LMFit;
                end
                if COEF(3,3,3) >= lmMinNoB
                    LMFit = lm(prePostCombD',prePostComb(i,:)');
                    LMCoef(:,3,i) = [LMFit.b;LMFit.a;LMFit.R2*100;LMFit.RMSE];
                    R.LMFitAll.(['Band' num2str(i)]) = LMFit;
                end
            else
                if COEF(3,1,3) >= lmMinNoB
                    LMFit = lm(preBreakD',preBreak(i,:)');
                    LMCoef(:,1,i) = [LMFit.b;LMFit.a;LMFit.R2*100;LMFit.RMSE];
                    LMCoef(:,2,i) = LMCoef(:,1,i);
                    LMCoef(:,3,i) = LMCoef(:,1,i);
                    R.LMFit.(['Band' num2str(i)]) = LMFit;
                end
            end
        end
        R.LMCoef = LMCoef;
        
        % record linear model coefs
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
                &&(abs(COEF(5,1,nband+1))<=thresNonFstSlp)&&(COEF(6,1,nband+1)<=thresNonFstR2)...
                &&(COEF(7,1,nband+1)<=thresNonFstRMSE)
            % pre-break is forest, check if post-break exist
            if CHGFlag == 1
                % check if post is non-forest
                if (COEF(1,2,nband+1)<=thresNonFstMean)&&(COEF(2,2,nband+1)<=thresNonFstStd)...
                        &&(abs(COEF(5,2,nband+1))<=thresNonFstSlp)&&(COEF(6,2,nband+1)<=thresNonFstR2)...
                        &&(COEF(7,1,nband+1)<=thresNonFstRMSE)
                    % post-break is forest, false break
                    CHG(CHG==C.Break) = C.Outlier;
                    CHG(CHG==C.Changed) = C.Outlier;
                    CHG(CHG==C.ChgEdge) = C.Stable;
                    % check this pixel as a whole again if this is non-forest
                    if ~((COEF(1,3,nband+1)<=thresNonFstMean)&&(COEF(2,3,nband+1)<=thresNonFstStd)...
                            &&(abs(COEF(5,3,nband+1))<=thresNonFstSlp)&&(COEF(6,3,nband+1)<=thresNonFstR2)...
                            &&(COEF(7,1,nband+1)<=thresNonFstRMSE))
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
            R.detDate = R.Date(breakPoint+nConsecutive-1);
        end
        % record result
        R.Class = CLS;
        
    % visualize results
        % calculate x axis
        X = floor(double(R.Date)/1000)+mod(double(R.Date),1000)/365.25;
        % make plot
        figure();
        for i = 1:nband
            % plot each band on the same plot
            subplot(nband,1,i);
            hold on;
            % plot different types of points in different color
            if max(CHG==C.Stable) == 1
                plot(X(CHG==C.Stable),TS(i,CHG==C.Stable),'g.','MarkerSize',15);
            end
            if max(CHG==C.Outlier) == 1
                plot(X(CHG==C.Outlier),TS(i,CHG==C.Outlier),'k.','MarkerSize',15);
            end
            if max(CHG==C.Break) == 1
                plot(X(CHG==C.Break),TS(i,CHG==C.Break),'r.','MarkerSize',15);
            end
            if max(CHG==C.Changed) == 1
                plot(X(CHG==C.Changed),TS(i,CHG==C.Changed),'b.','MarkerSize',15);
            end
            if max(CHG==C.ChgEdge) == 1
                plot(X(CHG==C.ChgEdge),TS(i,CHG==C.ChgEdge),'c.','MarkerSize',15);
            end
            if max(CHG==C.NonForest) == 1
                plot(X(CHG==C.NonForest),TS(i,CHG==C.NonForest),'b.','MarkerSize',15);
            end
            if max(CHG==C.NFEdge) == 1
                plot(X(CHG==C.NFEdge),TS(i,CHG==C.NFEdge),'c.','MarkerSize',15);
            end
            % plot the std lines
            plot([X(1),X(end)],ones(1,2).*(COEF(1,1,i)+nStandDev*COEF(2,1,i)),'Color',[0.5,0.5,0.5]);
            plot([X(1),X(end)],ones(1,2).*(COEF(1,1,i)-nStandDev*COEF(2,1,i)),'Color',[0.5,0.5,0.5]);
            % plot the linear models
            if CHGFlag == 1
                plot([X(1),X(R.CHG1==C.Break)],[X(1),X(R.CHG1==C.Break)]*COEF(5,1,i)+COEF(4,1,i),'Color',[0.75,0.75,0.75]);
                plot([X(R.CHG1==C.Break),X(end)],[X(R.CHG1==C.Break),X(end)]*COEF(5,2,i)+COEF(4,2,i),'Color',[0.75,0.75,0.75]);
            else
                plot([X(1),X(end)],[X(1),X(end)]*COEF(5,1,i)+COEF(4,1,i),'Color',[0.75,0.75,0.75]);
            end
            % adjust captions and axis
            title(['Band ' num2str(bandIncluded(i))]);
            xlim([floor(X(1)),floor(X(end))+1]);
            ylim([-2000,2000]);
            set(gca,'XTick',floor(X(1)):(floor(X(end))+1));
            xlabel('Date');
            ylabel('Fusion');
        end
        hold off;
        
    % done
    
end

% local functions
function LModel = lm(X,Y)
    X2 = [ones(length(X),1) X];
    b = X2\Y;
    Yhat = X2*b;
    SSE = sum((Y-Yhat).^2);
    TSS = sum((Y-mean(Y)).^2);
    R2 = 1-SSE/TSS;
    n = length(X);
    RMSE = sqrt(SSE/(n-2));
    LModel.a = b(2);
    LModel.b = b(1);
    LModel.R2 = R2;
    LModel.RMSE = RMSE;
end

function config = readConfig(file)
    config = [];
    if ~exist(file,'file') 
        disp('Config file does not exist.');
        return;
    end
    Fconfig = fopen(file,'r');
    while ~feof(Fconfig)
        thisLine = strtrim(fgetl(Fconfig));
        if isempty(thisLine)
            continue;
        elseif strcmp(thisLine(1),'%')
            continue;
        end
        [trueLine,~] = strtok(thisLine,'%;');
        [keyName,rem] = strtok(trueLine,'=');
        [keyString,~] = strtok(rem,'=');
        keyName = strtrim(keyName);
        keyString = strtrim(keyString);
        if strcmp(keyString(1),'''')
            keyValue = strrep(keyString,'''','');
        elseif strcmp(keyString(1),'[')
            keyValue = str2num(keyString);
        else
            keyValue = str2double(keyString);
        end
        config.(keyName) = keyValue;
    end
    fclose(Fconfig);
    curVersion = 10200;
    if ~isfield(config,'configVer')
        disp('WARNING!!!!');
        disp('Unknown config file version, unexpected error may occur.');
        disp('WARNING!!!!');
        config.configVer = 0;
    elseif config.configVer < curVersion
        disp('WARNING!!!!');
        disp('You are using older version of config file, unexpected error may occur.');
        disp('WARNING!!!!');
    end
    if ~isfield(config,'dataPath')
        config.dataPath = '/projectnb/landsat/projects/fusion/amz_site/data/modis/';
    end
    if ~isfield(config,'landsatScene')
        config.landsatScene = [227,65];
    end
    if ~isfield(config,'modisPlatform')
        config.modisPlatform = 'ALL';
    end
    if ~isfield(config,'BRDF')
        config.BRDF = 0;
    end
    if ~isfield(config,'BIAS')
        config.BIAS = 1;
    end
    if ~isfield(config,'discardRatio')
        config.discardRatio = 0;
    end
    if ~isfield(config,'diffMethod')
        config.diffMethod = 1;
    end
    if ~isfield(config,'cloudThres')
        config.cloudThres = 80;
    end
    if ~isfield(config,'startDate')
        config.startDate = 2013001;
    end
    if ~isfield(config,'endDate')
        config.endDate = 2015001;
    end
    if ~isfield(config,'nrtDate')
        config.nrtDate = 2014001;
    end
    if ~isfield(config,'minNoB')
        config.minNoB = 40;
    end
    if ~isfield(config,'initNoB')
        config.initNoB = 20;
    end
    if ~isfield(config,'nStandDev')
        config.nStandDev = 3;
    end
    if ~isfield(config,'nConsecutive')
        config.nConsecutive = 6;
    end
    if ~isfield(config,'nSuspect')
        config.nSuspect = 4;
    end
    if ~isfield(config,'outlierRemove')
        config.outlierRemove = 2;
    end
    if ~isfield(config,'thresNonFstMean')
        config.thresNonFstMean = 150;
    end
    if ~isfield(config,'thresNonFstStd')
        config.thresNonFstStd = 250;
    end
    if ~isfield(config,'thresNonFstSlp')
        config.thresNonFstSlp = 200;
    end
    if ~isfield(config,'thresNonFstR2')
        config.thresNonFstR2 = 30;
    end
    if ~isfield(config,'thresNonFstRMSE')
        config.thresNonFstRMSE = 200;
    end
    if ~isfield(config,'thresChgEdge')
        config.thresChgEdge = 0.65;
    end
    if ~isfield(config,'thresNonFstEdge')
        config.thresNonFstEdge = 0.35;
    end
    if ~isfield(config,'thresSpecEdge')
        config.thresSpecEdge = 100;
    end
    if ~isfield(config,'thresProbChange')
        config.thresProbChange = 8;
    end
    if ~isfield(config,'bandIncluded')
        config.bandIncluded = [7,8];
    end
    if ~isfield(config,'bandWeight')
        config.bandWeight = [1,1];
    end
    if ~isfield(config,'lmMinNoB')
        config.lmMinNoB = 20;
    end
    if ~isfield(config,'thresFlsBreak')
        config.lmMinNoB = 0.8;
    end
end


