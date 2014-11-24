% swathInterpQA.m
% Version 6.1
% Core
%
% Project: Fusion
% By Qinchuan Xin
% Updated By: Xiaojing Tang
% Created On: Unknown
% Last Update: 9/18/2014
%
% Input Arguments:
%   MOD09SUB (Structure) - Subset of MODIS swath data over the area of the 
%       ETM image and the corresponding geometry information.
% 
% Output Arguments: 
%   MOD09SUB (Structure) - Subset of MODIS swath data over the area of the 
%       ETM image and the corresponding geometry information (interpolated).
%
% Usage: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 6.0 - Unknown
%   This script gets decoded 500m QA data from 1000m QA data in MOD09 
%       (swath data).
%   This interpolation can NOT done by simple resampling, we need 
%       interpolate QA data for each scan.
%   In the code, SwathScan defined the steps for MODIS scan (20 for 500 m
%       and 40 for 250 m).
%   MOD09SUB.QAWater is for water mask, MOD09SUB.QACloud for cloud mask, 
%       MOD09SUB.QACloudB for buffered cloud mask.
%   MOD09SUB.QALowAsl for aerosol mask, and MOD09SUB.QALowAslB is for 
%       buffered aerosol mask.
%
% Updates of Version 6.1 - 9/18/2014 (by Xiaojing Tang)
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function MOD09SUB = swathInterpQA(MOD09SUB)

    % check the input arguments
    error(nargchk(1, 1, nargin));

    % initialize
    MOD09SUB.QAWater = nan(size(MOD09SUB.MODISQA));
    MOD09SUB.QACloud = nan(size(MOD09SUB.MODISQA));
    MOD09SUB.QACloudB = nan(size(MOD09SUB.MODISQA));
    MOD09SUB.QALowAsl = nan(size(MOD09SUB.MODISQA));
    MOD09SUB.QALowAslB = nan(size(MOD09SUB.MODISQA));
    SwathScan = 1000/MOD09SUB.Resolution*10;

    % loop through each swath scan of the MODIS sub swath data 
    for I = 1:SwathScan:size(MOD09SUB.MODISQA,1)
        
        % QA_1km: land, cloud, and Aerosol
        Water = (bitand(uint16( MOD09SUB.MODISQA(I:I+SwathScan-1,:) ),uint16(56))~=8);

        % Cloud Flag: Internal 10, Cloud 0-2, Cirrus 8,9
        Cloud = mod(bitshift(MOD09SUB.MODISQA(I:I+SwathScan-1,:), -10),2) | mod(MOD09SUB.MODISQA(I:I+SwathScan-1,:),8) | ...
            mod(bitshift(MOD09SUB.MODISQA(I:I+SwathScan-1,:), -8),4) | mod(bitshift(MOD09SUB.MODISQA(I:I+SwathScan-1,:), -13),2);
        CloudB=1-imerode(~Cloud,strel('square',7*SwathScan/10-1));
        % Cloud = (bitand(uint16(MOD09SUB.MODISQA(I:I+SwathScan-1,:)),uint16(1799))~=0);    
        % CloudB = 1-imerode(~Cloud,strel('square',7));
        % Cloud = mod(bitshift(MOD09SUB.MODISQA(I:I+SwathScan-1,:), -10),2) | mod(MOD09SUB.MODISQA(I:I+SwathScan-1,:),8) | ...
        %     mod(bitshift(MOD09SUB.MODISQA(I:I+SwathScan-1,:), -8),4);
        % NoCloud = mod(bitshift(QA(I:I+9,:), -10)+1,2).*floor(mod(QA(I:I+9,:)+7,8)/7).*...
        %     floor(mod(bitshift(QA(I:I+9,:), -8)+3,4)/3).*mod(bitshift(QA(I:I+9,:), -13)+1,2);
        % NoCloud(NoCloud<1) = NaN;

        % Aerosol Flag: get_MOD09SUB_250m.m
        LowAsl = floor(mod(bitshift(MOD09SUB.MODISQA(I:I+SwathScan-1,:),-6)+2,4)/3);
        LowAslB = imerode(LowAsl,strel('square',7*SwathScan/10-1));
        % LowAerosol(LowAerosol<1)=NaN;

        % assign value
        MOD09SUB.QAWater(I:I+SwathScan-1,:) = Water;
        MOD09SUB.QACloud(I:I+SwathScan-1,:) = Cloud;
        MOD09SUB.QACloudB(I:I+SwathScan-1,:) = CloudB;
        MOD09SUB.QALowAsl(I:I+SwathScan-1,:) = LowAsl;
        MOD09SUB.QALowAslB(I:I+SwathScan-1,:) = LowAslB;
        
    end

    % done
    
end

