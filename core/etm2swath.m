% etm2swath.m
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
%   ETM (Matrix, Double) - Landsat ETM data.
%   MOD09SUB (Structure) - Subset of MODIS swath data over the area of the 
%       ETM image and the corresponding geometry information.
%   ETMGeo (matrix) - geometry of each pixel of the ETM image.
%   Thres4NaN (Single) - threshold for a MODIS pixel to be called as NA.
% 
% Output Arguments: 
%   Swath (Vector, Double) - vector of swath data generated from ETM image.
%
% Usage: 
%   1.Call by other scripts with correct input and output arguments.
%   2.ETM, MOD09SUB, and ETMGeo are required input arguments.
%   3.Thres4NaN will be 0.1 (<10%) if not specified.
%
% Version 6.0 - Unknown
%   This script is designed to predict the MODIS swath observations from 
%       Landsat ETM images.
%
% Updates of Version 6.1 - 9/16/2014 (by Xiaojing Tang)
%   1.Updated comments.
%   2.Changed coding style
%   3.Modified for work flow of fusion version 6.1
%
%----------------------------------------------------------------
%
function Swath = etm2swath(ETM,MOD09SUB,ETMGeo,Thres4NaN)

    % check the input arguments
    error(nargchk(3, 4, nargin));

    % set ThresNaN to 0.1 if not specified
    if nargin < 4
        Thres4NaN =0.1;
        % disp('Default Threshold_NaN: <10% pixels are nan in a footprint');
    end

    % check if the size of ETM and ETMGeo matches
    if size(ETM)~=size(ETMGeo.Lat)
        error('ETM image and ETMGeo Latitude image must have the same size');
    end

    % ETM=ETMRED;
    % Thres4NaN =0.2;

    % initialize
    Swath = nan(size(MOD09SUB.SizeAlongScan));

    % for each MODIS swath observation, determine the maximum possible 
    %   range of corresponding ETM pixel
    Top = max(floor(MOD09SUB.ETMLine-MOD09SUB.SizeAlongScan/30),1);
    Bot = min( ceil(MOD09SUB.ETMLine+MOD09SUB.SizeAlongScan/30),max(ETMGeo.Line));
    Lef = max(floor(MOD09SUB.ETMSamp-MOD09SUB.SizeAlongScan/30),1);
    Rig = min( ceil(MOD09SUB.ETMSamp+MOD09SUB.SizeAlongScan/30),max(ETMGeo.Samp));

    % create a mask of valid MODIS swath observation that can be generated
    MODMask = (Lef<Rig & Top<Bot);

    % loop through the entire swath
    for Index_Row = 1:size(Top,1)
        for Index_Col = 1:size(Top,2)

            % if the current MODIS swath observation can be generated
            if MODMask(Index_Row,Index_Col) == 1

                % boundary of ETM images for current MODIS observation
                PixelTop = Top(Index_Row,Index_Col);
                PixelBot = Bot(Index_Row,Index_Col);
                PixelLef = Lef(Index_Row,Index_Col);
                PixelRig = Rig(Index_Row,Index_Col);      

                % distance and bearing for each ETM pixel to MODIS center.
                [Distance, Bearing] = pos2dist(MOD09SUB.Lat(Index_Row,Index_Col),MOD09SUB.Lon(Index_Row,Index_Col),...
                    ETMGeo.Lat(PixelTop:PixelBot,PixelLef:PixelRig),ETMGeo.Lon(PixelTop:PixelBot,PixelLef:PixelRig));
                Bearing = MOD09SUB.Bearing(Index_Row,Index_Col)-Bearing;

                % A and B for a oval shape
                A = MOD09SUB.SizeAlongScan(Index_Row,Index_Col);
                B = MOD09SUB.SizeAlongTrack(Index_Row,Index_Col)/2;

                % distance to the center line
                X = abs(Distance.*cosd(Bearing));
                Y = abs(Distance.*cosd(Bearing));

                % mask areas out of the shape of MODIS footprint
                ETMMask = (A^2*B^2 > (Distance.^2.*(A^2*sind(Bearing).^2+B^2*cosd(Bearing).^2)));

                % % Mask areas out of the shape of MODIS footprint
                % ETMMask=( X< A & Y <B);

                % if 90% of the swath area is covered by current ETM image
                if sum(sum(ETMMask))*30*30 > 0.9*pi*A*B  

                    % calculate weights and grab reflectance data
                    Weights = MOD09SUB.SizeAlongScan(Index_Row,Index_Col)-X;
                    Weights(ETMMask~=1) = nan;
                    ETMRefl = ETM(PixelTop:PixelBot,PixelLef:PixelRig);
                    ETMRefl(ETMMask~=1) = nan;

                    % convolution if number of NaN < Threshold_NaN
                    if (sum(sum(ETMMask))-sum(sum(~isnan(ETMRefl))))/sum(sum(ETMMask)) < Thres4NaN
                        Swath(Index_Row,Index_Col)=...
                            nansum(nansum(ETMRefl.*Weights))/nansum(nansum(Weights));
                    end

                end

            end

        end
    end

    % done
    
end
