% swath2etm.m
% Version 6.3
% Core
%
% Project: Fusion
% By Qinchuan Xin
% Updated By: Xiaojing Tang
% Created On: Unknown
% Last Update: 1/21/2014
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
% Updates of Version 6.2 - 12/14/2014 (by Xiaojing Tang)
%   1.Bugs fixed.
%   2.Generate band difference map according to new fusion workflow.
%
% Updates of Version 6.3 - 1/21/2014 (by Xiaojing Tang)
%   1.Convert MODIS swath style data to ETM scale with specific setting.
%   2.Operational with this version.
%   3.Bugs fixed.
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function ETM = swath2etm(Swath, MOD09SUB, ETMGeo)

    % initialize
    ETM = 0*ones([numel(ETMGeo.Line),numel(ETMGeo.Samp),3]);

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

                   % if 90% of the swath area is covered by current ETM image
                if sum(sum(ETMMask))*30*30 > 0.9*pi*A*B
                    
                    % change data type to double
                    ETMMask = double(ETMMask);
                    
                    % replace nan value with actual nan
                    ETMMask(ETMMask<1) = nan;

                    % create a mask for pixels that is already updated by
                    %   adjacent MODIS swatch observation
                    MaskFilled = ETM(PixelTop:PixelBot,PixelLef:PixelRig,1)>0;
                    MaskLarge = (ETMMask.*Swath(Index_Row,Index_Col))>ETM(PixelTop:PixelBot,PixelLef:PixelRig,1);

                    % generate number of observation map
                    Temp = ETM(PixelTop:PixelBot,PixelLef:PixelRig,1);
                    Temp(ETMMask>0) = Temp(ETMMask>0)+1;
                    ETM(PixelTop:PixelBot,PixelLef:PixelRig,1) = Temp;
                    
                    % generate average map
                    Temp = ETM(PixelTop:PixelBot,PixelLef:PixelRig,2);
                    Temp(MaskFilled>0) = Temp(MaskFilled>0)+Swath(Index_Row,Index_Col);
                    ETM(PixelTop:PixelBot,PixelLef:PixelRig,2) = Temp;
                    
                    % resample max(or min) map
                    Temp = ETM(PixelTop:PixelBot,PixelLef:PixelRig,3);
                    Temp(MaskLarge>0) = Swath(Index_Row,Index_Col);
                    ETM(PixelTop:PixelBot,PixelLef:PixelRig,3)=Temp;
                    
                end
                
            end
            
        end
    end

    % calculate averate
    Temp = ETM(:,:,1);
    Temp(Temp==0) = 1;
    ETM(:,:,2) = ETM(:,:,2)./Temp;
    
    
    % set 0 to -9999
    ETM(ETM==0)=-9999;

    % done
    
end
