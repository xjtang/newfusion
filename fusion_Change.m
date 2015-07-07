% fusion_Change.m
% Version 1.0.1
% Step 8
% Detect Change
%
% Project: New Fusion
% By xjtang
% Created On: 7/1/2015
% Last Update: 7/6/2015
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
% Version 1.0 - 7/1/2015
%   This script detect change in fusion time series.
%
% Version 1.0.1 - 7/6/2015
%   1.Fxied a num2str conversion bug.
%   2.Fixed a variable bug.
%   3.Fixed a band id bug.
%
% Released on Github on 7/1/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function fusion_Change(main)

    % calculate the lines that will be processed by this job
    njob = main.set.job(2);
    thisjob = main.set.job(1);
    if njob >= thisjob && thisjob >= 1 
        % subset lines
        jobLine = thisjob:njob:length(main.etm.line);
    else
        jobLine = 1:length(main.etm.line);
    end

    % start timer
    tic;

    % line by line processing
    for i = jobLine
        
        % check if result already exist
        File.Check = dir([main.output.chgmat 'ts.r' num2str(i) '.chg.mat']);
        if numel(File.Check) >= 1
            disp([i ' line already exist, skip this line.']);
            continue;  
        end
        
        % check if cache exist
        File.Check = dir([main.output.cache 'ts.r' num2str(i) '.cache.mat']);
        if numel(File.Check) == 0
            disp([num2str(i) ' line cache does not exist, skip this line.']);
            continue;
        end
        
        % load TS cache
        TS = load([main.output.cache 'ts.r' num2str(i) '.cache.mat']);
        samp = size(TS.Data,1);
        nday = size(TS.Data,2);
        
        % initialize
        CHG.Date = TS.Date;
        CHG.Data = ones(samp,nday,2)*(-9999);
        
        % pixel by pixel processing
        for j = 1:samp
            
            % compose data
            PTS = (squeeze(TS.Data(j,:,main.model.band)))';
            CLD = squeeze(TS.Data(j,:,end));
            CCTS = ones(length(main.model.band),nday);
            for k = 1:length(main.model.band)
                CCTS(k,:) = PTS(k,:).*not(CLD)+(-9999)*CLD;
            end
            
            % detect change
            CHG.Data(j,:,:) = change(CCTS,main.model);
            
        end
        
        % save current file
        save([main.output.cache 'ts.r' num2str(i) '.mat'],'CHG')
        disp(['Done with line',num2str(i),' in ',num2str(toc,'%.f'),' seconds']); 
        
    end
    
    % done
    
end

