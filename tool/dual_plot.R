# dual_plot.R
# Version 1.0
# Tools
#
# Project: Fusion
# By Xiaojing Tang
# Created On: 3/12/2015
# Last Update: 3/15/2015
#
# Input Arguments: 
#   See specific function.
#   
# Output Arguments: 
#   See specific function.
#
# Instruction: 
#   1.Finish running fusion.
#   2.Use this script to generate dual plots.
#
# Version 1.0 - 12/01/2014
#   This script generates plot with CCDC and Fusion result.
#
# Released on Github on 3/15/2015, check Github Commits for updates afterwards.
#------------------------------------------------------------

# library and sourcing
library(R.matlab)
library(RCurl)
library(png)
library(sp)
library(raster)
library(rgdal)
script <- getURL('https://raw.githubusercontent.com/xjtang/rTools/master/source_all.R',ssl.verifypeer=F)
eval(parse(text=script),envir=.GlobalEnv)

#------------------------------------------------------------

# generates plot with CCDC and Fusion result
#
# Input Arguments: 
#   fPath (String) - path to fusion result
#   cPath (String) - path to ccdc result
#   output (String) - output location
#   pixel (Vector) - pixel location (x,y), can be multiple
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
dual_plot <- function(fPath,cPath,output,pixel){
  
  # find all landsat images
  fList <- list.files(path=fPath,pattern='.*.hdr',full.names=T,recursive=T)
  cList <- list.files(path=cPath,pattern='.*.hdr',full.names=T,recursive=T)
  
  # check if we have files found
  if(length(fList)<=0){
    cat('Can not find any .hdr file in fusion folder.\n')
    return(-1)
  }
  if(length(cList)<=0){
    cat('Can not find any .hdr file in ccdc folder.\n')
    return(-1)
  }
  
  # initialize result
  fusion <- array(-9999,c(length(fList),7,nrow(pixel)))
  ccdc <- array(-9999,c(length(cList),7,nrow(pixel)))
  
  # read fusion result
    # loop through fusion images
    for(i in 1:length(fList)){
      # forge image file name 
      img <- trimRight(fList[i],4)
      # remove .aux.xml file
      if(file.exists(paste(img,'.aux.xml',sep=''))){
        file.remove(paste(img,'.aux.xml',sep=''))
      }
      # read image
      mask <- raster::as.matrix(raster(imgFile,band=8))
      red <- raster::as.matrix(raster(imgFile,band=3))
      nir <- raster::as.matrix(raster(imgFile,band=4))
      swir <- raster::as.matrix(raster(imgFile,band=5))
      swir2 <- raster::as.matrix(raster(imgFile,band=6))
      
      # read pixels
      for(j in nrow(pixel)){
        
        
      }
      
    }
  
  # read ccdc result
    # loop through ccdc images
    for(i in 1:length(cList)){
      # forge image file name 
      img <- trimRight(cList[i],4)
      # remove .aux.xml file
      if(file.exists(paste(img,'.aux.xml',sep=''))){
        file.remove(paste(img,'.aux.xml',sep=''))
      }
      # read image
      
  
      # read pixels
      for(j in nrow(pixel)){
        
      }
  
  
    }
  
  
  
  
  # make plot
  
  
  
  # save result
  
  
  
  
  # done
  return(0)
  
}