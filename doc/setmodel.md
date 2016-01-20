# The New Fusion
## Model Parameters
The New Fusion model uses a single config file to specify all model settings and parameters. Before you can run the model, you need to customize the config file for your project. This page briefly explains the function of each model parameter. The New Fusion model itself has not been published in scientific jounals yet. We will update the information once the model is published and you will have better understanding of these parameters. If you want to test the model now it is recommended to start with the default values.

#### The Config File
The config file looks like a MATLAB sript file (xxx.m), but it is actually read as a plain text file. You can find an example config file ([config.m](../config.m)) that comes with the New Fusion program. The easiest way to customize your own config file for your project is just to copy the example config file and edit your copy. You can either edit it in MATLAB or simply in any text editor. Here is what a config file would look like:

    % project information
        configVer = 10110;              % config file version, DO NOT CHANGE THIS!!
        modisPlatform = 'MOD';          % MOD for Terra, MYD for Aqua
        landsatScene = [227,65];        % Landsat path and row
        dataPath = '/projectnb/landsat/projects/fusion/amz_site/data/modis/';
                                        % data path
    % main settings
        BRDF = 0;                       % BRDF correction switch
        BIAS = 1;                       % bias correction switch
        discardRatio = 0;               % portion of Landsat pixel to be excluded on the edge
        diffMethod = 1;                 % method used in difference calculation, max(0) or mean(1)
        cloudThres = 80;                % A threshold on percent cloud cover for data filtering
        startDate = 2013001;            % start date of this analysis
        endDate = 2015001;              % end date of this analysis
        nrtDate = 2014001;              % start date of the near real time change detection
    % model parameters
        minNoB = 40;                    % minimun number of valid observation
        initNoB = 20;                   % number of observation or initialization
        nStandDev = 3;                  % number of standard deviation to flag a suspect
        nConsecutive = 6;               % number of consecutive observation to detect change
        nSuspect = 4;                   % number of suspect to confirm a change
        outlierRemove = 2;              % switch for outlier removing in initialization
        thresNonFstMean = 200;          % threshold of mean for non-forest detection
        thresNonFstStd = 200;           % threshold of std for non-forest detection
        thresNonFstSlp = 200;           % threshold of slope for non-forest detection
        thresNonFstR2 = 30;             % threshold of r2 for non-forest detection
        thresSpecEdge = 100;            % spectral threshold for edge detecting
        thresChgEdge = 0.65;            % threshold of detecting change edging pixel
        thresNonFstEdge = 0.35;         % threshold of detecting non-forest edging pixel
        thresProbChange = 8;            % threshold for n observation after change to confirm change
        bandIncluded = [7,8];           % bands to be included in change detection (band 7/8 are 250m)
        bandWeight = [1,1];             % weight on each band

#### Some Key Settings
The first two section of the config file tells the model some important information of your project such as the location of the data, some main settings and the type of output that you want. So it is very important that you make sure that the information is correct for your project. Here's a list of key settings and brief explanations:

    configVer = 10110;              % config file version, DO NOT CHANGE THIS!!
    modisPlatform = 'MOD';          % the MODIS satellite that you are using, MOD (Terra) or MYD (Aqua)
    landsatScene = [227,65];        % Landsat path and row (e.g. path 227 row 65)
    dataPath = '/projectnb/landsat/projects/fusion/amz_site/data/modis/';
                                    % the path of your work folder, absolute path.
    BRDF = 0;                       % do you want to apply BRDF correction (1 for yes, 0 for no)
    BIAS = 1;                       % do you want to apply BIAD correction (1 for yes, 0 for no)
    discardRatio = 0;               % portion of Landsat pixel to be excluded on the edge
    diffMethod = 1;                 % how to deal with overlap of adjacent MODIS swath observation, either use
                                      max (0) or mean (1)
    cloudThres = 80;                % threshold for filtering extremely cloudy data
    startDate = 2013001;            % start date of this analysis, data before this date will be discarded
    endDate = 2015001;              % end date of this analysis, data after this date will be discarded
    nrtDate = 2014001;              % start date of the near real time change detection

#### Model Parameters
The model parameters can influence the change detection part of the fusion process. Changing the model parameters will give you slightly different results. The default values are optimized for our test scene located in Para, Brazil (Landsat scene 227/65). It is recommended that you try different model parameters and see what works best for you study site. Here's a list of model parameters, the default values, and also brief explanation of what they control:

    minNoB = 40;            % minimun number of valid observation. 
    initNoB = 20;           % number of observations used for initialization, controls how many observations are
                              used to determine the initial state of the pixel.
    nStandDev = 3;          % n times standard deviation to flag a suspect, determines how sensitive the model is
                              when detecting changed observations.
    nConsecutive = 6;       % number of consecutive observations to check in change detection.
    nSuspect = 4;           % number of suspective obsercations to confirm a change, the model will need nSuspect
                              out of nConsecutive number of observations to confirm a change.
    outlierRemove = 2;      % how many outlier will be removed from the time series during each process.
    thresNonFstMean = 200;  % threshold of mean for detecting non-forest, controls how sensitive the model is 
                              when deciding whether a time series is non-forest (SR*10000).
    thresNonFstStd = 200;   % threshold of std for detecting non-forest, controls how sensitive the model is 
                              when deciding whether a time series is non-forest (SR*10000).
    thresNonFstSlope = 200; % threshold of slope for detecting non-forest, controls how sensitive the model is 
                              when deciding whether a time series is non-forest.
    thresNonFstR2 = 30;     % threshold of R2 for detecting non-forest, controls how sensitive the model is 
                              when deciding whether a time series is non-forest (R2*100, 0-100).
    thresSpecEdge = 100;    % threshold of mean for detecting pixel on the edge of two classes, controls how
                              sensitive the model is when detecting observations that might be on the edge
                              (SR*10000).
    thresChgEdge = 0.65;    % threshold of defining edge of change pixel (%).
    thresNonFstEdge = 0.35; % threshold of defining edge of non-forest pixel (%).
    thresProbChange = 8;    % number of observations after the change event to confirm change.
    bandIncluded = [7,8];   % bands to be included in change detection (band 1-6 are 500m, band 7/8 are 250m).
    bandWeight = [1,1];     % weight on each band (must have the same number of elements as bandIncluded), the
                              weight will be normalized, so [1,1,1] is the same as [2,2,2].

Note the unit we are using here is surface reflectance times 10000, some parameters need to be adjusted accordingly if you are using different unit.
