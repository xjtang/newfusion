Versions and Updates
==============

New Fusion  
--------------
Version 1.3.2 - 2/4/2016
--------------
- Export single class maps for all three major classe.  
- Improve outlier removal process in change detection.  
- SwathSub will check the cloud folder for existing file.  
- Cloud process will recheck files in SUBCLD folder.  
- Converted BRDF correction into a standalone separate process.  
- Removed all system commands in main scrips.  
- Improved false break removal process.  
- Added a tool to reproject results to MODIS grid.  
- Config file checks are moved from core script to inputs script.  
- Converted uncommonly changed parameters into internal model parameters.  
- Bugs fixed.  

Version 1.3.1 - 1/30/2016
--------------
- Changed job time limit to 24 hours.  
- Added new bash script to clear results.   
- Added min NoB control on linear model check.  
- Embeded the assign class part to fusion_Change.  
- Updated config file and config file version.  
- Updated documentation.  
- Bugs fixed  
- Recompiled

Version 1.3 - 1/21/2016
--------------
- Added change detection threshold on RMSE.  
- No point swath is recorded to be excluded in future runs.  
- Improved output file handeling.  
- Improved model efficiency.  
- Added new core script to fit simple linear model.  
- Added new core script to read the config file in text format.  
- Added a wrap-up function to run fusion steps with one command.  
- Made a few changes to the model to support for a compiled version.  
- Added new function to compile the model.  
- Compiled the model as a standalone program.  
- Added new bash script to run the compiled version.  
- Added options to the bash script for running standalone and request memory.  
- Added separate option for requesting extra memory and slots.  
- Consolidate output log.  
- Updated the tune_model tool.  
- Updated documentation.  
- Bugs fixed.  

Version 1.2.6 - 12/28/2015
--------------
- Combining data from Aqua and Terra to produce better results.  
- All steps before change detection now process data from both platform by default.  
- Platform information recorded in cache file.  
- Optimized the cript for submiting jobs.  
- Improved ploting function in tune_model.  
- Some tools updated and tested.  
- Bugs fixed.  
- Updated documentation.  
- Adjusted default values.  

Version 1.2.5 - 11/16/2015
--------------
- Redesigned the change detection model.  
- Implemented model constants.  
- Added a study time period control system.  
- Updated the tune_model tool.  
- Parameterized fusion time series and classification class codes.  
- Expanded collection of coefficients.  
- Added a linear model for classifying fusion time series segments.  
- Implement large area multiple Landsat scenes processing.  
- Bugs fixed.  

Version 1.2.4 - 9/25/2015
--------------
- Added version control for the config file.  
- Adjusted default values.  
- Removed useless tools.  
- Updates some old tools.  
- Removed usedless bash script.  
- Added overall mean and std to coef maps.  
- Tools are tested.  
- Bugs fixed.  

Version 1.2.3 - 9/17/2015
--------------
- Updated readme and comments.  
- Adjusted default values.  
- Improved cloudy data filtering code.  
- Added water body detecting.  
- Improved the way the model checks whether result already exist.  
- Improved the map generating process.  
- Updated the tune_model tool.  
- Improved memory handeling.  
- Date list for generating synthetic image is automatically generated.  
- Added a component to generate coefficients maps as part of the result.  
- Bugs fixed.  

Version 1.2.2 - 8/30/2015
--------------
- Updated readme.  
- Adjusted default values of parameters.  
- Filtering cloudy data is a main function now.  
- Adjusted the change detection model.  

Version 1.2.1 - 8/18/2015
--------------
- Added gitignore.  
- Added documentation on how to run the model.  
- Improved the change detection model.  
- Updated readme.  
- Fixed bugs.  

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
