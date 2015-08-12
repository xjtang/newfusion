# The New Fusion
## Installation
The installation ofthe New Fusion is quite easy. However you need to make sure you have the proper environment to run it.

#### Environment
The core of the New Fusion program is writen in [MATLAB](http://matlab.com) and works with just MATLAB alone. Part of the BRDF correction process is writen in [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) and uses [gdal](https://http://gdal.org/). And [hdf](https://hdfeos.org/) support is needed if output of predicted MODIS swath in HDF format is needed. Also some stand-along tools are writen in [R](https://r-project.org/). 90% of the functions, especially the core functions, of the New Fusion model can be performed in MATLAB. Most users should have no problem using the New Fusion just in MATLAB.  

#### Install Fusion
There are several ways to install the New Fusion:  
1. Download the released [source code](https://github.com/xjtang/newfusion/releases) of the New Fusion program.  
2. Simply clone this [repository](https://github.com/xjtang/newfusion) using git.  

    git clone http://github.com/xjtang/newfusion.git
    
Then in MATLAB, add the New Fusion codes to your path to finish the installation process.    

#### Dependencies
**For the main functions:**  

    MATLAB: R2013a or higher (change detection uses the Statistics Toolbox)  
    hdf: 4.2.5 or higher (only if you need HDF format output of the predicted swath)
    
**For the BRDF correction process**  

    gdal: 1.10.0 or higher
    Bash: 4.1.2 or higher (Bash is also needed for batch running on cluster)

**For some minor tools**

    R: 2.15.2 or higher (also need the following packages)
        RCurl (1.95-4.3 or higher)
        R.matlab (3.1.1 or higher)
        png (0.1-7 or higher)
