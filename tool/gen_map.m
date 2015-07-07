% gen_map.m
% Version 1.0
% Tools

% Project: New Fusion
% By xjtang
% Created On: 7/6/2014
% Last Update: 7/6/2015
%
% Input Arguments: 
%   file - full path to config file.
%   filename - output file name.
%   mapType - type of map to generate
%               DoC - date of change (e.g. 2010023)
%               MoC - month of change (e.g. 5)
%               CoC - class of change (change, no change)
%   
% Output Arguments: NA
%
% Instruction: 
%   1.Finish the fusion process and have change result generated.
%   2.Use this function to generate change map in envi format.
%
% Version 1.0 - 11/25/2014
%   This script generates change map in envi format based on fusion result.
%   Only DoC map available in this version.
%
% Created on Github on 11/24/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function gen_map(file,filename,mapType)
    
    % load config file
    if exist(file,'file')
        run(file);
    else
        disp('Can not fine the confid file, abort.');
        return;
    end
    
    % check if all parameters exist in config file
    % data path
    if ~exist('dataPath', 'var')
        dataPath = '/projectnb/landsat/projects/fusion/br_site/data/modis/2013/';
    end
    % landsat path and row
    if ~exist('landsatScene', 'var')
        landsatScene = [227,65];
    end
    
    % assemble useful path
    inPath = [dataPath 'P' num2str(landsatScene(1),'%03d') 'R' num2str(landsatScene(2),'%03d') '/CHGMAT/'];
    outPath = [dataPath 'P' num2str(landsatScene(1),'%03d') 'R' num2str(landsatScene(2),'%03d') '/CHGMAP/'];
    etmPath = [dataPath 'ETMSYN/P' num2str(landsatScene(1),'%03d') 'R' num2str(landsatScene(2),'%03d') '/'];

    % gather landsat geo information
    etmFirst = dir([etmPath '*.hdr']);
    if numel(etmFirst) == 0 
        etmFirst = dir([etmPath '*.HDR']);
    end
    if numel(etmFirst) == 0 
        disp('Can not gather ETM geo information, only binary file will be created.')
        etm.dim = -1;
    end
    etmFirst = [etmPath etmFirst(1).name];
    [etm.dim,etm.ul,etm.res,etm.utm,etm.bands,etm.itl] = envihdrread(etmFirst);
    etm.sample = 1:etm.dim(1);
    etm.line = (1:etm.dim(2))';
    etm.ulNorth = etm.ul(2);
    etm.ulEast = etm.ul(1);
    etm.lrNorth = etm.ulNorth-etm.res(2)*etm.line(end);
    etm.lrEast = etm.ulEast+etm.res(1)*etm.sample(end);
    
    % initialize
    MAP = ones(length(etm.line),length(etm.sample))*-9999;
    
    % line by line processing
    for i = etm.line
        
        % check if result exist
        File.Check = dir([main.output.chgmat 'ts.r' num2str(i) '.chg.mat']);
        if numel(File.Check) == 0
            disp([num2str(i) ' line cache does not exist, skip this line.']);
            continue;  
        end
        
        % read input data
        CHG = load([main.output.chgmat 'ts.r' num2str(i) '.chg.mat']);
        
        % processing
        for j = etm.sample
            
            % subset data
            X = squeeze(CHG(j,:,2));
            
            % see if this pixel is eligible
            if max(X) <= 0
                continue
            end
            
            % different types of maps
            if strcmp(mapType,'DoC') 
                
                
                
            else
                disp('Invalid change type, abort.')
                return
            end
            
            % assign result
            
        end 
        
        % clear processed line
        clear 'CHG';
        
    end
   
    % export map
    
    
    % done
    
end

