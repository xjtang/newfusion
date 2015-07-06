% change.m
% Version 1.1.1
% Core
%
% Project: New fusion
% By xjtang
% Created On: 3/31/2015
% Last Update: 7/6/2015
%
% Input Arguments:
%   TS (Matrix) - fusion time series of a pixel.
%   sets (Structure) - model parameters.
% 
% Output Arguments: 
%   CHG (Matrix) - time series of change.
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
%
% Released on Github on 3/31/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

% Classification Scheme
%
% Intermediate:
%  -1 - Ineligible Observation
%   0 - Default Value
%   1 - Stable Forest
%   2 - Suspected Change
%   3 - Confirmed Change
%   4 - Stable Non-forest
%   5 - Edge of Non-Forest
%
% Final:
%  -1 - Ineligible Observation
%   0 - Default Value
%   1 - Stable Forest
%   2 - Outlier (Cloud, Shadow ...)
%   3 - Break
%   4 - Changed
%   5 - Edge of Change
%   6 - Stable Non-forest
%   7 - Edge of Non-forest

function CHG = change(TS,sets)
    
    % costomized settings
    % sets.minNoB = 10;
    % sets.initNoB = 5;
    % sets.nSD = 1.5;
    % sets.nCosc = 5;
    % sets.nSusp = 3;
    % sets.outlr = 1;
    % sets.nonfstmean = 10;
    % sets.nonfstdev = 0.3;
    % sets.nonfstedge = 5;
    % sets.weight = [1,1,1];
    % sets.band = [3,4,5];

    % analyse input TS 
    [nband,nob] = size(TS);
    
    % initilize result
    CHG = zeros(2,nob);
    ETS = 1:nob;
    sets.weight = sets.weight/sum(sets.weight);

    % complie eligible observations
    for i = nob:-1:1
        if max(TS(:,i)==-9999)
            CHG(:,i) = -1;
            ETS(i) = [];
        end
    end
    
    % check total number of eligible observation
    [~,neb] = size(ETS);
    if neb < sets.minNoB
        CHG = -1;
        return 
    end
        
    % initilization
    mainVec = TS(:,ETS(1:sets.initNoB));
    if sets.outlr > 0
        for i = 1:sets.outlr
            % remove outliers in the initial observations
            subMean = (sets.weight*mainVec)/nband;
            [~,TSmaxI] = max(subMean);
            [~,TSminI] = min(subMean);
            mainVec(:,[TSmaxI,TSminI]) = [];
        end
    end
    initMean = mean(mainVec,2);
    initStd = std(mainVec,0,2);
    tempVec = mainVec;
    tempMean = initMean;
    tempStd = initStd;
    nCosc = 0;
    nSusp = 0;
    posBreak = -1;
    j = 1;
    nonFst = 0;
      
    % check if this is a stable non-forest pixel
    pMean = sets.weight*abs(initMean);
    pSTD = sets.weight*abs(initStd);
    if pMean > sets.nonfstmean && pSTD > sets.nonfstdev 
        nonFst = 1;
    end
    
    % start sequnce
    for i = ETS
        
        % calculate metrics
        x = TS(:,i);
        xRes = abs(x-initMean);
        xNorm = xRes./initStd;
        xDev = sets.weight*xNorm;
        
        % check if this is a statble non-forest pixel
        if nonFst == 0 
        
            % check if possible change occured
            if xDev >= sets.nSD 
                % increment number of suspects and confessed
                if j > sets.nCosc
                    nCosc = nCosc + 1;
                    nSusp = nSusp + 1;
                end
                % set result to suspect change 
                CHG(1,i) = 2;
                % store posible break point
                if nCosc == 1
                    posBreak = i;
                end
            else
                % set result to stable
                CHG(1,i) = 1;
                % check if suspicious
                if nSusp == 0 && j > sets.nCosc
                    % safe
                    mainVec = [mainVec,TS(:,i)];  %#ok<*AGROW>
                    initMean = mean(mainVec,2);
                    initStd = std(mainVec,0,2);
                elseif nSusp > sets.nCosc
                    % stable found after confirmed change
                    nCosc = nCosc + 1;
                else
                    % deal with suspicous stable observation
                    nCosc = nCosc + 1;
                    tempVec = [tempVec,TS(:,i)];
                    tempMean = mean(tempVec,2);
                    tempStd = std(tempVec,0,2);
                end

                j = j + 1;
            end

            % check if change can be confirmed
            if nCosc == sets.nCosc
                if nSusp >= sets.nSusp
                    % change confirmed
                    CHG(1,posBreak) = 3;
                else
                    % alert discarded
                    nCosc = 0;
                    nSusp = 0;
                    posBreak = -1;
                    mainVec = tempVec;
                    initMean = tempMean;
                    initStd = tempStd;
                end
            end
        
        else
            % deal with stable non-forest pixel
            if sets.weight*abs(x) > sets.nonfstedge
                CHG(1,i) = 4;
            else
                CHG(1,i) = 5;
            end
        end
    end

    % finalize result    
    CHGFlag = 0;
    for i = 1:nob
        if CHGFlag == 0
            CHG(2,i) = CHG(1,i);
            if CHG(1,i) == 3
                CHGFlag = 1;
            end
        else
            if CHG(1,i) == 1
                CHG(2,i) = 5;
            elseif CHG(1,i) == 2
                CHG(2,i) = 4;
            elseif CHG(1,i) == 4
                CHG(2,i) = 6;
            elseif CHG(1,i) == 5
                CHG(2,i) = 7;
            else
                CHG(2,i) = CHG(1,i);
            end
        end
    end
    
    % done
    
end
