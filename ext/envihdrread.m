% envihdrread.m
% Version 1.1 Fusion SP
% External
%
% Project: CCDC
% By Z. Zhu
% Created On: Unknown
% Last Update: 10/8/2014
%
% Input Arguments:
%   filename (String) - full path and file name of the IMAGE file.
%
% Output Arguments: 
%   jiDim (Vector, Integer) - the dimension of the image.
%   jiUL (Vector, Double) - the corner coorfinates of the image.
%   resolu (Vector, Integer) - the resolution of the image.
%   ZC (Integer) - the UTM zone of the image (neg. for Southern Hem.)
%   bands (Integer) - number of bands in the image
%   interleave (String) - interleave of the iamge
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 1.0 - Unknown (by Z. Zhu)
%   Function to retrieve information from envi header file.
%   Used in Zhe Zhu's CCD Model.
%
% Updates of Version 1.1 Fusion SP - 10/8/2014 (by xjtang)
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%   4.Added support for data type 5 (double).
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------
%
function [jiDim,jiUL,resolu,ZC,bands,interleave] = envihdrread(filename)

    % open file
    fid_in = fopen(filename,'r');

    % figure out the location of the key informations in the header file
    geo_char = fscanf(fid_in,'%c',inf);
    fclose(fid_in);

    geo_char = geo_char';
    geo_str = strread(geo_char,'%s');

    indx_samples = strmatch('samples',geo_str)+2;
    indx_lines = strmatch('lines',geo_str)+2;
    indx_bands = strmatch('bands',geo_str)+2;
    indx_datatype = strmatch('data',geo_str)+3;
    indx_interleave = strmatch('interleave',geo_str)+2;
    indx_xUL = strmatch('map',geo_str)+6;
    indx_yUL = strmatch('map',geo_str)+7;
    indx_xreso = strmatch('map',geo_str)+8;
    indx_yreso = strmatch('map',geo_str)+9;
    indx_zc = strmatch('map',geo_str)+10;
    indx_zs = strmatch('map',geo_str)+11;

    % read information from the header
    cols = str2double(geo_str(indx_samples));
    rows = str2double(geo_str(indx_lines));
    jiDim = [cols,rows];
    bands = str2double(geo_str(indx_bands)); 
    datatype = str2double(geo_str(indx_datatype));
    interleave = char(geo_str(indx_interleave));
    jiUL(1) = str2double(geo_str(indx_xUL)); 
    jiUL(2) = str2double(geo_str(indx_yUL)); 
    resolu(1) = str2double(geo_str(indx_xreso)); 
    resolu(2) = str2double(geo_str(indx_yreso)); 
    ZC = str2double(geo_str(indx_zc));
    ZS = char(geo_str(indx_zs));
    if strcmp(ZS(1:5),'South')
        ZC = -ZC;
    end

    % check datatype of the image
    if datatype == 1
        in_type = 'uint8';
    elseif datatype == 2
        in_type = 'int16';
    elseif datatype == 12
        in_type = 'uint16';
    elseif datatype == 5
        in_type = 'double';
    else
        in_type = num2str(datatype);
    end
    
    % done
    
end
           
