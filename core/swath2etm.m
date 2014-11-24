% swath2etm.m
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
%   Swath (Matrix, Var) - MODIS swath data (change map usually).
%   MOD09SUB (Structure) - Subset of MODIS swath data over the area of the 
%       ETM image and the corresponding geometry information.
%   ETMGeo (matrix) - geometry of each pixel of the ETM image.
% 
% Output Arguments: 
%   ETM (Matrix, Var) - the resulting ETM image from MODIS swath data.
%
% Usage: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 6.0 - Unknown
%   This script reprojects MODIS change map into ETM resolution
%
% Updates of Version 6.1 - 9/17/2014 (by Xiaojing Tang)
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%   4.Initial value set to -9999 (-10000 originally).
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function ETM = swath2etm(Swath, MOD09SUB, ETMGeo)

    % Swath=((MOD09SUB.FUS09NIR-MOD09SUB.FUS09RED)./(MOD09SUB.FUS09NIR+MOD09SUB.FUS09RED)-...
    %     (MOD09SUB.MOD09NIR-MOD09SUB.MOD09RED)./(MOD09SUB.MOD09NIR+MOD09SUB.MOD09RED))*1000;

    % initialize
    ETM = -9999*ones([numel(ETMGeo.Line),numel(ETMGeo.Samp),size(Swath,3)]);

    % for each MODIS swath observation, determine the maximum possible 
    %   range of corresponding ETM pixel
    Top = max(floor(MOD09SUB.ETMLine-MOD09SUB.SizeAlongScan/30),1);
    Bot = min( ceil(MOD09SUB.ETMLine+MOD09SUB.SizeAlongScan/30),max(ETMGeo.Line));
    Lef = max(floor(MOD09SUB.ETMSamp-MOD09SUB.SizeAlongScan/30),1);
    Rig = min( ceil(MOD09SUB.ETMSamp+MOD09SUB.SizeAlongScan/30),max(ETMGeo.Samp));

    % create a mask of valid MODIS swath observation that can be generated
    MODMask = (Lef<Rig & Top<Bot);

    % loop through the entire swath
    for Index_Row=1:size(Top,1)
        for Index_Col=1:size(Top,2)  
            
            % if the current MODIS swath observation can be generated
            if MODMask(Index_Row,Index_Col)==1
                
                % boundary of ETM images for a MODIS observation
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

                % mask areas out of the shape of MODIS footprint
                ETMMask = (A^2*B^2 > (Distance.^2.*(A^2*sind(Bearing).^2+B^2*cosd(Bearing).^2)));

                % % Mask areas out of the shape of MODIS footprint
                % ETMMask=( X< A & Y <B);

                % if 90% of the swath area is covered by current ETM image
                if sum(sum(ETMMask))*30*30 > 0.9*pi*A*B
                    
                    % change data type to double
                    ETMMask = double(ETMMask);
                    
                    % replace nan value with actual nan
                    ETMMask(ETMMask<1) = nan;

                    % create a mask for pixels that is already updated by
                    %   adjacent MODIS swatch observation
                    MaskLarge = (ETMMask.*Swath(Index_Row,Index_Col,1))>ETM(PixelTop:PixelBot,PixelLef:PixelRig,1);

                    % resample MODIS swath of change map to ETM resolution
                    for I_Bands=1:size(Swath,3)
                        Temp = ETM(PixelTop:PixelBot,PixelLef:PixelRig,I_Bands);
                        Temp(MaskLarge>0) = Swath(Index_Row,Index_Col,I_Bands);
                        ETM(PixelTop:PixelBot,PixelLef:PixelRig,I_Bands)=Temp;
                    end
                    
                end
                
            end
            
        end
    end

    % set -9999 to nan
    ETM(ETM==-9999)=nan;

    % done
    
end
