Versions and Updates
==============

New Fusion  
--------------
Version 1.2.1 - 8/4/2015
--------------
- Added gitignore.  
- Trying to update the documentation.  
- Improved the change detection model.  

Version 1.2 - 8/3/2015  
--------------
- Optimized the outlier removing process in initialization in change detection.  
- Threshold for edge finding are percentized.  
- Added a new tool to examine change detection process of individual pixel.  
- Added a post-break checking mechanism to eliminate false break.  
- Added a outlier removing process for post-break check.  
- Added a new tool to help tune the model parameters. 
- Adjusted default config values.  
- Bugs fixed.  
  
Version 1.1 - 7/20/2015  
--------------
- Added a new mechanism for false break non-forest check.  
- Added a new parameter for probable change detecting.  
- Added a spectral threshold for edge detecting.  
- Bugs fixed.  
  
Version 1.0 - 7/14/2015  
--------------
- Change project name to the New Fusion (version 1.0).  
- Bugs fixed.  
- Added new core function for change detection.  
- Added new fusion function to cache fusion time series.  
- Adjusted data structure.  
- Added support for multiple Landsat scene senario.  
- Updated readme.  
- Added new fusion function for change detection.  
- Implemented a config file that can be customized for each project.  
- All main function tested.  
- Added new fusion function to generate change map.  

Fusion  
--------------
Version 6.4 - 4/7/2015
--------------
- Bugs fixed.  
- Combined 250m and 500m fusion.  
- Removed a unused feature that could cause license problem.  
- Updated tools for combining 250m and 500m fusion.  
- Remove two old tools that is no longer usable.  

Version 6.3.1 - 3/24/2015 
--------------
- Bugs fixed.  
- Added a new tool to check cheksums of downloaded files.  
- modified bash functon to include job index in job name.  
- MOD09GA and MCD43A1 are no longer required.  

Version 6.3 - 2/10/2015
--------------
- Bugs fixed.
- Improved performance.
- Added new core function to reproject Swath to ETM.
- Improved input and output data structure.
- Added new fusion function to generate dif and change image.
- Added new fusion function to reproject dif to ETM scale.
- Added external function to write output to ETM image.
- Modified bash function so each step can be run separately.

Version 6.2.2 - 1/5/2015
--------------
- Bugs fixed.  
- Added new tool for generating difference images.  
- Added support for 250m resolution in all tools.  

Version 6.2.1 - 12/08/2014
--------------
- Updated comments in all script files.
- Bugs fixed.
- Created log for updates in all versions.
- Added new tool for generateing cloud stats.  
- Added new tool for generating cloud plots.  
- Added new tool for generating preview image.
- Added new tool for generating fusion plots.  
- Added a DUMP folder for collecting trash.  
- Added support for synthetic image with nodata value (-9999).  

Version 6.2 - 11/24/2014
--------------
- Added support for BRDF correction.
- Added support for 250m fusion.
- Added support for MODIS Aqua.
- Bugs fixed.
- Updated comments.

Version 6.1.2 - 11/4/2014
------------
- Added new tool for downloading MODIS swath data.
- Bugs fixed.
- Updated comments

Version 6.1.1 - 10/21/2014
------------
- Added support for submitting multiple shell jobs for the fusion process.
- Bugs fixed.
- Updated comments

Version 6.1 - 10/15/2014
-------------
- Implemented new data structure.
- Implemented the main input structure.
- Implemented new work flow.
- Changed coding style.
- Updated comments.
- Bugs fixed.
- Released on Github.
- remastered and operational.

Version 6.0 - Unknown (by Q. Xin)
--------------
- Operational version of the original fusion project.
