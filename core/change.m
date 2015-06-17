% change.m
% Version 1.0
% Core
%
% Project: Fusion
% By: Xiaojing Tang
% Created On: 3/31/2015
% Last Update: 6/10/2015
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
% Version 1.0 - 6/10/2015
%   The script fits a time series model to fusion result of a pixel
%
% Released on Github on 3/31/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function CHG = change(TS)
    
    % costomized settings
    set.minNoB = 10;
    set.initNoB = 5;
    set.nSD = 1.5;
    set.csec = 5;
    set.nSus = 3;

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
    nSusp = 0;
    nCsec = 0;
    
    % start sequnce
    for i = (set.initNoB+1):neb
        
        % calculate metrics
        x = TS(:,i);
        xRes = abs(x-initMean);
        xNorm = xRes./initStd;
        xDev = mean(xNorm);
        
        % check if possible change occured
        if xDev >= set.nSD 
            nSusp = nSusp + 1;
            nCsec = nCsec + 1;
            
        else
            
            
        end
    end

    % finalize result
    
    
    
    % done
    
end