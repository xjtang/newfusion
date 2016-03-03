% getDateList.m
% Version 1.0.2
% Core
%
% Project: New Fusion
% By xjtang
% Created On: 10/8/2014
% Last Update: 2/4/2016
%
% Input Arguments:
%   Path (String) - the input directory of images
% 
% Output Arguments: 
%   dateList (Vector,Long) - vector of Julian dates of all images in the input directory.
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 1.0 - 10/8/2014 
%   This function checks all the image files in the inpur directory and output a list of Julian dates of those images.
%
% Updates of Version 1.0.1 - 10/10/2014 
%   1.Bug fixed: date list is now unique.
%
% Updates of Version 1.0.2 - 2/4/2016
%   2.Added handle for empty folder.
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function dateList = getDateList(path)
    
    % read files
    fileList = dir([path '*.hdf']);
    if numel(fileList) == 0 
        fileList = dir([path '*.hdr']);
    end
    if numel(fileList) == 0 
        disp(['No .hd* file found in ' path]);
        dateList = 0;
        return;
    end
    
    % initialize
    dateList = 1:numel(fileList);

    % loop through all files
    for i = 1:numel(fileList)
        name = fileList(i).name;
        dChar = regexp(name,'\d\d\d\d\d\d\d');
        dateList(i) = str2num(name(dChar(1):(dChar(1)+6)));
    end

    % make the list unique
    dateList = unique(dateList);
    
    % done
    
end

