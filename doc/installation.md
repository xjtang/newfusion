# The New Fusion
## Installation
The installation of the New Fusion is quite easy. However you need to make sure you have the proper environment to run it.

#### Environment
The core of the New Fusion program is writen in [MATLAB](http://matlab.com) and works with just MATLAB alone. The standalone compiled version of fusion only requires MATLAB Compiler Runtime ([MCR](http://www.mathworks.com/products/compiler/mcr/)) and can be run without MATLAB. Part of the BRDF correction process is writen in [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) and uses [gdal](https://http://gdal.org/). Also [hdf](https://hdfeos.org/) support is needed if output of predicted MODIS swath in HDF format is needed. Some standalone tools are writen in [R](https://r-project.org/). 90% of the functions, especially the core functions, of the New Fusion model can be performed in MATLAB. Most users should have no problem using the New Fusion just in MATLAB. You will need [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) shell to submit multiple jobs to run fusion in parallel on a computing cluster.  

#### Install Fusion
There are several ways to install the New Fusion:  
1. Download the released [source code](https://github.com/xjtang/newfusion/releases) of the New Fusion program.  
2. Simply clone this [repository](https://github.com/xjtang/newfusion) using git.  

    git clone http://github.com/xjtang/newfusion.git
    
Then in MATLAB, add the New Fusion codes to your path to finish the installation process.    

#### Dependencies
**For the main functions:**  

    MATLAB: R2013a or higher 
    hdf: 4.2.5 or higher (only if you need HDF format output of the predicted swath)
    gdal: 1.10.0 or higher (only if you need BRDF correction)
    Bash: 4.1.2 or higher (for submitting jobs, also for BRDF correction)
    MCR: 8.1/2013a or higher (for running compiled version)

**For some minor tools**

    R: 2.15.2 or higher (also need the following packages)
        RCurl (1.95-4.3 or higher)
        R.matlab (3.1.1 or higher)
        png (0.1-7 or higher)
