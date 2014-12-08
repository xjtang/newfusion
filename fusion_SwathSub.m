% fusion_SwathSub.m
% Version 6.2.1
% Step 2
% Subsetting the Swath Data
%
% Project: Fusion
% By Qinchuan Xin
% Updated By: Xiaojing Tang
% Created On: Unknown
% Last Update: 12/1/2014
%
% Input Arguments: 
%   main (Structure) - main inputs of the fusion process generated by
%     fusion_inputs.m.
%
% Output Arguments: NA
%
% Usage: 
%   1.Customize the main input file (fusion_inputs.m) with proper settings
%       for specific project.
%   2.Run fusion_Inputs() first and get the returned structure of inputs
%   3.Run previous steps first to make sure required data are already
%       generated.
%   4.Run this function with the stucture of inputs as the input argument.
%
% Version 6.0 - Unknown
%   This script subsets original MODIS swath data to fit the coverage of a
%       Landsat ETM image.
%   This script also creates a Matlab object called MOD09SUB that contains
%       the subset and related information.
%
% Updates of Version 6.1 - 10/1/2014 (by Xiaojing Tang)
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%   4.Changed from script to function
%   5.Modified the code to incorporate the use of fusion_inputs structure.
%   6.Added processing of two other MODIS land bands (correspond to Landsat 
%       band 5 and 7)
%
% Updates of Version 6.1.1 - 10/10/2014 (by Xiaojing Tang)
%   1.automatically skip if output file already exist.
%
% Updates of Version 6.2 - 12/1/2014 (by Xiaojing Tang)
%   1.Bug fixed.
%   2.Added support for 250m.
%   3.Updated comments.
%   4.Added support for MODIS Aqua
%   5.Automatically remove swath that does not cover roi.
%
% Updates of Version 6.2.1 - 12/8/2014 (by Xiaojing Tang)
%   1.Move non-usable swath to DUMP instead of deleting.
%
% Released on Github on 10/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function fusion_SwathSub(main)

    % MOD09 Swath Info
    % FileName.Day=datenum(2003,9,1);	% nadir image
    % FileName.Day=datenum(2000,9,12);	% two images
    % FileName.Day=datenum(2000,9,17);	% off-nadir image

    % start the timer
    tic;
    
    % loop through all files
    for I_Day = 1:numel(main.date.swath)
        
        % check platform
        plat = main.set.plat;
        
        % find files
        Day = main.date.swath(I_Day);
        DayStr = num2str(Day);
        File.MOD09 = dir([main.input.swath,plat,'09.A',DayStr,'*']);

        % all files exist
        if numel(File.MOD09)<1
            disp(['Cannot find MOD09 for Julian Day: ', DayStr]);
            continue;
        end

        % loop through MODIS swath images of that date
        for I_TIME = 1:numel(File.MOD09)
            
            % construct time string
            TimeStr = regexp(File.MOD09(I_TIME).name,'\.','split');
            TimeStr = char(TimeStr(3));
            
            % check if file already exist
            output = [main.output.modsub,plat,'09SUB.',num2str(main.set.res),'m.',DayStr,'.',TimeStr,'.mat'];
            if exist(output,'file')>0 
                disp([output ' already exist, skip one'])
                continue;
            end
            
            % initialize MOD09SUB
            MOD09SUB = [];

            % interpolate swath geolocation data
            Lat1km = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],'Latitude' ));
            Lon1km = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],'Longitude'));
            Lat = geoInterpMODIS(Lat1km,main.set.res);
            Lon = geoInterpMODIS(Lon1km,main.set.res);
            
            % convert to UTM
            [East,North,~] = deg2utm(Lat,Lon,main.etm.utm);
            
            % create mask for area outside the coverage of Landsat image
            Mask = (East>main.etm.subULEast & East<main.etm.subLREast & ...
                North<main.etm.subULNorth & North>main.etm.subLRNorth);
            
            % find lines and samples in swath data that is not masked
            [Row,Col] = find(Mask>0);
            NLine = 1000/main.set.res*10;
            MOD09SUB.MODLine = (floor(min(Row)/NLine)*NLine+1:ceil(max(Row)/NLine)*NLine)';
            MOD09SUB.MODSamp = (min(Col):max(Col));

            % loop through all non-masked lines
            if numel(MOD09SUB.MODLine)>0
                
                % get swath observation geometry for sub_image
                [ScanAngle,ViewAngle,SizeAlongScan,SizeAlongTrack]= swathGeo(main.set.res);
                MOD09SUB.SizeAlongScan = ones(numel(MOD09SUB.MODLine),1)*SizeAlongScan(MOD09SUB.MODSamp);
                MOD09SUB.SizeAlongTrack = ones(numel(MOD09SUB.MODLine),1)*SizeAlongTrack(MOD09SUB.MODSamp);
                MOD09SUB.ViewAngle = ones(numel(MOD09SUB.MODLine),1)*ViewAngle(MOD09SUB.MODSamp);
                MOD09SUB.Resolution = main.set.res;

                % get swath observation latitude and longitude
                MOD09SUB.Lat = Lat(MOD09SUB.MODLine,MOD09SUB.MODSamp);
                MOD09SUB.Lon = Lon(MOD09SUB.MODLine,MOD09SUB.MODSamp);

                % get swath reflectance
                MOD09RED = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],[num2str(main.set.res),'m Surface Reflectance Band 1']));
                MOD09NIR = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],[num2str(main.set.res),'m Surface Reflectance Band 2']));
                MOD09SUB.MOD09RED = MOD09RED(MOD09SUB.MODLine,MOD09SUB.MODSamp);
                MOD09SUB.MOD09NIR = MOD09NIR(MOD09SUB.MODLine,MOD09SUB.MODSamp);

                if main.set.res == 500
                    MOD09BLU = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],[num2str(main.set.res),'m Surface Reflectance Band 3']));
                    MOD09GRE = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],[num2str(main.set.res),'m Surface Reflectance Band 4']));
                    MOD09SUB.MOD09BLU = MOD09BLU(MOD09SUB.MODLine,MOD09SUB.MODSamp);
                    MOD09SUB.MOD09GRE = MOD09GRE(MOD09SUB.MODLine,MOD09SUB.MODSamp);
                    MOD09SWIR = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],[num2str(main.set.res),'m Surface Reflectance Band 6']));
                    MOD09SWIR2 = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],[num2str(main.set.res),'m Surface Reflectance Band 7']));
                    MOD09SUB.MOD09SWIR = MOD09SWIR(MOD09SUB.MODLine,MOD09SUB.MODSamp);
                    MOD09SUB.MOD09SWIR2 = MOD09SWIR2(MOD09SUB.MODLine,MOD09SUB.MODSamp);
                end
                
                % get swath QA
                MODISQA = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],'1km Reflectance Data State QA'));
                MODISQA = kron(MODISQA,ones(1000/main.set.res));
                MOD09SUB.MODISQA = MODISQA(MOD09SUB.MODLine,MOD09SUB.MODSamp);

                % get band QA
                BandQA = double(hdfread([main.input.swath,File.MOD09(I_TIME).name],[num2str(main.set.res),'m Reflectance Band Quality']));
                MOD09SUB.BandQA = BandQA(MOD09SUB.MODLine,MOD09SUB.MODSamp);

                % get ETM Line & Sample for the MODIS subimage
                East = East(MOD09SUB.MODLine,MOD09SUB.MODSamp);
                North = North(MOD09SUB.MODLine,MOD09SUB.MODSamp);

                MOD09SUB.ETMLine = (main.etm.ulNorth-North)/30;
                MOD09SUB.ETMSamp = (East-main.etm.ulEast)/30;

                % get bearing
                Bearing = nan(size(MOD09SUB.Lat));
                [~, Bearing(:,1:end-1)] = pos2dist(MOD09SUB.Lat(:,1:end-1),MOD09SUB.Lon(:,1:end-1),...
                    MOD09SUB.Lat(:,2:end),MOD09SUB.Lon(:,2:end));
                Bearing(:,end) = 2*Bearing(:,end-1)-Bearing(:,end-2);
                MOD09SUB.Bearing = Bearing;

                % get QA data
                MOD09SUB = swathInterpQA(MOD09SUB);

                % save and end timer
                save([main.output.modsub,plat,'09SUB.',num2str(main.set.res),'m.',DayStr,'.',TimeStr,'.mat'],'-struct','MOD09SUB');
                disp(['Done with ',DayStr,' in ',num2str(toc,'%.f'),' seconds']);
            else
                disp(['No points in: ',File.MOD09(I_TIME).name]);
                system(['mv ',main.input.swath,File.MOD09(I_TIME).name,' ',main.output.dump])
            end
        end
    end

    % done
    
end
