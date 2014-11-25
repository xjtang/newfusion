% cloud_interp.m
% Version 1.0
%
% Project: Fusion
% By Xiaojing Tang
% Created On: 11/24/2014
%
% Input Arguments: 
%   path - path to MOD09SUB m-files.
%   res - resolusion of MODIS swath.
%   outFile - output file.
%   
% Output Arguments: NA
%
% Usage: 
%   1.Generate MOD09SUB m-files with the main fusion codes.
%   2.Run this script with correct input arguments.
%
% Version 1.0 - 11/24/2014
%   This script generates plot and table for cloud statistics of the MOD09SUB data.
%   
% Created on Github on 11/24/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function cloud_interp(path,res,outFile)

  % get list of all valid files in the input directory
  fileList = dir([path,'MOD09SUB*',num2str(res),'*.mat']);

  % check if list is empty
  if numel(fileList)<1
    disp(['Cannot find any .mat file at ',num2str(res),'m resolution.']);
    return;
  end

  % initiate results
  perCloud = zeros(numel(fileList));
  dateList = zeros(numel(fileList));

  % loop through all files in the list
  for i = 1:numel(fileList)
    
    % load the .mat file
    MOD09SUB = load([path,fileList(i).name]);
  
    % total number of swath observation
    nPixel = numel(MOD09SUB.MODLine)*numel(MOD09SUB.MODSamp);
    
    % total cloudy
    nCloud = sum(MOD09SUB.QACloud(:));
    
    % insert result
    perCloud(i) = nCloud/nPixel;
    dateList(i) = 2005123;
  
  end

  % done

end
