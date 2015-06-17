% change.m
% Version 1.0
% Core
%
% Project: Fusion
% By: Xiaojing Tang
% Created On: 3/31/2015
% Last Update: 6/11/2015
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
% Version 1.0 - 6/11/2015
%   The script fits a time series model to fusion result of a pixel
%
% Released on Github on 3/31/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function CHG = change(TS)
    
    % costomized settings
    set.minNoB = 10;
    set.initNoB = 5;
    set.nSD = 1.5;
    set.nSusp = 5;
    set.nConf = 3;

    % analyse input TS 
    [~,nob] = size(TS);
    
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
    initMean = mean(mainVec,2);
    initStd = std(mainVec,0,2);
    tempVec = mainVec;
    tempMean = initMean;
    tempStd = initStd;
    nSusp = 0;
    nConf = 0;
    posBreak = -1;
    
    % start sequnce
    for i = ETS((set.initNoB+1):end)
        
        % calculate metrics
        x = TS(:,i);
        xRes = abs(x-initMean);
        xNorm = xRes./initStd;
        xDev = mean(xNorm);
        
        % check if possible change occured
        if xDev >= set.nSD 
            % increment number of suspects and confessed
            nSusp = nSusp + 1;
            nConf = nConf + 1;
            % set result to suspect change 
            CHG(1,i) = 2;
            % store posible break point
            if nSusp == 1
                posBreak = i;
            end
        else
            % set result to stable
            CHG(1,i) = 1;
            % check if suspicious
            if nSusp == 0
                % safe
                mainVec = [mainVec,TS(:,i)];  %#ok<*AGROW>
                initMean = mean(mainVec,2);
                initStd = std(mainVec,0,2);
            elseif nSusp > set.nSusp
                % stable found after confirmed change
                nSusp = nSusp + 1;
            else
                % deal with suspicous stable observation
                nSusp = nSusp + 1;
                tempVec = [tempVec,TS(:,i)];
                tempMean = mean(tempVec,2);
                tempStd = std(tempVec,0,2);
            end
        end
        
        % check if change can be confirmed
        if nSusp == set.nSusp
            if nConf >= set.nConf
                % change confirmed
                CHG(1,posBreak) = 3;
            else
                % alert discarded
                nSusp = 0;
                nConf = 0;
                posBreak = -1;
                mainVec = tempVec;
                initMean = tempMean;
                initStd = tempStd;
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
            else
                CHG(2,i) = CHG(1,i);
            end
        end
    end
    
    % done
    
end