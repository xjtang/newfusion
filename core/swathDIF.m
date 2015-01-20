% swathDIF.m
% Version 1.0
% Core
%
% Project: Fusion
% By: Xiaojing Tang
% Created On: 1/17/2015
% Last Update: 1/19/2015
%
% Input Arguments:
%   MOD (Matrix) - observed swath.
%   FUS (Matrix) - predicted swath.
%   CLD (Matrix) - cloud mask.
%   q (Single) - quantile for defining extreme value, 1 is na.
%   fix (Single) - a fix value for degining extreme value, 0 is na. 
%   cmask (Boolean) - apply mask or not.
%   bias (Boolean) - correct bias or not.
% 
% Output Arguments: 
%   DIF (Matrix, Var) - the difference image.
%
% Usage: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 6.0 - 1/19/2015
%   The script calculate difference image of predicted and observed swath
%
% Released on Github on 1/19/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function [DIF, CHG] = swathDIF(MOD, FUS, CLD, q, fix, cmask, bias)

    % initialize
    % DIF = 0*ones(size(MOD));
    CHG = 0*ones(size(MOD));
    
    % apply cloud mask
    if cmask == 1
        for i=1:size(CLD,1)
            for j=1:size(CLD,2)
                if CLD(i,j)==1
                    MOD(i,j) = nan;
                end
            end
        end
    end
    
    % correct bias
    if bias == 1
        b = nanmean(MOD(:)) - nanmean(FUS(:));
        MOD = MOD - b;
    end
    
    % calculate difference
    DIF = MOD - FUS;
    
    % calculate change image
        % calculate absolute difference
        ADIF = abs(DIF);
        % using quantile
        if q<1 && q>0
            thres = quantile(ADIF(:),q);
        end
        % using fixed value
        if fix~=0
            thres = fix;
        end
        % update the change map
        for i=1:size(CHG,1)
            for j=1:size(CHG,2)
                if ADIF(i,j)>thres
                    CHG(i,j) = 1;
                end
                if isnan(ADIF(i,j))==1
                    CHG(i,j) = nan;
                end
            end
        end
        
    % done
    
end
