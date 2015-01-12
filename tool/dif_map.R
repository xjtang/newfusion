# dif_map.R
# Version 1.2
# Tools
#
# Project: Fusion
# By Xiaojing Tang
# Created On: 12/20/2014
# Last Update: 1/3/2015
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
# Updates of Version 1.1 - 12/31/2014
#   1.Added support for 250m resolution.
#   2.Bugs fixed.
#
# Updates of Version 1.2 - 1/3/2015
#   1.display possitive and negative pixels in different color
#   2.display outliers in green
#   3.Added a quantile for streching the image
#   4.Added support for a fixed streching value
#   5.Bugs fixed
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
#   plat (String) - platform ('MOD' or 'MYD')
#   res (Integer) - resolution of the image (250 or 500)
#   cmask (Logical) - apply cloud mask or not
#   q (Single) - quantile for determine the max value in stretching the image
#   fix (Vector) - fixed value for streching each band (0 means na)
#   bias (Logical) - fix the bias or not
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
dif_map <- function(file,outFile,fusType='FUS',plat='MOD',
                    res=500,cmask=T,q=0.95,fix=c(0,0,0,0),bias=T){
  
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
  if(res==500){
    sr <- array(0,c(line,samp,9))
    imax <- 4
  }else if(res==250){
    sr <- array(0,c(line,samp,7))
    imax <- 3
  }else{
    cat('Invalid resolution.\n')
    return(-1)
  }
  
  # grab each band
  sr[,,1] <- matrix(unlist(MOD09SUB[paste('MOD09','RED',sep='')],use.names=F),line,samp)
  sr[,,3] <- matrix(unlist(MOD09SUB[paste('MOD09','NIR',sep='')],use.names=F),line,samp)
  sr[,,2] <- matrix(unlist(MOD09SUB[paste(FUS,'RED',sep='')],use.names=F),line,samp)
  sr[,,4] <- matrix(unlist(MOD09SUB[paste(FUS,'NIR',sep='')],use.names=F),line,samp)
  sr[,,7] <- matrix(unlist(MOD09SUB['QACloud'],use.names=F),line,samp)
  sr[,,5] <- (sr[,,3]-sr[,,1])/(sr[,,3]+sr[,,1])
  sr[,,6] <- (sr[,,4]-sr[,,2])/(sr[,,4]+sr[,,2])
  if(res==500){
    sr[,,8] <- matrix(unlist(MOD09SUB[paste('MOD09','SWIR',sep='')],use.names=F),line,samp)
    sr[,,9] <- matrix(unlist(MOD09SUB[paste(FUS,'SWIR',sep='')],use.names=F),line,samp)
  }
  
  # set na to -9999
  # sr[is.na(sr)] <- -9999
  
  # fix bias
  if(bias){
    bseq <- c(1,3,5,8)
    for(i in bseq[1:imax]){
      observe <- sr[,,i]
      predict <- sr[,,i+1]
      b <- mean(observe[sr[,,7]==0],na.rm=T)-mean(predict[sr[,,7]==0],na.rm=T)
      sr[,,i] <- sr[,,i] - b
    }
  }
  rm(observe)
  rm(predict)
  rm(b)
  
  # initialize dif bands
  dif <- array(0,c(line,samp,imax))
  
  # calculate dif
  dif[,,1] <- sr[,,1] - sr[,,2]
  dif[,,2] <- sr[,,3] - sr[,,4]
  dif[,,3] <- sr[,,5] - sr[,,6]
  if(res==500){
    dif[,,4] <- sr[,,8] - sr[,,9]
  }
  
  # forge preview image
  # initiate preview image
  preview <- array(0,c(line,samp*4+30,3))
  if(cmask){
    preview[,,2] <- cbind(sr[,,7],matrix(0,line,10),sr[,,7],matrix(0,line,10),sr[,,7],matrix(0,line,10),sr[,,7])
  }
  if(res==250){preview[,(samp*3+31):(samp*4+30),2]<-0}
  # insert each band
  for(i in 1:imax){
    # initialize extreme band
    extm <- matrix(0,line,samp)
    for(j in c(1,3)){
      # grab band
      band <- dif[,,i]
      # fix na
      band[is.na(band)] <- 0 
      # apply cloud mask
      if(cmask){
        band[sr[,,7]==1] <- 0
      }
      if(j==1){
        band[band<0] <- 0
      }else{
        band[band>0] <- 0
        band <- abs(band)
      }
      # stretch the band
      if(fix[i]==0){
        band <- band/(quantile(band,q,na.rm=T))
      }else{
        band <- band/fix[i]
      }
      # pick out extreme values
      extm[band>1] <- 1
      # fix extreme value
      band[band>1] <- 0   
      # add cloud mask
      if(cmask){
        band[sr[,,7]==1] <- 1 
        extm[sr[,,7]==1] <- 1 
      }
      # assign masked image
      preview[,((samp+10)*(i-1)+1):(samp*i+10*(i-1)),j] <- band
    }
    #assign extreme value to image
    preview[,((samp+10)*(i-1)+1):(samp*i+10*(i-1)),2] <- extm
  }
  rm(band)
  rm(extm)

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
  cc <- floor(sum(sr[,,7])/(line*samp)*100)
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
#   output (String) - output location
#   fusType (String) - the type of the fusion result ('FUS', or 'BRDF')
#   plat (String) - platform ('MOD' or 'MYD')
#   res (Integer) - resolution of the image (250 or 500).
#   cmask (Logical) - apply cloud mask or not
#   q (Single) - quantile for determine the max value in stretching the image
#   fix (Vector) - fixed values for streching each band (0 means na)
#   bias (Logical) - fix the bias or not
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
batch_dif_map <- function(path,output,plat='MOD',res=500,fusType='FUS',
                          cmask=T,q=0.95,fix=c(0,0,0,0),bias=T){
  
  # find all files
  pattern <- paste('.*',plat,'.*',res,'m.*.mat',sep='')
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
    outFile <- paste(output,'/DIF_',plat,fusType,'_',res,'m_',date,'_',time,'.png',sep='')
    dif_map(fileList[i],outFile,fusType,plat,res,cmask,q,fix,bias)
    cat(paste(outFile,'...done\n'))
   }
  
  # done
  return(0)
  
}

#------------------------------------------------------------
