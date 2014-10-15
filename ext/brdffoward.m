% brdfforward.m
% Version 1.1
% External
%
% Project: BRDF
% By Feng Gao
% Modified By Qinchuan Xin
% Updated By: Xiaojing Tang
% Created On: Unknown
% Last Update: 9/29/2014
%
% Input Arguments:
%   iso, vol, geo (Double) - BRDF parameters.
%   sza (Double) - solar zenith angle in degrees.
%   vza (Double) - view zenith angle in degrees.
%   relaz (Double) - relative azimuth angle in degrees. 
%
% Output Arguments: 
%   refl (Double) - BRDF corrected reflectance
%
% Usage: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 1.0 - Unknown
%   Function to convert BRDF parameters into reflectance
%   Rewritten from Feng Gao's BRDF forward model.
%
% Updates of Version 1.1 - 9/29/2014 (by Xiaojing Tang)
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%
%----------------------------------------------------------------
%
function refl = brdffoward(iso,vol,geo,sza,vza,relaz)

    % input argument checking
    error(nargchk(6, 6, nargin)); 

    % predefined BRratio, HBratio for LiSparse model
    BR = 1.0;                     % LiSparse b/r
    HB = 2.0;                     % LiSparse h/b

    % convert angles to trigomometric funstions
    costv = cosd(vza);
    sintv = sind(vza);
    tantv = tand(vza);
    costi = cosd(sza);
    sinti = sind(sza);
    tanti = tand(sza);
    cosphi = cosd(relaz);
    sinphi = sind(relaz);

    % Ross Kernel
    cosphaang = costv.*costi+sintv.*sinti.*cosphi;
    phaang = acos(max(-1, min(1,cosphaang)));
    sinphaang = sin(phaang);
    
    rosskernel = ((pi/2 - phaang).*cosphaang + sinphaang)./(costi + costv)-pi/4;

    % Li Kernel
    tantvp = max(0,BR*tantv);
    angp = atan(tantvp);
    sintvp = sin(angp);
    costvp = cos(angp);

    tantip = max(0,BR*tanti);
    angp = atan(tantip);
    sintip = sin(angp);
    costip = cos(angp);

    cosphaangp = max(-1, min(1,costvp.*costip+sintvp.*sintip.*cosphi));
    distance = sqrt(max(0,tantvp.^2+tantip.^2-2*tantvp.*tantip.*cosphi));

    % overlap
    temp = 1./costvp+1./costip;
    cost = max(-1,min(1,HB*sqrt(distance.^2+tantvp.*tantvp.*tantip.*tantip.*sinphi.*sinphi)./temp));
    tvar = acos(cost);
    sint = sin(tvar);
    overlap = max(0,1/pi*(tvar-sint.*cost).*temp);

    likernel = overlap - temp + 0.5 * (1+cosphaangp)./costvp./costip;

    % reflectance
    refl = iso + vol.*rosskernel + geo.*likernel;

    % done
    
end