% readConfig.m
% Version 1.0
% Core
%
% Project: New Fusion
% By xjtang
% Created On: 1/11/2016
% Last Update: 1/11/2016
%
% Input Arguments:
%   file (String) - full path and file name to the config file
%
% Output Arguments: 
%   config (Structure) - a structure of all inputs from the config file
%
% Instruction: 
%   1.Call by other scripts with correct input and output arguments.
%
% Version 1.0 - 1/11/2016
%   Function to read config.m file as a text file.
%
% Released on Github on 1/11/2016, check Github Commits for updates afterwards.
%----------------------------------------------------------------

function config = readConfig(file)
    
    % initialize
    config = [];

    % check if file exist
    if ~exist(file,'file') 
        disp('Config file does not exist.');
        return;
    end

    % open file and read line by line
    Fconfig = fopen(file,'r');
    while ~feof(Fconfig)
        
        % read in one line without l/t spaces
        thisLine = strtrim(fgetl(Fconfig));
        
        % check this line
        if isempty(thisLine)
            continue;
        elseif strcmp(thisLine(1),'%')
            continue;
        end
            
        % parse this line
        [trueLine,~] = strtok(thisLine,'%;');
        [keyName,rem] = strtok(trueLine,'=');
        [keyString,~] = strtok(rem,'=');
        keyName = strtrim(keyName);
        keyString = strtrim(keyString);
        
        % parse keyString
        if strcmp(keyString(1),'''')
            % is string
            keyValue = strrep(keyString,'''','');
        elseif strcmp(keyString(1),'[')
            % is vector
            keyValue = str2num(keyString);
        else
            % is number 
            keyValue = str2double(keyString);
        end
        
        % assign this key
        config.(keyName) = keyValue;
        
    end
    fclose(Fconfig);
    
    % done

end