% utm2deg.m
% Version 6.1
% Core
%
% Project: New Fusion
% By xjtang
% Created On: Unknown
% Last Update: 9/17/2014
%
% Input Arguments:
%   UTMEast (Vector, Double) - vector of UTM easting in meters.
%   UTMNorth (Vector, Double) - vector of UTM northing in meters.
%   UTMZone (Integer) - Corresponding UTM zone of the inputs (zone only).
% 
% Output Arguments: 
%   Lat (Vector, Double) - vector of latitude in degrees in WGS84 (neg. for West).
%   Lon (Vector, Double) - vector of longitude in degrees in WGS84 (neg. for South).
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%   2.UTMEast, UTMNorth, and UTMZone are required input arguments.
%   3.Hemisphere will be North if not specified.
%
% Version 6.0 - Unknown (by Q. Xin)
%   Function to convert vectors of UTM coordinates into WGS 84 Lat/Lon vectors.
%   Calculate Latitude and Longitude in degrees given UTM Easting, Northing and UTM zones.
%   Some code was extracted from utm2deg.m function by Rafael Palacios
%
% Updates of Version 6.1 - 9/17/2014 
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%   4.Handle negative UTM zone as southern hemisphere (used to be extra input argument in previous version).
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function  [Lat, Lon] = utm2deg(UTMEast, UTMNorth, UTMZone)

    % check the input and output arguments
    error(nargchk(5, 5, nargin+nargout)); 
        
    % datum constants of WGS84
    b = 6356752.314;
    a = 6378137;
    e = 0.081819191;
    e1sq = 0.006739497;
    k0 = 0.9996;

    ei = (1-(1-e*e)^(1/2))/(1+(1-e*e)^(1/2));
    C1 = (3*ei/2-27*ei^3/32);
    C2 = (21*ei^2/16-55*ei^4/32);
    C3 = (151*ei^3/96);
    C4 = (1097*ei^4/512);

    % correct for hemisphere
    if (UTMZone<0)
        Corrected_Northing = (10000000-UTMNorth);
    else
        Corrected_Northing = UTMNorth;
    end

    % easting correction
    East_Prime = (500000-UTMEast);
   
    % calculation
    Arc_Length = (Corrected_Northing / k0);
    Mu = (Arc_Length/(a*(1-e^2/4-3*e^4/64-5*e^6/256)));
    Footprint_Latitude = (Mu+C1*sin(2*Mu)+C2*sin(4*Mu)+C3*sin(6*Mu)+C4*sin(8*Mu));
    CC1 = (e1sq*cos(Footprint_Latitude).^2);
    T1 = tan(Footprint_Latitude).^2;
    N1 = a ./ ( 1-(e*sin(Footprint_Latitude)).^2 ).^ 0.5;
    R1 = a*(1-e^2) ./ (1-(e*sin(Footprint_Latitude)) .^2 ).^(3/2);
    D  = (East_Prime ./ (N1*k0));

    Fact1 = N1 .* tan(Footprint_Latitude) ./R1;
    Fact2 = D.^2/2;
    Fact3 = (5+3*T1+10*CC1-4*CC1.*CC1-9*e1sq).*D.^4/24;
    Fact4 = (61+90*T1+298*CC1+45*T1.*T1-252*e1sq-3*CC1.*CC1).*D.^6/720;

    LoFact1 = D;
    LoFact2 = ((1+2*T1+CC1).*D.^3/6);
    LoFact3 = ((5-2*CC1+28*T1-3*CC1.^2+8*e1sq+24*T1.^2).*D.^5/120);

    Delta_Long = (LoFact1-LoFact2+LoFact3)./cos(Footprint_Latitude);
    Zone_CM = 6*abs(UTMZone)-183;
    Lat = 180*(Footprint_Latitude-Fact1.*(Fact2+Fact3+Fact4))/(4*atan(1));

    % final correction and generate results
    if UTMZone<0
        Lat = -Lat;
    end
    Lon = (Zone_CM-Delta_Long*180/(4*atan(1)));

    % done
    
end


