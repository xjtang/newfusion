# dual_plot.R
# Version 1.0
# Tools
#
# Project: New Fusion
# By xjtang
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
  fusion <- array(-9999,c(length(fList),6,nrow(pixel)))
  ccdc <- array(-9999,c(length(cList),6,nrow(pixel)))
  
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
      mask <- raster::as.matrix(raster(img,band=8))
      red <- raster::as.matrix(raster(img,band=3))
      nir <- raster::as.matrix(raster(img,band=4))
      swir <- raster::as.matrix(raster(img,band=5))
      swir2 <- raster::as.matrix(raster(img,band=6))
      # read pixels
      for(j in nrow(pixel)){
        fusion[i,1,j] <- as.integer(strRight(trimRight(fList[i],15),7))
        fusion[i,2,j] <- red[pixel[j,1],pixel[j,2]]
        fusion[i,3,j] <- nir[pixel[j,1],pixel[j,2]]
        fusion[i,4,j] <- swir[pixel[j,1],pixel[j,2]]
        fusion[i,5,j] <- swir2[pixel[j,1],pixel[j,2]]
        fusion[i,6,j] <- mask[pixel[j,1],pixel[j,2]]
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
      mask <- raster::as.matrix(raster(img,band=8))
      red <- raster::as.matrix(raster(img,band=3))
      nir <- raster::as.matrix(raster(img,band=4))
      swir <- raster::as.matrix(raster(img,band=5))
      swir2 <- raster::as.matrix(raster(img,band=6))
      # read pixels
      for(j in nrow(pixel)){
        ccdc[i,1,j] <- as.integer(strRight(trimRight(fList[i],15),7))
        ccdc[i,2,j] <- red[pixel[j,1],pixel[j,2]]
        ccdc[i,3,j] <- nir[pixel[j,1],pixel[j,2]]
        ccdc[i,4,j] <- swir[pixel[j,1],pixel[j,2]]
        ccdc[i,5,j] <- swir2[pixel[j,1],pixel[j,2]]
        ccdc[i,6,j] <- mask[pixel[j,1],pixel[j,2]]
      }
    }
  
  # clean up
  rm(mask)
  rm(red)
  rm(nir)
  rm(swir)
  rm(swir2)
  gc()
  
  # make plot
  
  # save result
    # check if output folder exist
    if(!file.exists(output)){
      cat('Creating output directory.\n')
      dir.create(output)
    }
    # loop through individual pixels
    for(k in nrow(pixel)){
      # save fusion time series
      outFile <- paste(output,'FUS_',pixel[k,1],'_'pixel[k,2],'.csv',sep='')
      temp <- fusion[,,k]
      write.table(temp,outFile,append=F,sep=',',row.names=F,col.names=F)
      #save ccd tile series
      outFile <- paste(output,'CCDC_',pixel[k,1],'_'pixel[k,2],'.csv',sep='')
      temp <- ccdc[,,k]
      write.table(temp,outFile,append=F,sep=',',row.names=F,col.names=F)
    }
  
  # done
  return(0)
  
}