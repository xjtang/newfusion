% lm.m
% Version 1.0
% Core
%
% Project: New fusion
% By xjtang
% Created On: 1/13/2016
% Last Update: 1/13/2016
%
% Input Arguments:
%   X (Vector) - Variable.
%   Y (Vector) - Predictor.
% 
% Output Arguments: 
%   LModel (Structure) - the linear model.
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 1.0 - 1/13/2016
%   The script fits a simple linear model.
%   The script is kept as simple as possible to ensure efficiency.
%   No test is included, make sure the arguments are correct.
%
% Released on Github on 1/13/2016, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function LModel = lm(X,Y)

    % add intercept term
    X2 = [ones(length(X),1) X];
    
    % calculate coeficients
    b = X2\Y;
    
    % calculate R2
    Yhat = X2*b;
    SSE = sum((Y-Yhat).^2);
    TSS = sum((Y-mean(Y)).^2);
    R2 = 1-SSE/TSS;

    % calculate RMSE
    n = length(X);
    RMSE = sqrt(SSE/(n-2));
    
    % assign results
    LModel.a = b(2);
    LModel.b = b(1);
    LModel.R2 = R2;
    LModel.RMSE = RMSE;
    
    % done
    
end

