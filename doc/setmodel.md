# The New Fusion
## Model Parameters
The New Fusion model uses a single config file to specify all model settings and parameters. Before you can run the model, you need to customize the config file for your project. This page briefly explains the function of each model parameter. The New Fusion model itself has not been published in scientific jounals yet. We will update the information once the model is published and you will have better understanding of these parameters. If you want to test the model now it is recommended to start with the default values.

#### The Config File


#### Some Key Settings


#### Model Parameters
The model parameters can influence the change detection part of the fusion process. Changing the model parameters will give you slightly different results. The default values are optimized for our test scene located in Para, Brazil (Landsat scene 227/65). It is recommended that you try different model parameters and see what works best for you study site. Here's a list of model parameters, the default values, and also brief explanation of what they control.

    minNoB = 10;            % minimun number of valid observations for a single pixel through out the time series
                              if a pixel have less than minNoB valid observation, then it will not be classified.
    initNoB = 8;            % number of observations used for initialization, controls how many observations are
                              used to determine the initial state of the pixel.
    nStandDev = 2.5;        % n times standard deviation to flag a suspect, determines how sensitive the model is
                              when detecting changed observations.
    nConsecutive = 6;       % number of consecutive observations to check in change detection.
    nSuspect = 4;           % number of suspective obsercations to confirm a change, the model will need nSuspect
                              out of nConsecutive number of observations to confirm a change.
    outlierRemove = 2;      % how many outlier will be removed from the time series during each process.
    thresNonFstMean = 350;  % threshold of mean for detecting non-forest, controls how sensitive the model is 
                              when deciding whether a time series is non-forest (SR*10000)
    thresNonFstStd = 150;   % threshold of std for detecting non-forest, controls how sensitive the model is 
                              when deciding whether a time series is non-forest (SR*10000)
    thresChgEdge = 0.35;    % threshold of defining edge of change pixel (%)
    thresNonFstEdge = 0.35; % threshold of defining edge of non-forest pixel (%)
    thresSpecEdge = 150;    % threshold of mean for detecting pixel on the edge of two classes, controls how
                              sensitive the model is when detecting observations that might be on the edge.
    thresProbChange = 8;    % number of observations after the change event to confirm change.
    bandIncluded = [4,5,6]; % bands to be included in change detection (band 1-6 are 500m, band 7/8 are 250m)
    bandWeight = [1,1,1];   % weight on each band (must have the same number of elements as bandIncluded), the
                              weight will be normalized, so [1,1,1] is the same as [2,2,2].

Note the unit we are using here is surface reflectance times 10000, some parameters need to be adjusted accordingly if you are using different unit.
