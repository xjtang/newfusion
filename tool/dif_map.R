# dif_map.R
# Version 1.0
# Tools
#
# Project: Fusion
# By Xiaojing Tang
# Created On: 12/20/2014
# Last Update: 12/21/2014
#
# Input Arguments: 
#   See specific function.
#   
# Output Arguments: 
#   See specific function.
#
# Usage: 
#   1.Generate fusion results with fusion program.
#   2.Use this script to generate difference map.
#
# Version 1.0 - 12/21/2014
#   This script generates difference maps for fusion results.
#
# Released on Github on 12/21/2014, check Github Commits for updates afterwards.
#------------------------------------------------------------

# library and sourcing
library(R.matlab)
library(RCurl)
library(png)
script <- getURL('https://raw.githubusercontent.com/xjtang/rTools/master/source_all.R',ssl.verifypeer=F)
eval(parse(text=script),envir=.GlobalEnv)

#------------------------------------------------------------

# generate difference map for the fusion results
#
# Input Arguments: 
#   file (String) - input fusion result .mat file
#   outFile (String) - output file with .png extension
#   fusType (String) - the type of the fusion result ('FUS', or 'BRDF')
#   cmask (Logical) - apply cloud mask or not
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
dif_map <- function(file,outFile,fusType='FUS',cmask=T){
  
  # check fusType
  if(fusType=='FUS'){
    FUS <- 'FUS09' 
  }else if(fusType=='BRDF'){
    FUS <- 'FUSB9' 
  }else{
    cat('Invalid fusType.\n')
    return(-1)
  }
  
  # check if file exist
  if(!file.exists(file)){
    cat('Can not find input file.\n')
    return(-1)
  }
  
  # check platform
  plat <- strLeft(gsub('.*(M.*D09SUB).*','\\1',file),3)
  if(plat=='MOD'){
    MODIS <- 'Terra' 
  }else if(plat=='MYD'){
    MODIS <-'Aqua' 
  }else{
    cat('Can not figure our the platform.\n')
    return(-1)
  }
  
  # read the mat file
  MOD09SUB <- readMat(file)
  
  # grab dimension information
  line <- length(unlist(MOD09SUB['MODLine'],use.names=F))
  samp <- length(unlist(MOD09SUB['MODSamp'],use.names=F))
  
  # initiate surface reflectance array
  sr <- array(0,c(line,samp,9))
  ndvi <- array(0,c(line,samp,2))
  
  # grab each band
  sr[,,1] <- matrix(unlist(MOD09SUB[paste('MOD09','RED',sep='')],use.names=F),line,samp)
  sr[,,2] <- matrix(unlist(MOD09SUB[paste('MOD09','NIR',sep='')],use.names=F),line,samp)
  sr[,,3] <- matrix(unlist(MOD09SUB[paste('MOD09','SWIR',sep='')],use.names=F),line,samp)
  sr[,,5] <- matrix(unlist(MOD09SUB[paste(FUS,'RED',sep='')],use.names=F),line,samp)
  sr[,,6] <- matrix(unlist(MOD09SUB[paste(FUS,'NIR',sep='')],use.names=F),line,samp)
  sr[,,7] <- matrix(unlist(MOD09SUB[paste(FUS,'SWIR',sep='')],use.names=F),line,samp)
  sr[,,9] <- matrix(unlist(MOD09SUB['QACloud'],use.names=F),line,samp)
  sr[,,4] <- (sr[,,2]-sr[,,1])/(sr[,,2]+sr[,,1])
  sr[,,8] <- (sr[,,5]-sr[,,4])/(sr[,,5]+sr[,,4])
  
  # set na to -9999
  # sr[is.na(sr)] <- -9999
  
  # initialize dif bands
  dif <- array(0,c(line,samp,4))
  
  # calculate dif
  for(i in 1:4){
    dif[,,i] <- abs(sr[,,i] - sr[,,i+4])
  }
  
  # forge preview image
  # initiate preview image
  preview <- array(0,c(line,samp*4+30,3))
  if(cmask){
    preview[,,2] <- cbind(sr[,,9],matrix(0,line,10),sr[,,9],matrix(0,line,10),sr[,,9],matrix(0,line,10),sr[,,9])
    preview[,,3] <- preview[,,2]
  }
  # insert each band
  for(i in 1:4){
    # grab band
    band <- dif[,,i]
    band[sr[,,9]==1] <- NaN
    # stretch the band
    band <- ((band-min(band,na.rm=T))/(max(band,na.rm=T)-min(band,na.rm=T)))
    # fix na
    band[is.na(band)] <- 0
    #add cloud mask
    if(cmask){
      band[sr[,,9]==1] <- 1 
    }
    # assign masked image
    preview[,((samp+10)*(i-1)+1):(samp*i+10*(i-1)),1] <- band
  }
  rm(band)
  
  # finalize preview 
  preview2 <- array(0,c(2*line+10,2*samp+10,3))
  for(i in 1:3){
    preview2[,,i] <- rbind(preview[,1:(samp*2+10),i],matrix(0,10,samp*2+10),preview[,(samp*2+21):(samp*4+30),i])
  }
  rm(preview)
  
  # generate image
  # remove the trailing .png extension from output file name
  if(strRight(outFile,4)=='.png'){outFile<-trimRight(outFile,4)}
  # calculate cloud cover percent
  cc <- floor(sum(sr[,,9])/(line*samp)*100)
  # forge output file name
  outFile <- paste(outFile,'_',cc,'C.png',sep='')
  # write output
  writePNG(preview2,outFile)
  
  # done
  return(0)
  
}

#------------------------------------------------------------

# batch generate difference map of all mat files in a folder
#
# Input Arguments: 
#   path (String) - path to all input files
#   pattern (String) pattern to search for file
#   output (String) - output location
#   fusType (String) - the type of the fusion result ('FUS', or 'BRDF')
#   cmask (Logical) - apply cloud mask or not
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
batch_dif_map <- function(path,output,pattern='MOD09SUB.*500m.*',
                              fusType='FUS',cmask=T){
  
  # find all files
  pattern <- paste(pattern,'.*.mat',sep='')
  fileList <- list.files(path=path,pattern=pattern,full.names=T,recursive=T)
  
  # check if we have files found
  if(length(fileList)<=0){
    cat('Can not find any .mat file.\n')
    return(-1)
  }
  
  # check output
  if(!file.exists(output)){
    cat('Creating output directory.\n')
    dir.create(output)
  }
  
  # loop through all files
  for(i in 1:length(fileList)){
    date <- gsub('.*(\\d\\d\\d\\d\\d\\d\\d).*','\\1',fileList[i])
    time <- gsub('.*(\\d\\d\\d\\d).*','\\1',fileList[i])
    outFile <- paste(output,fusType,'_',date,'_',time,'_dif.png',sep='')
    dif_map(fileList[i],outFile,fusType,cmask)
    cat(paste(outFile,'...done\n'))
  }
  
  # done
  return(0)
  
}

#------------------------------------------------------------
