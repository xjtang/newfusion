% swath2etm.m
% Version 6.4.1
% Core
%
% Project: New Fusion
% By xjtang
% Created On: Unknown
% Last Update: 10/18/2015
%
% Input Arguments:
%   Swath (Matrix, Var) - MODIS swath data (change map usually).
%   MOD09SUB (Structure) - Subset of MODIS swath data over the area of the ETM image and the corresponding geometry information.
%   ETMGeo (matrix) - geometry of each pixel of the ETM image.
% 
% Output Arguments: 
%   ETM (Matrix, Var) - the resulting ETM image from MODIS swath data.
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 6.0 - Unknown (by Q. Xin)
%   This script reprojects MODIS change map into ETM resolution
%
% Updates of Version 6.1 - 9/17/2014 
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%   4.Initial value set to -9999 (-10000 originally).
%
% Updates of Version 6.2 - 12/14/2014 
%   1.Bugs fixed.
%   2.Generate band difference map according to new fusion workflow.
%
% Updates of Version 6.3 - 1/26/2015 
%   1.Convert MODIS swath style data to ETM scale with specific setting.
%   2.Operational with this version.
%   3.Bugs fixed.
%
% Updates of Version 6.3.1 - 3/26/2015 
%   1.Changed output data structure.
%   2.Bugs fixed.
%   3.A bug caused by negative evalues in calculating max image is fixed.
%
% Updates of Version 6.4 - 4/4/2015 
%   1.Combined 250 and 500 fusion.
%   2.Bug fixed.
%
% Updates of Version 6.4.1 - 10/18/2015
%   1.Implement model constants
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function [ETMnob,ETMmax,ETMavg] = swath2etm(Swath, MOD09SUB, ETMGeo,res,NAValue)

    % grab inputs
    if res == 250
        SizeAlongScan = MOD09SUB.SizeAlongScan250;
        SizeAlongTrack = MOD09SUB.SizeAlongTrack250;
        ETMLine = MOD09SUB.ETMLine250;
        ETMSamp = MOD09SUB.ETMSamp250;
        Lat = MOD09SUB.Lat250;
        Lon = MOD09SUB.Lon250;
        MODBear = MOD09SUB.Bearing250;
    elseif res == 500
        SizeAlongScan = MOD09SUB.SizeAlongScan500;
        SizeAlongTrack = MOD09SUB.SizeAlongTrack500;
        ETMLine = MOD09SUB.ETMLine500;
        ETMSamp = MOD09SUB.ETMSamp500;
        Lat = MOD09SUB.Lat500;
        Lon = MOD09SUB.Lon500;
        MODBear = MOD09SUB.Bearing500;
    else
        error('Invalid resolution');
    end
    
    % initialize
    ETMnob = 0*ones([numel(ETMGeo.Line),numel(ETMGeo.Samp)]);
    ETMmax = 0*ones([numel(ETMGeo.Line),numel(ETMGeo.Samp)]);
    ETMavg = 0*ones([numel(ETMGeo.Line),numel(ETMGeo.Samp)]);

    % for each MODIS swath observation, determine the maximum possible 
    %   range of corresponding ETM pixel
    Top = max(floor(ETMLine-SizeAlongScan/30),1);
    Bot = min( ceil(ETMLine+SizeAlongScan/30),max(ETMGeo.Line));
    Lef = max(floor(ETMSamp-SizeAlongScan/30),1);
    Rig = min( ceil(ETMSamp+SizeAlongScan/30),max(ETMGeo.Samp));

    % create a mask of valid MODIS swath observation that can be generated
    MODMask = (Lef<Rig & Top<Bot);

    % loop through the entire swath
    for Index_Row=1:size(Top,1)
        for Index_Col=1:size(Top,2)  
            
            % if the current MODIS swath observation can be generated
            if MODMask(Index_Row,Index_Col)==1 && ~isnan(Swath(Index_Row,Index_Col))
                
                % boundary of ETM images for a MODIS observation
                PixelTop = Top(Index_Row,Index_Col);
                PixelBot = Bot(Index_Row,Index_Col);
                PixelLef = Lef(Index_Row,Index_Col);
                PixelRig = Rig(Index_Row,Index_Col);      

                % distance and bearing for each ETM pixel to MODIS center.
                [Distance, Bearing] = pos2dist(Lat(Index_Row,Index_Col),Lon(Index_Row,Index_Col),...
                    ETMGeo.Lat(PixelTop:PixelBot,PixelLef:PixelRig),ETMGeo.Lon(PixelTop:PixelBot,PixelLef:PixelRig));
                Bearing = MODBear(Index_Row,Index_Col)-Bearing;

                % A and B for a oval shape
                A = SizeAlongScan(Index_Row,Index_Col);
                B = SizeAlongTrack(Index_Row,Index_Col)/2;

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
                    MaskLarger = abs(ETMMask.*Swath(Index_Row,Index_Col))>abs(ETMmax(PixelTop:PixelBot,PixelLef:PixelRig));

                    % generate number of observation map
                    Temp = ETMnob(PixelTop:PixelBot,PixelLef:PixelRig);
                    Temp(ETMMask>0) = Temp(ETMMask>0)+1;
                    ETMnob(PixelTop:PixelBot,PixelLef:PixelRig) = Temp;
                    
                    % generate sum map
                    Temp = ETMavg(PixelTop:PixelBot,PixelLef:PixelRig);
                    Temp(ETMMask>0) = Temp(ETMMask>0)+Swath(Index_Row,Index_Col);
                    ETMavg(PixelTop:PixelBot,PixelLef:PixelRig) = Temp;
                    
                    % resample max(or min) map
                    Temp = ETMmax(PixelTop:PixelBot,PixelLef:PixelRig);
                    Temp(MaskLarger>0) = Swath(Index_Row,Index_Col);
                    ETMmax(PixelTop:PixelBot,PixelLef:PixelRig)=Temp;
                    
                end
                
            end
            
        end
    end

    % calculate average
    Temp = ETMnob;
    Temp(Temp==0) = 1;
    ETMavg = ETMavg./Temp;
    
    % set 0 to -9999
    ETMmax(ETMnob==0) = NAValue;
    ETMavg(ETMnob==0) = NAValue;
    ETMnob(ETMnob==0) = NAValue;

    % done
    
end
