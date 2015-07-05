% fusion_BRDFusion.m
% Version 6.3.1
% Step 4
% Fusion With BRDF Correction
%
% Project: New Fusion
% By xjtang
% Created On: Unknown
% Last Update: 7/5/2015
%
% Input Arguments: 
%   main (Structure) - main inputs of the fusion process generated by fusion_inputs.m.
%
% Output Arguments: NA
%
% Instruction: 
%   1.Customize a config file for your project.
%   2.Run fusion_Inputs() first and get the returned structure of inputs
%   3.Run previous steps first to make sure required data are already generated.
%   4.Run this function with the stucture of inputs as the input argument.
%
% Version 6.0 - Unknown (by Q. Xin)
%   This script generage MODIS swath data based on Landsat synthetic data with BRDF correction.
%
% Updates of Version 6.1 - 10/3/2014 
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%   4.Changed from script to function
%   5.Modified the code to incorporate the use of fusion_inputs structure.
%
% Updates of Version 6.2 - 11/24/2014 
%   1.Bugs fixed.
%   2.Updated comments.
%   3.Added support for 250m fusion
%   4.Added support for Aqua
%
% Updates of Version 6.2.1 - 12/08/2014
%   1.Set ETM to nan if = -9999
%
% Updates of Version 6.2.2 - 1/21/2015 
%   1.Bugs fixed.
%
% Updates of Version 6.3 - 4/6/2015 
%   1.Combined 250m and 500m fusion.
%   2.Bug fixed.
%
% Updates of Version 6.3.1 - 7/5/2015
%   1.Changed output file name style.
%   2.Fixed a bug caused by thermal band.
%
% Released on Github on 10/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function fusion_BRDFusion(main)

    % check if BRDF option is checked
    if main.set.brdf == 0
        return
    end

    [Samp,Line] = meshgrid(main.etm.sample,main.etm.line);
    ETMGeo.Northing = main.etm.ulNorth-Line*30+15;
    ETMGeo.Easting = main.etm.ulEast +Samp*30-15;
    [ETMGeo.Lat,ETMGeo.Lon] = utm2deg(ETMGeo.Easting,ETMGeo.Northing,main.etm.utm);
    ETMGeo.Line = main.etm.line;
    ETMGeo.Samp = main.etm.sample;

    % start timer
    tic;
    
    % check platform
    plat = main.set.plat;
    
    % loop through all etm images
    for I_Day = 1:numel(main.date.swath)
        
        % get date information of all images
        Day = main.date.etm(I_Day);
        DayStr = num2str(Day);

        % check if result already exist
        File.Check = dir([main.output.modsubbrdf plat '*' 'ALL' '*' DayStr '*']);
        if numel(File.Check) >= 1
            disp([DayStr ' already exist, skip this date.']);
            continue;
        end

        % find ETM BRDF files
        File.ETMBRDF = dir([main.output.etmBRDF,'ETM',plat,'BRDF_A',DayStr,'*.hdr']);
        if  numel(File.ETMBRDF)~=1
            disp(['Cannot find ETMBRDF for Julian Day: ', DayStr]);
            continue;
        end   

        % read brdf coefficients
        ETMBRDF = multibandread([main.output.etmBRDF,File.ETMBRDF.name(1:(length(File.ETMBRDF.name)-4))],...
            [numel(main.etm.line),numel(main.etm.sample),6],'int16',0,'bsq','ieee-le');
        ETMBRDF(ETMBRDF<=0) = nan;
        ETMBRDF = ETMBRDF/1000;

        % read ETM
        File.ETM = dir([main.input.etm,'*',DayStr,'*.hdr']);
        if  numel(File.ETM) ~= 1
            disp(['Cannot find ETM for Julian Day: ', DayStr]);     
            continue;
        end

        ETM = multibandread([main.input.etm,File.ETM.name(1:(length(File.ETM.name)-4))],...
            [numel(main.etm.line),numel(main.etm.sample),main.etm.band],'int16',0,main.etm.interleave,'ieee-le');
        ETM(ETM==-9999) = nan;
        ETM(ETM>10000) = 10000;
        % ETM(ETM<0) = 0;
        
        % apply brdf coefficients
        ETMBLU = ETM(:,:,1).*ETMBRDF(:,:,1);
        ETMGRE = ETM(:,:,2).*ETMBRDF(:,:,2);
        ETMRED = ETM(:,:,3).*ETMBRDF(:,:,3);
        ETMNIR = ETM(:,:,4).*ETMBRDF(:,:,4);
        ETMSWIR = ETM(:,:,5).*ETMBRDF(:,:,5);
        ETMSWIR2 = ETM(:,:,6).*ETMBRDF(:,:,6);

        % find modsub
        File.MOD09SUB = dir([main.output.modsub,plat,'09SUB.','ALL','*',DayStr,'*']);

        if numel(File.MOD09SUB)<1
            disp(['Cannot find MOD09SUB for Julian Day: ', DayStr]);
            continue;
        end

        % loop through MOD09SUB file of current date
        for I_TIME = 1:numel(File.MOD09SUB)
            TimeStr = regexp(File.MOD09SUB(I_TIME).name,'\.','split');
            TimeStr = char(TimeStr(4));

            % load MOD09SUB
            MOD09SUB = load([main.output.modsub,File.MOD09SUB(I_TIME).name]);

            % fusion
            MOD09SUB.FUS09RED250 = etm2swath(ETMRED,MOD09SUB,ETMGeo,250);
            MOD09SUB.FUS09NIR250 = etm2swath(ETMNIR,MOD09SUB,ETMGeo,250);
            MOD09SUB.FUS09RED500 = etm2swath(ETMRED,MOD09SUB,ETMGeo,500);
            MOD09SUB.FUS09NIR500 = etm2swath(ETMNIR,MOD09SUB,ETMGeo,500);
            MOD09SUB.FUS09BLU500 = etm2swath(ETMBLU,MOD09SUB,ETMGeo,500);
            MOD09SUB.FUS09GRE500 = etm2swath(ETMGRE,MOD09SUB,ETMGeo,500);
            MOD09SUB.FUS09SWIR500 = etm2swath(ETMSWIR,MOD09SUB,ETMGeo,500);
            MOD09SUB.FUS09SWIR2500 = etm2swath(ETMSWIR2,MOD09SUB,ETMGeo,500);

            % save
            save([main.output.modsubbrdf,plat,'09FUS.','ALL.',DayStr,'.',TimeStr,'.mat'],'-struct','MOD09SUB');
            disp(['Done with ',DayStr,' in ',num2str(toc,'%.f'),' seconds']);
        end
    end

    % done
    
end
