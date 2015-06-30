% enviwrite.m
% Version 1.1 Fusion SP
% External
%
% Project: CCDC
% By Z. Zhu
% Created On: Unknown
% Last Update: 2/5/2015
%
% Input Arguments:
%   filename (String) -  full path and file name of the IMAGE file.
%   data (Array) - data to write.
%   UL (Vector) - coordinates of upper left corner
%   zone (Integer) - UTM zone
%
% Output Arguments: NA
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 1.0 - Unknown (by Z. Zhu)
%   Function to write matrix to ENVI format image.
%   Used in Zhe Zhu's CCDC Model.
%
% Updates of Version 1.1 Fusion SP - 2/5/2015 (by xjtang)
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%
% Released on Github on 2/5/2015, check Github Commits for updates afterwards.
%----------------------------------------------------------------
%

function enviwrite(filename,data,UL,zone)
    
    % default setting
    % type = 'int16';
    typeID = 2;
    res = [30,30];
    interleave = 'bip';
    
    % get dimmension
    n_dims = size(data);
    nrows = n_dims(1); 
    ncols = n_dims(2); 
    
    % get n bands
    bands = 1;
    if length(n_dims) >= 3
        bands = n_dims(3);
    end

    % write image
    multibandwrite(data,filename,interleave);

    % write header
        % initiate file
        filename_hdr=[filename,'.hdr'];
        fid_out=fopen(filename_hdr,'wt');
        % print file
        fprintf(fid_out,'ENVI\n');
        fprintf(fid_out,'descirption = {Landsat Scientific Data}\n');
        fprintf(fid_out,'samples = %d\n',ncols); % samples is for j
        fprintf(fid_out,'lines   = %d\n',nrows); % lines is for i
        fprintf(fid_out,'bands   = %d\n',bands);
        fprintf(fid_out,'header offset = 0\n');
        fprintf(fid_out,'file type = ENVI Standard\n');
        fprintf(fid_out,'data type = %d\n',typeID);
        fprintf(fid_out,'interleave = %s\n',interleave);
        fprintf(fid_out,'sensor type = Landsat\n');
        fprintf(fid_out,'byte order = 0\n');
        % deal with utm zone
        if (zone > 0)
            fprintf(fid_out, 'map info = {UTM, 1.000, 1.000, %d, %d, %d, %d, %d, North, WGS-84, units=Meters}',UL(1),UL(2),res(1),res(2),zone);
        else
            fprintf(fid_out, 'map info = {UTM, 1.000, 1.000, %d, %d, %d, %d, %d, South, WGS-84, units=Meters}',UL(1),UL(2),res(1),res(2),zone);
        end
        % close file
        fclose(fid_out);

    % done
        
end



