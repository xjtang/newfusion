% geoInterpMODIS.m
% Version 6.1
% Core
%
% Project: New Fusion
% By xjtang
% Created On: Unknown
% Last Update: 9/19/2014
%
% Input Arguments:
%   Input (Matrix) - 1km Latitude, Longitude swath data.
%   Resolution (Integer) - resolution interpolating to (250 or 500).
% 
% Output Arguments: 
%   Output (Matrix) - Interpolated results
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 6.0 - Unknown (by Q. Xin)
%   This script interpolates MODIS 1km latitude/longitude to obtain 500m/250m latitude/longitude.
%   The 1 km latitude/longitude in MODIS swath can "NOT" be simply resampled to 500m/250m.
%   One MODIS scan is defined as every 10/20/40 (1000m/500m/250m) pixels along the track direction.
%   Bilinear interpolation is used within each MODIS scan.
%   There is a need to account for 0.5 pixel shift in the scan direction, and 0.75 pixel shift in the track direction.
%   Linear extrapolation is used for the first and last 1/2 (500m/250m, respectively) pixels.
%
% Updates of Version 6.1 - 9/19/2014
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function Output = geoInterpMODIS(Input, Resolution)

    % Check the input arguments
    error(nargchk(2, 2, nargin));
    if ~isnumeric(Resolution)
        error('MATLAB:Resolution is NotNumeric');
    end

    % get total numbers of swath scans
    NScan = size(Input,1) / 10;

    % condition on resolution
    % interpolating to 500m resolution
    if Resolution==500
        
        % initialize output
        Output = nan(size(Input)*2);
        
        % bilinear interpolation within each scan
        for I_Scan = 1:NScan
            [S,L] = meshgrid((1:size(Input,2))-1,(1:10)-1);
            [SI,LI] = meshgrid((1:2*size(Input,2))/2-0.5,(1:2*10)/2-0.75);
            Output((I_Scan-1)*20+1:(I_Scan-1)*20+20,:) = interp2(S,L,Input((I_Scan-1)*10+1:(I_Scan-1)*10+10,:),SI,LI);
        end

        % use linear extrapolation for the first and last 500 meter pixel along track
        Output(1:20:end,:) = 2*Output(2:20:end,:)-Output(3:20:end,:);
        Output(20:20:end,:) = 2*Output(19:20:end,:)-Output(18:20:end,:);

        % use linear extrapolation for the last 500 meter pixel along scan
        Output(:,end) = 2*Output(:,end-1)-Output(:,end-2);

    % interpolating to 250m resolution
    elseif Resolution==250
        
        % initialize output
        Output = nan(size(Input)*4);
        
        % bilinear interpolation within each scan
        for I_Scan = 1:NScan
            [S,L] = meshgrid((1:size(Input,2))-1,(1:10)-1);
            [SI,LI] = meshgrid((1:4*size(Input,2))/4-0.25,(1:4*10)/4-0.625);
            Output((I_Scan-1)*40+1:(I_Scan-1)*40+40,:) = interp2(S,L,Input((I_Scan-1)*10+1:(I_Scan-1)*10+10,:),SI,LI);
        end

        % use linear extrapolation for the first and last two 250 meter 
        %   pixel along track
        Output(2:40:end,:)=2*Output(3:40:end,:)-Output(4:40:end,:);
        Output(1:40:end,:)=2*Output(2:40:end,:)-Output(3:40:end,:);
        Output(39:40:end,:)=2*Output(38:40:end,:)-Output(37:40:end,:);
        Output(40:40:end,:)=2*Output(39:40:end,:)-Output(38:40:end,:);

        % use linear extrapolation for the last 250 meter pixel along scan
        Output(:,end-2:end)=2*Output(:,end-5:end-3)-Output(:,end-8:end-6);

    % error message if resolution is set to anything other than 250 and 500
    else
        error('MATLAB:Resolution must be 500 or 250');
        
    end

    % done
    
end
