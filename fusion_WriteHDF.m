% fusion_WriteHDF.m
% Version 6.3
% Step 4
% Write Output
%
% Project: Fusion
% By Qinchuan Xin
% Updated By: Xiaojing Tang
% Created On: Unknown
% Last Update: 4/6/2015
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
%   This script generage MODIS swath data based on Landsat synthetic data
%       with BRDF correction.
%
% Updates of Version 6.1 - 10/7/2014 (by Xiaojing Tang)
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%   4.Changed from script to function
%   5.Modified the code to incorporate the use of fusion_inputs structure.
%
% Updates of Version 6.2 - 11/24/2014 (by Xiaojing Tang)
%   1.Bug fixed.
%   2.Updated comments.
%   3.Added support for 250m fusion.
%   4.Added support for BRDF correstion.
%   5.Added support for Aqua
%
% Updates of Version 6.2.1 - 1/21/2015 (by Xiaojing Tang)
%   1.Fixed a bug in brdf support.
%
% Updates of Version 6.3 - 4/6/2015 (by Xiaojing Tang)
%   1.Combined 250 and 500 fusion.
%   2.Bug fixed.
%
% Released on Github on 10/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function fusion_WriteHDF(main)

    % start timer
    tic;
    
    % check platform
    plat = main.set.plat;
    
    % set file path
    FileName.MOD09SUB = main.output.modsubf;
    FileName.MOD09SUBB = main.output.modsubbrdf;
    
    % loop through all existing MOD09SUB files
    for I_Day = 1:numel(main.date.swath)
        
        % construct date string
        Day = main.date.swath(I_Day);
        DayStr = num2str(Day);
        
        % find files
        File.MOD09SUB = dir([FileName.MOD09SUB,plat,'09SUBF.','ALL','*',DayStr,'*']);
        if numel(File.MOD09SUB) < 1
            disp(['Cannot find MOD09SUBF for Julian Day: ', DayStr]);
            continue;
        end

        % copy original swath data to output location 
        system(['cp ' main.input.swath plat '*' DayStr '* ' main.output.fusion]);
        
        for I_TIME = 1:numel(File.MOD09SUB)
            
            TimeStr = regexp(File.MOD09SUB(I_TIME).name,'\.','split');
            TimeStr = char(TimeStr(4));

            % load MOD09SUBBRDF
            BRDFlag = main.set.brdf;
            if BRDFlag == 1
                File.MOD09SUBB = dir([main.output.modsubbrdf,plat,'09SUBFB.','ALL.',DayStr,'.',TimeStr,'.mat']);
                if numel(File.MOD09SUB) < 1
                    disp(['Cannot find MOD09SUBFB for Julian Day: ', DayStr]);
                    disp(['Only non-BRDF corrected results are produced for Julian Day: ', DayStr]);
                    BRDFlag = 0;
                end
            end
            
            % load MOD09SUB and MOD09SUBBRDF
            MOD09SUB = load([FileName.MOD09SUB,File.MOD09SUB(I_TIME).name]);
            if BRDFlag == 1 
                MOD09SUBB = load([FileName.MOD09SUBB,File.MOD09SUBB.name]);
                system(['cp ' main.input.swath plat '*' DayStr '* ' main.output.fusionbrdf]);
            end
            
            % Find HDF file to write
            HDFFile = dir([main.output.fusion,plat,'*',DayStr,'*',TimeStr,'*']);
            if numel(HDFFile) ~= 1
                disp(['Cannot find HDFFile for Julian Day: ', DayStr]);
                continue;
            end

            % Transform
            Dims250 = size(hdfread([main.output.fusion,HDFFile.name],['250','m Surface Reflectance Band 1']));
            Dims500 = size(hdfread([main.output.fusion,HDFFile.name],['500','m Surface Reflectance Band 1']));

            FUS09RED250 = ones(Dims250)*(-9999);
            FUS09RED250(MOD09SUB.MODLine250,MOD09SUB.MODSamp250) = MOD09SUB.FUS09RED250;        
            FUS09RED250 = int16(FUS09RED250);

            FUS09NIR250 = ones(Dims250)*(-9999);
            FUS09NIR250(MOD09SUB.MODLine250,MOD09SUB.MODSamp250) = MOD09SUB.FUS09NIR250;        
            FUS09NIR250 = int16(FUS09NIR250);
            
            FUS09RED500 = ones(Dims500)*(-9999);
            FUS09RED500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500) = MOD09SUB.FUS09RED500;        
            FUS09RED500 = int16(FUS09RED500);

            FUS09NIR500 = ones(Dims500)*(-9999);
            FUS09NIR500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500) = MOD09SUB.FUS09NIR500;        
            FUS09NIR500 = int16(FUS09NIR500);

            FUS09BLU500 = ones(Dims500)*(-9999);
            FUS09BLU500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500) = MOD09SUB.FUS09BLU500;        
            FUS09BLU500 = int16(FUS09BLU500);

            FUS09GRE500 = ones(Dims500)*(-9999);
            FUS09GRE500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500) = MOD09SUB.FUS09GRE500;        
            FUS09GRE500 = int16(FUS09GRE500);

            FUS09SWIR500 = ones(Dims500)*(-9999);
            FUS09SWIR500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500) = MOD09SUB.FUS09SWIR500;        
            FUS09SWIR500 = int16(FUS09SWIR500);

            FUS09SWIR2500 = ones(Dims500)*(-9999);
            FUS09SWIR2500(MOD09SUB.MODLine500,MOD09SUB.MODSamp500) = MOD09SUB.FUS09SWIR2500;        
            FUS09SWIR2500 = int16(FUS09SWIR2500);

            % write HDF file

            [~] = writeHDF([main.output.fusion,HDFFile.name],11,FUS09BLU500);
            [~] = writeHDF([main.output.fusion,HDFFile.name],12,FUS09GRE500);
            [~] = writeHDF([main.output.fusion,HDFFile.name],9,FUS09RED500);
            [~] = writeHDF([main.output.fusion,HDFFile.name],10,FUS09NIR500);
            [~] = writeHDF([main.output.fusion,HDFFile.name],14,FUS09SWIR500);
            [~] = writeHDF([main.output.fusion,HDFFile.name],15,FUS09SWIR2500);
            [~] = writeHDF([main.output.fusion,HDFFile.name],7,FUS09RED250);
            [~] = writeHDF([main.output.fusion,HDFFile.name],8,FUS09NIR250);
            

            if BRDFlag == 1
            
                % Find HDF file to write
                HDFFileB = dir([main.output.fusionbrdf,plat,'*',DayStr,'*',TimeStr,'*']);
                if numel(HDFFileB) ~= 1
                    disp(['Cannot find HDFFileB for Julian Day: ', DayStr]);
                    continue;
                end
                
                FUSB9RED250 = ones(Dims250)*(-9999);
                FUSB9RED250(MOD09SUBB.MODLine250,MOD09SUBB.MODSamp250) = MOD09SUBB.FUS09RED250;        
                FUSB9RED250 = int16(FUSB9RED250);

                FUSB9NIR250 = ones(Dims250)*(-9999);
                FUSB9NIR250(MOD09SUBB.MODLine250,MOD09SUBB.MODSamp250) = MOD09SUBB.FUSB9NIR250;        
                FUSB9NIR250 = int16(FUSB9NIR);
                
                FUSB9RED500 = ones(Dims500)*(-9999);
                FUSB9RED500(MOD09SUBB.MODLine500,MOD09SUBB.MODSamp500) = MOD09SUBB.FUSB9RED500;        
                FUSB9RED500 = int16(FUSB9RED500);

                FUSB9NIR500 = ones(Dims500)*(-9999);
                FUSB9NIR500(MOD09SUBB.MODLine500,MOD09SUBB.MODSamp500) = MOD09SUBB.FUSB9NIR500;        
                FUSB9NIR500 = int16(FUSB9NIR500);
                
                FUSB9BLU500 = ones(Dims500)*(-9999);
                FUSB9BLU500(MOD09SUBB.MODLine500,MOD09SUBB.MODSamp500) = MOD09SUBB.FUSB9BLU500;        
                FUSB9BLU500 = int16(FUSB9BLU500);

                FUSB9GRE500 = ones(Dims500)*(-9999);
                FUSB9GRE500(MOD09SUBB.MODLine500,MOD09SUBB.MODSamp500) = MOD09SUBB.FUSB9GRE500;        
                FUSB9GRE500 = int16(FUSB9GRE500);

                FUSB9SWIR500 = ones(Dims500)*(-9999);
                FUSB9SWIR500(MOD09SUBB.MODLine500,MOD09SUBB.MODSamp) = MOD09SUBB.FUSB9SWIR500;        
                FUSB9SWIR500 = int16(FUSB9SWIR500);

                FUSB9SWIR2500 = ones(Dims500)*(-9999);
                FUSB9SWIR2500(MOD09SUBB.MODLine500,MOD09SUBB.MODSamp) = MOD09SUBB.FUSB9SWIR2500;        
                FUSB9SWIR2500 = int16(FUSB9SWIR2500);

                [~] = writeHDF([main.output.fusionbrdf,HDFFileB.name],11,FUSB9BLU500);
                [~] = writeHDF([main.output.fusionbrdf,HDFFileB.name],12,FUSB9GRE500);
                [~] = writeHDF([main.output.fusionbrdf,HDFFileB.name],9,FUSB9RED500);
                [~] = writeHDF([main.output.fusionbrdf,HDFFileB.name],10,FUSB9NIR500);
                [~] = writeHDF([main.output.fusionbrdf,HDFFileB.name],14,FUSB9SWIR500);
                [~] = writeHDF([main.output.fusionbrdf,HDFFileB.name],15,FUSB9SWIR2500);
                [~] = writeHDF([main.output.fusionbrdf,HDFFileB.name],7,FUSB9RED250);
                [~] = writeHDF([main.output.fusionbrdf,HDFFileB.name],8,FUSB9NIR250);
            
            end
            
        end

        disp(['Done with ',DayStr,' in ',num2str(toc,'%.f'),' seconds']);
    end

    % done
    
end
