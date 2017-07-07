% swath2csv.m
% Version 1.0
% Core
%
% Project: New Fusion
% By xjtang
% Created On: 6/28/2017
% Last Update: 7/6/2017
%
% Input Arguments:
%   MOD09SUB (Structure) - Subset of MODIS swath data over the area of the ETM image and the corresponding geometry information.
%   res (Integer) - resolution, 250 or 500
%
% Output Arguments:
%   csv (Matrix) - a table of actual coordinates and axis of the swath footprints
%
% Instruction:
%   1.Call by other scripts with correct input and output arguments.
%
% Version 1.0 - 7/6/2017
%   Function to convert swath image to a table of actual coordinates and axis of the observation footprints
%
%----------------------------------------------------------------

function [header, csv] = swath2csv(MOD09SUB, res, utm)

    % grab inputs
    if res == 250
        SizeAlongScan = MOD09SUB.SizeAlongScan250;
        SizeAlongTrack = MOD09SUB.SizeAlongTrack250;
        Lat = MOD09SUB.Lat250;
        Lon = MOD09SUB.Lon250;
    elseif res == 500
        SizeAlongScan = MOD09SUB.SizeAlongScan500;
        SizeAlongTrack = MOD09SUB.SizeAlongTrack500;
        Lat = MOD09SUB.Lat500;
        Lon = MOD09SUB.Lon500;
    else
        error('Invalid resolution');
    end

    % convert lat lon to utm
    [East,North,~] = deg2utm(Lat,Lon,utm);
    
    % calculate bearing
    Bearing = nan(size(East));
    [~, Bearing(:,1:end-1)] = pos2dist(East(:,1:end-1),North(:,1:end-1),...
        East(:,2:end),North(:,2:end));
    Bearing(:,end) = 2*Bearing(:,end-1)-Bearing(:,end-2);
    
    % initialize output
    csv = zeros(numel(Lat),10);
    count = 1;
    header = {'id','row','col','lat','lon','x','y','r','a','b'};

    % loop through the entire swath
    for Index_Row=1:size(Lat,1)
        for Index_Col=1:size(Lat,2)
            % pixel id and location
            csv(count,1) = count;
            csv(count,2) = Index_Row;
            csv(count,3) = Index_Col;
            % center location and bearing
            csv(count,4) = Lat(Index_Row,Index_Col);
            csv(count,5) = Lon(Index_Row,Index_Col);
            csv(count,6) = East(Index_Row,Index_Col);
            csv(count,7) = North(Index_Row,Index_Col);
            csv(count,8) = Bearing(Index_Row,Index_Col);
            % A and B for a oval shape
            csv(count,9) = SizeAlongScan(Index_Row,Index_Col);
            csv(count,10) = SizeAlongTrack(Index_Row,Index_Col)/2;
            % increment
            count = count + 1;
        end
    end

    % done

end
