% deg2utm.m
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
%   Lat (Vector, Double) - vector of latitude in degrees in WGS84
%       (neg. for West).
%   Lon (Vector, Double) - vector of longitude in degrees in WGS84
%       (neg. for South).
%   UTMzone (Integer) - UTM zone of the input locatios (neg. for Southern
%       hemisphere).
% 
% Output Arguments: 
%   Easting (Vector, Double) - vector of easting in meters.
%   Northing (Vector, Double) - vector of northing in meters.
%   UTMzone (Integer) - Corresponding UTM zone of the outputs (neg. for
%       Southern hemisphere).
%
% Usage: 
%   1.Call by other scripts with correct input and output arguments.
%   2.Lat and Lon are required input arguments.
%   3.UTMzone will be calculated if missing.
%
% Version 6.0 - Unknown
%   Function to convert vectors of WGS84 Lat/Lon vectors into UTM
%       coordinates.
%   Calculate Easting and Northing for given Latitude, Longitude, and
%       UTM zone.
%   Some code was extracted from utm2deg.m function by Rafael Palacios
%
% Updates of Version 6.1 - 9/17/2014 (by Xiaojing Tang)
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%   4.Handle negative UTMzone as southern hemisphere.
%
%----------------------------------------------------------------
%
function [Easting, Northing, UTMzone] = deg2utm(Lat, Lon, UTMzone)

    % check the input and output arguments
    error(nargchk(5, 6, nargin+nargout));
    if nargin==3 && ~isnumeric(UTMzone)
        error('MATLAB: UTMZone is NotNumber');
    elseif nargin==2 
        UTMzone=fix(Lon/6)+31;
        disp('Default: using Latitude to calculate UTMZone');
    end
    
    % normalize UTM zone
    UTMzone = abs(UTMzone);


    % meridional arc constants	
    A0 = 6367449.146;
    B0 = 16038.42955;
    C0 = 16.83261333;
    D0 = 0.021984404;
    E0 = 0.000312705;

    a = 6378137;
    b = 6356752.314;
    k0 = 0.9996;
    e = 0.081819191;
    e2 = 0.006739497;

    % calculation
    deltalonrad = (Lon-(6*UTMzone-183))*pi/180;
    nu = a./((1-(e*sind(Lat)).^2).^0.5);

    ki = k0*(A0*Lat*pi/180-B0*sind(2*Lat)+C0*sind(4*Lat)-D0*sind(6*Lat)+E0*sind(8*Lat));
    kii = nu.*sind(Lat).*cosd(Lat)/2;
    kiii = ((nu.*sind(Lat).*cosd(Lat).^3)/24).*(5-tand(Lat).^2+9*e2*cosd(Lat).^2+4*e2^2*cosd(Lat).^4).*k0;
    kiv = nu.*cosd(Lat).*k0;
    kv = cosd(Lat).^3.*(nu/6).*(1-tand(Lat).^2+e2*cosd(Lat).^2)*k0;

    % results
    Northing = (ki+kii.*deltalonrad.*deltalonrad+kiii.*deltalonrad.^4);
    Northing(Northing<0) = 10000000+Northing(Northing<0);
    Easting = 500000+(kiv.*deltalonrad+kv.*deltalonrad.^3);
    if Lat<0
        UTMzone = -UTMzone;
    end
        
    % done
    
end
