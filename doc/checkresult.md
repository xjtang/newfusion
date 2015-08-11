# The New Fusion
## Check Result
The New Fusion model stores all intermediate data and outputs of each step in the main work folder that you specified. Some outputs will be in MATLAB format (.m) while some are in remote sensing image formats (e.g. hdf, envi). If you actually understand how the model works you are free to check out those files. For normal uers and applications, there are two outputs that need to pay attention with, which is the Fusion time series and the change maps. The output from some tools may also be quite useful for some studies. Here is some examples of how to examine the output of the New Fusion model using our test site.

#### Fusion Time Series
One ofthe byproduct that the New Fusion model creates is a Fusion time series. It is basically a time series of the residual of our predicted data and observer data. It is stores in the same format as a Landsat time series. The fusion time series are stored in two different formats:
In standard ENVI format:

    /workfolder/PxxxRxxx/ETMDIF/

In MATLAB format:

    /workfolder/PxxxRxxx/CACHE/

You can certainly open individual fusion time series images in ENVI. Here we recommend two other ways to visualize the Fusion time series in a more intuitive way.

##### 1. TSTools QGIS Plugin

The first way to visualize the Fusion time series is to use the [TSTools](https://github.com/ceholden/TSTools) developed by [Christ Holden](http://ceholden.github.io/). TSTools is a nice open source [QGIS](http://www.qgis.org/en/site/) plugin that is designed to visualize Landsat time series. Please check out the [QGIS website](http://www.qgis.org/en/site/) for installation of QGIS and the [Github page of TSTools](https://github.com/ceholden/TSTools) for documentation of TSTools. Here's an example of using TSTools to visualize the Fusion time series:

You are able to examine individual images, overlay with real Landsat images, and also plot the Fusion time series of individual pixel that you selected.

##### 2. Built-in Tools of the New Fusion

The second way 

#### Change Map


#### Output from tools
