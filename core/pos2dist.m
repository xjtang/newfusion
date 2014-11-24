% pos2dist.m
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
%   Lat1 (Double) - Latitude of the start point in degrees.
%   Lon1 (Double) - Longitude of the start point in degrees.
%   Lat2 (Double) - Latitude of the end point in degrees.
%   Lon2 (Double) - Longitude of the end point in degrees.
%
% Output Arguments: 
%   Distance (Double): distance in meters betwee the two points.
%   Bearing (Double): bearing in degree from the stating point.
%
% Usage: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 6.0 - Unknown
%   Calculate distance between two points on earth's surface given their 
%       latitudes and longitudes.
%
% Updates of Version 6.1 - 9/17/2014 (by Xiaojing Tang)
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------
%
function [Distance, Bearing] = pos2dist(Lat1, Lon1, Lat2, Lon2)

    % check the input arguments
    error(nargchk(4, 4, nargin));

    % Earth's radius in meters
    R = 6371000;

    % % distance by spherical law of cosines
    % Distance = acos( sind(Lat1).*sind(Lat2) + cosd(Lat1).*cosd(Lat2).*cosd(Lon2-Lon1) ) * R;

    % distance by haversine law
    dLat = Lat2-Lat1; 
    dLon = Lon2-Lon1;

    HaversineA = sind(dLat/2) .^2 + sind(dLon/2) .^2 .* cosd(Lat1) .* cosd(Lat2); 
    Distance = R * 2 * atan2(sqrt(HaversineA), sqrt(1-HaversineA));

    % bearing from the starting point
    Bearing = radtodeg(atan2(sind(dLon).*cosd(Lat2), cosd(Lat1).*sind(Lat2)-sind(Lat1).*cosd(Lat2).*cosd(dLon)));

    % done
    
end
    
