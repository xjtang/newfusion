% compile.m
% Version 1.0
% Compiling
%
% Project: New Fusion
% By xjtang
% Created On: 1/16/2016
% Last Update: 1/16/2016
%
% Instruction: 
%   1.Use this script to compile the fusion model into standalone version.
%
% Version 1.0 - 10/8/2014 
%   This script compiles the model.
%
% Released on Github on 1/16/2016, check Github Commits for updates afterwards.
%----------------------------------------------------------------

% add program to path
addpath(genpath(fileparts(mfilename('fullpath'))));

% compile
mcc -mv -o fusion_v130 -R -singleCompThread -R -nodisplay -R -nojvm -d ./mcc/ fusion_Run.m

% done

