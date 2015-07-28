% check_pixel.m
% Version 1.1
% Tools
%
% Project: New Fusion
% By xjtang
% Created On: 7/22/2015
% Last Update: 7/27/2015
%
% Input Arguments: 
%   file - path to config file
%   row - row number of the pixel
%   col - column number of the pixel
%   
% Output Arguments: 
%   R (Structure) - outputs of each step in change detection.
%
% Instruction: 
%   1.Generate cache files of fusion time series.
%   2.Run this script with correct input arguments.
%
% Version 1.0 - 7/27/2015
%   This script gathers intermediate outputs of change detection on individual pixel.
%
% Updates of Version 1.1 - 7/27/2015
%   1.Added the ploting feature.
%   2.Bug fixed.
%   3.Added a outlier removing process for post-break check.
%
% Created on Github on 7/22/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function R = check_pixel(file,row,col)
    
    % initialize
    R = -1;

    % load config file
    if exist(file,'file')
        run(file);
    else
        disp('config file does not exist, abort.');
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
                    if i < nob+1-nConsecutive
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
                R.manova = manova1([preBreak';postBreak'],[ones(size(preBreak,2),1);(ones(size(postBreak,2),1)*2)]);
                if manova1([preBreak';postBreak'],[ones(size(preBreak,2),1);(ones(size(postBreak,2),1)*2)]) == 0
                    % this is a false break
                    CHG(CHG==3) = 2;
                    CHG(CHG==4) = 2;
                    CHG(CHG==5) = 1;
                    % check this pixel as a whole again if this is non-forest
                    pMean = bandWeight*abs(mean(TS(:,CHG==1),2));
                    pSTD = bandWeight*abs(std(TS(:,CHG==1),0,2));
                    R.allMean = pMean;
                    R.allSTD = pSTD;
                    if pMean >= thresNonFstMean || pSTD >= thresNonFstStd
                        for i = 1:nob
                            x = TS(:,ETS(i));
                            if bandWeight*abs(x) >= thresSpecEdge
                                CHG(i) = 6;
                            else
                                CHG(i) = 7;
                            end
                        end
                    end
                else
                    % make sure post break is non-forest
                    if sets.outlr > 0
                        for i = 1:outlierRemove
                            % remove outliers in post-break
                            pMean = mean(postBreak,2);
                            R.postMean1 = pMean;
                            pMeanDev = bandWeight*abs(postBreak-repmat(pMean,1,size(postBreak,2)+1-i));
                            [~,TSmaxI] = max(pMeanDev);
                            postBreak(:,TSmaxI) = [];
                        end
                    end
                    pMean = bandWeight*abs(mean(postBreak,2));
                    pSTD = bandWeight*abs(std(postBreak,0,2));
                    R.postBreakClean = postBreak;
                    R.postMean2 = pMean;
                    R.postSTD2 = pSTD;
                    if pMean < thresNonFstMean && pSTD < thresNonFstStd 
                        % this is a false break
                        CHG(CHG==3) = 2;
                        CHG(CHG==4) = 2;
                        CHG(CHG==5) = 1;
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
            % probable change
            if (sum(CHG==4)+sum(CHG==5)+1) < thresProbChange
                CLS = 12;
            end 
            % could be change edge
            if sum(CHG==5)/sum(CHG>=3) >= thresChgEdge
                CLS = 11;
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
            set(gca,'XTick',floor(Y(1)):(1/12):(floor(Y(1))+1));
            set(gca,'XTickLabel',{'1','2','3','4','5','6','7','8','9','10','11','12'});
            xlabel('Date');
            ylabel('Fusion');
        end
    
    % done
    
end

