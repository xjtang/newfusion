% swathInterpQA.m
% Version 6.2
% Core
%
% Project: New Fusion
% By xjtang
% Created On: Unknown
% Last Update: 4/3/2015
%
% Input Arguments:
%   MOD09SUB (Structure) - Subset of MODIS swath data over the area of the ETM image and the corresponding geometry information.
% 
% Output Arguments: 
%   MOD09SUB (Structure) - Subset of MODIS swath data over the area of the ETM image and the corresponding geometry information (interpolated).
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 6.0 - Unknown (by Q. Xin)
%   This script gets decoded 500m QA data from 1000m QA data in MOD09 (swath data).
%   In the code, SwathScan defined the steps for MODIS scan (20 for 500m and 40 for 250m).
%   MOD09SUB.QAWater is for water mask, MOD09SUB.QACloud for cloud mask, MOD09SUB.QACloudB for buffered cloud mask.
%   MOD09SUB.QALowAsl for aerosol mask, and MOD09SUB.QALowAslB is for buffered aerosol mask.
%
% Updates of Version 6.1 - 9/18/2014 
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%
% Updates of Version 6.2 - 4/3/2015 
%   1.Combined 250 and 500 fusion.
%   2.Removed a unused feature that could cause license problem.
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function MOD09SUB = swathInterpQA(MOD09SUB)

    % check the input arguments
    error(nargchk(1, 1, nargin));

    % initialize
    MOD09SUB.QAWater250 = nan(size(MOD09SUB.MODISQA250));
    MOD09SUB.QACloud250 = nan(size(MOD09SUB.MODISQA250));
    MOD09SUB.QACloudB250 = nan(size(MOD09SUB.MODISQA250));
    MOD09SUB.QALowAsl250 = nan(size(MOD09SUB.MODISQA250));
    MOD09SUB.QALowAslB250 = nan(size(MOD09SUB.MODISQA250));
    SwathScan250 = 1000/250*10;
    MOD09SUB.QAWater500 = nan(size(MOD09SUB.MODISQA500));
    MOD09SUB.QACloud500 = nan(size(MOD09SUB.MODISQA500));
    MOD09SUB.QACloudB500 = nan(size(MOD09SUB.MODISQA500));
    MOD09SUB.QALowAsl500 = nan(size(MOD09SUB.MODISQA500));
    MOD09SUB.QALowAslB500 = nan(size(MOD09SUB.MODISQA500));
    SwathScan500 = 1000/500*10;

    % loop through each swath scan of the MODIS sub swath data 250
    for I = 1:SwathScan250:size(MOD09SUB.MODISQA250,1)
        
        % QA_1km: land, cloud, and Aerosol
        Water250 = (bitand(uint16( MOD09SUB.MODISQA250(I:I+SwathScan250-1,:) ),uint16(56))~=8);

        % Cloud Flag: Internal 10, Cloud 0-2, Cirrus 8,9
        Cloud250 = mod(bitshift(MOD09SUB.MODISQA250(I:I+SwathScan250-1,:), -10),2) | mod(MOD09SUB.MODISQA250(I:I+SwathScan250-1,:),8) | ...
            mod(bitshift(MOD09SUB.MODISQA250(I:I+SwathScan250-1,:), -8),4) | mod(bitshift(MOD09SUB.MODISQA250(I:I+SwathScan250-1,:), -13),2);
        % CloudB250 = 1-imerode(~Cloud250,strel('square',7*SwathScan250/10-1));
        % Cloud = (bitand(uint16(MOD09SUB.MODISQA(I:I+SwathScan-1,:)),uint16(1799))~=0);    
        % CloudB = 1-imerode(~Cloud,strel('square',7));
        % Cloud = mod(bitshift(MOD09SUB.MODISQA(I:I+SwathScan-1,:), -10),2) | mod(MOD09SUB.MODISQA(I:I+SwathScan-1,:),8) | ...
        %     mod(bitshift(MOD09SUB.MODISQA(I:I+SwathScan-1,:), -8),4);
        % NoCloud = mod(bitshift(QA(I:I+9,:), -10)+1,2).*floor(mod(QA(I:I+9,:)+7,8)/7).*...
        %     floor(mod(bitshift(QA(I:I+9,:), -8)+3,4)/3).*mod(bitshift(QA(I:I+9,:), -13)+1,2);
        % NoCloud(NoCloud<1) = NaN;

        % Aerosol Flag: get_MOD09SUB_250m.m
        LowAsl250 = floor(mod(bitshift(MOD09SUB.MODISQA250(I:I+SwathScan250-1,:),-6)+2,4)/3);
        % LowAslB250 = imerode(LowAsl250,strel('square',7*SwathScan250/10-1));

        % assign value
        MOD09SUB.QAWater250(I:I+SwathScan250-1,:) = Water250;
        MOD09SUB.QACloud250(I:I+SwathScan250-1,:) = Cloud250;
        % MOD09SUB.QACloudB250(I:I+SwathScan250-1,:) = CloudB250;
        MOD09SUB.QALowAsl250(I:I+SwathScan250-1,:) = LowAsl250;
        % MOD09SUB.QALowAslB250(I:I+SwathScan250-1,:) = LowAslB250;
        
    end
    
    % loop through each swath scan of the MODIS sub swath data 500
    for I = 1:SwathScan500:size(MOD09SUB.MODISQA500,1)
        
        % QA_1km: land, cloud, and Aerosol
        Water500 = (bitand(uint16( MOD09SUB.MODISQA500(I:I+SwathScan500-1,:) ),uint16(56))~=8);

        % Cloud Flag: Internal 10, Cloud 0-2, Cirrus 8,9
        Cloud500 = mod(bitshift(MOD09SUB.MODISQA500(I:I+SwathScan500-1,:), -10),2) | mod(MOD09SUB.MODISQA500(I:I+SwathScan500-1,:),8) | ...
            mod(bitshift(MOD09SUB.MODISQA500(I:I+SwathScan500-1,:), -8),4) | mod(bitshift(MOD09SUB.MODISQA500(I:I+SwathScan500-1,:), -13),2);
        % CloudB500 = 1-imerode(~Cloud500,strel('square',7*SwathScan500/10-1));

        % Aerosol Flag: get_MOD09SUB_250m.m
        LowAsl500 = floor(mod(bitshift(MOD09SUB.MODISQA500(I:I+SwathScan500-1,:),-6)+2,4)/3);
        % LowAslB500 = imerode(LowAsl500,strel('square',7*SwathScan500/10-1));
        % LowAerosol(LowAerosol<1)=NaN;

        % assign value
        MOD09SUB.QAWater500(I:I+SwathScan500-1,:) = Water500;
        MOD09SUB.QACloud500(I:I+SwathScan500-1,:) = Cloud500;
        % MOD09SUB.QACloudB500(I:I+SwathScan500-1,:) = CloudB500;
        MOD09SUB.QALowAsl500(I:I+SwathScan500-1,:) = LowAsl500;
        % MOD09SUB.QALowAslB500(I:I+SwathScan500-1,:) = LowAslB500;
        
    end

    % done
    
end

