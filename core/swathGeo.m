% swathGeo.m
% Version 6.1
% Core
%
% Project: Fusion
% By Qinchuan Xin
% Updated By: Xiaojing Tang
% Created On: Unknown
% Last Update: 9/17/2014
%
% Input Arguments:
%   Resolution (Integer) - resolution of the MODIS band (250 or 500).
% 
% Output Arguments: 
%   ScanAngle (Vector, Double) - vector of scan angles of entire swath.
%   ViewAngle (Vector, Double) - vector of view angles of entire swath.
%   SizeAlongScan (Vector, Double) - vector of pixel sizes along scan line.
%   SizeAlongTrack (Vector, Double) - vector of pixels size along track.
%
% Usage: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 6.0 - Unknown
%   This script generates array of MODIS swath observation geometry for the
%       whole swath
%
% Updates of Version 6.1 - 9/17/2014 (by Xiaojing Tang)
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function [ScanAngle,ViewAngle,SizeAlongScan,SizeAlongTrack]= swathGeo(Resolution)

    % check the input arguments
    error(nargchk(1, 1, nargin));
    error(nargchk(4, 4, nargout));

    % constants
    ALT = 705000; 
    EARTH = 6371000; 

    % calculation
    FOV = 2*atand(Resolution/ALT/2);

    ScanAngle = [fliplr(0.0000001:FOV:55) 0.0000001:FOV:55];
    ViewAngle = asind(sind(ScanAngle)*(EARTH+ALT)/EARTH);
    SizeAlongScan = (EARTH/Resolution)*pi/180*(asind(sind(ScanAngle+FOV/2)*(EARTH+ALT)./EARTH)-...
        asind(sind(ScanAngle-FOV/2)*(EARTH+ALT)./EARTH)-FOV)*Resolution;
    SizeAlongTrack = (EARTH/ALT)*sind(asind(sind(ScanAngle)*(EARTH+ALT)./EARTH)-(ScanAngle))./sind(ScanAngle)*Resolution;

    % done
    
end
