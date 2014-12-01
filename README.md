Fusion 
======

Ver. 6.2.1 (Beta)  

Near Real-Time Monitoring of Land Cover Disturbance by Fusion of MODIS and Landsat Data

About
------

The fusion tool is a set of functions written in MATLAB for combining remote sensing images from MODIS and Landsat to detect land cover change in near real time (see Xin et al., 2013 for more details on fusion). The core of the fusion tool is to predict MODIS swath observations based on synthetic Landsat ETM image from the CCDC model (see Zhu & Woodcock, 2014 for more details on CCDC). 

The fusion tool is originally developed by Qinchuan Xin at Boston University (version 1-6). I modified the the fusion ver. 6 after I took over the project in May, 2014. The new fusion ver. 6.1 (and higher) in this repo. is designed to fit the new work flow and data structure. See comments in each script for the specific changes that I made to the original fusion tool.

The current fusion tool supports MODIS Terra/Aqua in 500/250m resolution with the option of BRDF correction. A brand new fusion tool in open source language is under development. I expect it to be released soon. (follow xjtang/openfusion). The new open source fusion will be based on fusion ver. 6.1 and higher.

Content
------

**Main Scripts:**  

fusion_Inputs - Intilize the main input structure for other processes  
fusion_BRDF - Generate BRDF correction coefficients  
fusion_SwathSub - Create subset of the MODIS swath based on geolocation of Landsat images  
fusion_Fusion - The main fusion process  
fusion_FusionBRDF - The main fusion process with BRDF correction  
fusion_WriteHDF - Write the final outputs to new HDF files  

**Supplimental Scripts:**  

core - some key functions that will be used by the main scripts  
ext - some external functions written by other authors  
bash - bash scripts for running fusion in qshell  
tool - some small tools for pre- / post- fusion analysis


Data
------

**Required:**  

MOD09 - MODIS Terra Surface Reflectance 5m L2 Swath  
MOD09GA - MODIS Terra Surface Reflectance Daily L2G 500m and 1km Gridded Data  
MCD43A1 - MODIS BRDF/Albedo Model Parameters Product  
MOD09ETM - Synthetic Landsat ETM image   

**Optional:**  

MOD09GQ - MODIS Terra Surface Reflectance Daily L2G 250m Gridded Data  
MOD03 - MODIS Geolocation Data Set

Instruction
------

**Preparing**  

- Download required input data and allocate enough disk space for output
- Organize all input data in one folder with original folders and file names (such as MOD09, MOD09GA)
- Clone (or pull) the fusion repo. to your server or local computer

**To run fusion step by step**  

- Launch MATALB
- Initialize the main input structure by running fusion_Inputs.m with correct inputs
- Run each step of the fusion process one by one (use the structure generated by fusion_Inputs.m as input).

**To run fusion in shell**  

- Get in Bash
- Use fusion_Batch.sh to submit jobs to run fusion

See the comments in each script for detailed instructions including description of input and output arguments. A complete fusion process follows these steps: Inputs -> BRDF -> SwathSub -> Fusion/FusionBRDF -> WriteHDF

Requirements
------

**For main functions:**    
MATLAB (r2011b or higher)  
gdal (1.10.0 or higher)  
hdf (4.2.5 or higher)  
bash (4.1.2 or higher)  

**For some minor fucstions:**  
R (2.15.2 or higher)  
RCurl Package (1.95-4.3 or higher)  
R.matlab Package (3.1.1 or higher)  
png (0.1-7 or higher)  

Publications
------

Xin, Q., Olofsson, P., Zhu, Z., Tan, B., & Woodcock, C. E. (2013). Toward near real-time monitoring of forest disturbance by fusion of MODIS and Landsat data. Remote Sensing of Environment, 135, 234-247.  

Zhu, Z., & Woodcock, C. E. (2014). Continuous change detection and classification of land cover using all available Landsat data. Remote Sensing of Environment, 144, 152-171.

