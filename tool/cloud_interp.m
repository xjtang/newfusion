% cloud_interp.m
% Version 1.2
%
% Project: Fusion
% By Xiaojing Tang
% Created On: 11/24/2014
% Last Update: 12/11/2014
%
% Input Arguments: 
%   path - path to MOD09SUB m-files.
%   res - resolusion of MODIS swath.
%   plat - paltform MOD/MYD
%   outFile - output file.
%   
% Output Arguments: NA
%
% Usage: 
%   1.Generate MOD09SUB m-files with the main fusion codes.
%   2.Run this script with correct input arguments.
%
% Version 1.0 - 11/25/2014
%   This script generates plot and table for cloud statistics of the MOD09SUB data.
%   
% Updates of Version 1.1 - 11/26/2014
%   1.Seperate year and doy.
%
% Updates of Version 1.2 - 12/11/2014
%   1.Added support for aqua.
%
% Created on Github on 11/24/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function cloud_interp(path,res,plat,outFile)

  % get list of all valid files in the input directory
  fileList = dir([path,plat,'09SUB*',num2str(res),'*.mat']);

  % check if list is empty
  if numel(fileList)<1
    disp(['Cannot find any .mat file at ',num2str(res),'m resolution.']);
    return;
  end

  % initiate results
  perCloud = zeros(numel(fileList),1);
  dateYear = zeros(numel(fileList),1);
  dateDOY = zeros(numel(fileList),1);

  % loop through all files in the list
  for i = 1:numel(fileList)
    
    % load the .mat file
    MOD09SUB = load([path,fileList(i).name]);
  
    % total number of swath observation
    nPixel = numel(MOD09SUB.MODLine)*numel(MOD09SUB.MODSamp);
    
    % total cloudy
    nCloud = sum(MOD09SUB.QACloud(:));
    
    % insert result
    perCloud(i) = round(nCloud/nPixel*1000)/10;
    p = regexp(fileList(i).name,'\d\d\d\d\d\d\d');
    dateYear(i) = str2num(fileList(i).name(p:(p+3)));
    dateDOY(i) = str2num(fileList(i).name((p+4):(p+6)));
  
  end
  
  % draw plot
    
  
  % save result
  r = [dateYear,dateDOY,perCloud];
  dlmwrite(outFile,r,'delimiter',',','precision',10);

  % done

end
