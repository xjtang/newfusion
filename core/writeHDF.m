% writeHDF.m
% Version 6.1
% Core
%
% Project: Fusion
% By Qinchuan Xin
% Updated By: Xiaojing Tang
% Created On: Unknown
% Last Update: 9/17/2014
%
% Input Arguments:
%   HDFFileName (String) - the file name of the HDF file to write to.
%   Band (Integer) - band number to write to in the HDF file.
%   Data (Matrix, Numeric) - data to be written (the precision must be the
%       the same as the layer).
%   Start (Vector, Integer, 1x2) - the start point of the writting process
%       ([0 0] by default if not specified).
%
% Output Arguments: 
%   Status (Integer) - <0: HDF writing process failed.
%                      >=0: See specific status in help document.
%
% Usage: 
%   1.Call by other scripts with correct input and output arguments.
%   2.HDFFileName, Band, and Data are required input arguments.
%   3.Start will be [0 0] if not specified.
%
% Version 6.0 - Unknown
%   Function to write data to a HDF file.
%   Utilizes the built-in HDF connection in Matlab
%
% Updates of Version 6.1 - 9/17/2014 (by Xiaojing Tang)
%   1.Updated comments.
%   2.Changed coding style.
%   3.Modified for work flow of fusion version 6.1.
%
% Released on Github on 11/15/2014, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function Status=writeHDF(HDFFileName,Band,Data,Start)

    % checking input and output arguments
    error(nargchk(3, 4, nargin));

    % open HDF files to write
    HDFID = hdfsd('start',HDFFileName,'write');
    if HDFID<1
        error(['Reading HDF files:', HDFFileName]);
    end
    
    % load specific band to write
    SDSID = hdfsd('select',HDFID,Band);

    % specify the beginning to write
    ds_start = zeros(1:ndims(Data));
    if nargin == 4
        ds_start = Start;
    end

    % writing data
    Status=hdfsd('writedata',SDSID,ds_start,[],size(Data),Data');

    % check status
    if Status <0
        error('writing hdf fail');
    end

    % close file
    hdfsd('endaccess',SDSID);
    hdfsd('end',HDFID);

    % done
    
end
