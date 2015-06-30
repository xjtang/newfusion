% gridInterpQA.m
% Version 6.1
% Core
%
% Project: New Fusion
% By xjtang
% Created On: Unknown
% Last Update: 9/18/2014
%
% Input Arguments:
%   MOD09GA (Structure) - Subset of MODIS grided data over the area of the 
%       ETM image and the corresponding geometry information.
% 
% Output Arguments: 
%   MOD09GA (Structure) - Subset of MODIS grided data over the area of the 
%       ETM image and the corresponding geometry information (interpolated).
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 6.0 - Unknown (by Q. Xin)
%   This script gets decoded 500m QA data from 1000m QA data in MOD09GA (gridded data).
%   This interpolation is simply done by resampling.
%   MOD09GA.MODISQA contains the original 1000m QA dataset (uint16) obtained from MOD09GA.
%   MOD09GA.QAWater  contains a masking image for water by decoding uint16 QA data. (0 is land and  1 is water)
%   MOD09GA.QACloud  contains a masking image for cloud by decoding uint16 QA data. (0 is non-cloud and  1 is cloud)
%   MOD09GA.QACloudB  contains a masking image for buffered clouds by decoding uint16 QA data. (0 is non-cloud and  1 is cloud).
%   Every 7 pixels around clouds defined in QACloud are also considered as clouds in QACloudB.
%
% Updates of Version 6.1 - 9/18/2014 
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function    MOD09GA=gridInterpQA(MOD09GA)

    % check the input arguments
    error(nargchk(1, 1, nargin));

    % initialize
    MOD09GA.QAWater = nan(size(MOD09GA.MODISQA));
    MOD09GA.QACloud = nan(size(MOD09GA.MODISQA));
    MOD09GA.QACloudB = nan(size(MOD09GA.MODISQA));
    % MOD09GA.QAHAsl = nan(size(MOD09GA.MODISQA));
    Water = (bitand(uint16(MOD09GA.MODISQA),uint16(56))~=8);

    % Cloud Flag: Internal 10, Cloud 0-2, Cirrus 8,9
    Cloud = mod(bitshift(MOD09GA.MODISQA, -10),2) | mod(MOD09GA.MODISQA,8) | ...
        mod(bitshift(MOD09GA.MODISQA, -8),4) | mod(bitshift(MOD09GA.MODISQA, -13),2);
    CloudB = 1-imerode(~Cloud,strel('square',13));
    % Cloud = mod(bitshift(MOD09GA.MODISQA(I:I+SwathScan-1,:), -10),2) | mod(MOD09GA.MODISQA(I:I+SwathScan-1,:),8) | ...
    %     mod(bitshift(MOD09GA.MODISQA(I:I+SwathScan-1,:), -8),4);

    % LowAerosol(LowAerosol<1) = NaN;
    
    % assign values
    MOD09GA.QAWater = Water;
    MOD09GA.QACloud = Cloud;
    MOD09GA.QACloudB = CloudB;

    % done
    
end
