% change.m
% Version 1.0
% Core
%
% Project: Fusion
% By: Xiaojing Tang
% Created On: 3/31/2015
% Last Update: 6/15/2015
%
% Input Arguments:
%   TS (Matrix) - fusion time series of a pixel.
% 
% Output Arguments: 
%   CHG (Matrix) - time series of change.
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 1.0 - 6/15/2015
%   The script fits a time series model to fusion result of a pixel
%
% Released on Github on 3/31/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function CHG = change(TS)
    
    % costomized settings
    set.minNoB = 10;
    set.initNoB = 5;
    set.nSD = 1.5;
    set.nCosc = 5;
    set.nSusp = 3;
    set.outlr = 1;
    set.nonfstmean = 10;
    set.nonfstdev = 0.3;
    set.nonfstedge = 5;

    % analyse input TS 
    [nband,nob] = size(TS);
    
    % initilize result
    CHG = zeros(2,nob);
    ETS = 1:nob;

    % complie eligible observations
    for i = nob:-1:1
        if max(TS(:,i)==-9999)
            CHG(:,i) = -1;
            ETS(i) = [];
        end
    end
    
    % check total number of eligible observation
    [~,neb] = size(ETS);
    if neb < set.minNoB
        CHG = -1;
        return 
    end
        
    % initilization
    mainVec = TS(:,ETS(1:set.initNoB));
    if set.outlr > 0
        for i = 1:set.outlr
            % remove outliers in the initial observations
            subMean = trimmean(mainVec,(2/set.initNoB*100),'round',2);
            nTS = abs(((1./subMean)'*mainVec)/nband-1);
            [~,TSmaxI] = max(nTS);
            mainVec(:,TSmaxI) = [];
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
    pMean = mean(abs(initMean));
    pSTD = mean(initStd./initMean);
    if pMean > set.nonfstmean && pSTD > set.nonfstdev 
        nonFst = 1;
    end
    
    % start sequnce
    for i = ETS
        
        % calculate metrics
        x = TS(:,i);
        xRes = abs(x-initMean);
        xNorm = xRes./initStd;
        xDev = mean(xNorm);
        
        % check if this is a statble non-forest pixel
        if nonFst == 0 
        
            % check if possible change occured
            if xDev >= set.nSD 
                % increment number of suspects and confessed
                if j > set.nCosc
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
                if nSusp == 0 && j > set.nCosc
                    % safe
                    mainVec = [mainVec,TS(:,i)];  %#ok<*AGROW>
                    initMean = mean(mainVec,2);
                    initStd = std(mainVec,0,2);
                elseif nSusp > set.nCosc
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
            if nCosc == set.nCosc
                if nSusp >= set.nSusp
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
            if mean(abs(x)) > set.nonfstedge
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