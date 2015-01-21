# result_preview.R
# Version 1.0
# Tools
#
# Project: Fusion
# By Xiaojing Tang
# Created On: 1/21/2015
# Last Update: 1/22/2015
#
# Input Arguments: 
#   See specific function.
#   
# Output Arguments: 
#   See specific function.
#
# Usage: 
#   1.Generate change result with fusion program.
#   2.Use this script to generate preview image of the result.
#   3.NDVI grey scale image at 250 resolution.
#
# Version 1.0 - 1/22/2015
#   This script generates preview of results from fusion.
#
# Released on Github on 1/22/2015, check Github Commits for updates afterwards.
#------------------------------------------------------------

# library and sourcing
library(R.matlab)
library(RCurl)
library(png)
script <- getURL('https://raw.githubusercontent.com/xjtang/rTools/master/source_all.R',ssl.verifypeer=F)
eval(parse(text=script),envir=.GlobalEnv)

#------------------------------------------------------------

# generate preview image of the result
#
# Input Arguments: 
#   file (String) - input change .mat file
#   outFile (String) - output file with .png extension
#   res (Integer) - resolution of the image (250 or 500)
#   comp (Vector) - composite of the preview image (default 5,4,3)
#   stretch (Vector) - stretch of the image (default 0-5000)
#   cband (Integer) - the band to show change and difference image (ndvi is 8)
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
result_preview <- function(file,outFile,res=500,
                        comp=c(5,4,3),stretch=c(0,5000),cband=8){
  
  # check if input file exist
  if(!file.exists(file)){
    cat('Can not find input file.\n')
    return(-1)
  }
  
  # read the mat file
  MOD09SUB <- readMat(file)
  
  # grab dimension information
  line <- length(unlist(MOD09SUB['MODLine'],use.names=F))
  samp <- length(unlist(MOD09SUB['MODSamp'],use.names=F))
  
  # initiate input data array
  if(res==500){
    CLD <- matrix(0,line,samp)
    MOD <- array(0,c(line,samp,6))
    FUS <- array(0,c(line,samp,6))
    DIF <- array(0,c(line,samp,1))
    CHG <- array(0,c(line,samp,1))
  }else if(res==250){
    CLD <- matrix(0,line,samp)
    MOD <- array(0,c(line,samp,3))
    FUS <- array(0,c(line,samp,3))
    DIF <- array(0,c(line,samp,1))
    CHG <- array(0,c(line,samp,1))
  }else{
    cat('Invalid resolution.\n')
    return(-1)
  }
  
  # initiate band sequance
  bsr <- c(3,4,1,2,5,6,6)
  bdc <- c('BLU','GRE','RED','NIR','SWIR','SWIR2','SWIR2','NDVI')
  
  # grab input data
    # grab cloud data
    CLD <- matrix(unlist(MOD09SUB['QACloud'],use.names=F),line,samp)
    # grab reflectance data
    MOD[,,1] <- matrix(unlist(MOD09SUB[paste('MOD09','RED',sep='')],use.names=F),line,samp)
    MOD[,,2] <- matrix(unlist(MOD09SUB[paste('MOD09','NIR',sep='')],use.names=F),line,samp)
    FUS[,,1] <- matrix(unlist(MOD09SUB[paste('FUS09','RED',sep='')],use.names=F),line,samp)
    FUS[,,2] <- matrix(unlist(MOD09SUB[paste('FUS09','NIR',sep='')],use.names=F),line,samp)
    if(res==500){  
      MOD[,,3] <- matrix(unlist(MOD09SUB[paste('MOD09','BLU',sep='')],use.names=F),line,samp)
      MOD[,,4] <- matrix(unlist(MOD09SUB[paste('MOD09','GRE',sep='')],use.names=F),line,samp)
      MOD[,,5] <- matrix(unlist(MOD09SUB[paste('MOD09','SWIR',sep='')],use.names=F),line,samp)
      MOD[,,6] <- matrix(unlist(MOD09SUB[paste('MOD09','SWIR2',sep='')],use.names=F),line,samp)
      FUS[,,3] <- matrix(unlist(MOD09SUB[paste('FUS09','BLU',sep='')],use.names=F),line,samp)
      FUS[,,4] <- matrix(unlist(MOD09SUB[paste('FUS09','GRE',sep='')],use.names=F),line,samp)
      FUS[,,5] <- matrix(unlist(MOD09SUB[paste('FUS09','SWIR',sep='')],use.names=F),line,samp)
      FUS[,,6] <- matrix(unlist(MOD09SUB[paste('FUS09','SWIR2',sep='')],use.names=F),line,samp)
    }else{
      MOD[,,3] <- matrix(unlist(MOD09SUB[paste('MOD09','NDVI',sep='')],use.names=F),line,samp)
      FUS[,,3] <- matrix(unlist(MOD09SUB[paste('FUS09','NDVI',sep='')],use.names=F),line,samp)
    }
    # grab change and dif data
    DIF <- matrix(unlist(MOD09SUB[paste('DIF09',bdc[cband],sep='')],use.names=F),line,samp)
    CHG <- matrix(unlist(MOD09SUB[paste('CHG09',bdc[cband],sep='')],use.names=F),line,samp)
  
  # forge preview image
    # initiate preview image
    preview <- array(0,c(line*2+10,samp*2+10,3))
    # insert each band
    for(i in 1:3){
      # grab band
      band <- cbind(sr2[,,sr2b[comp[i]]],matrix(0,line,10),sr[,,sr1b[comp[i]]])
      # fix na
      band[is.na(band)] <- 0
      # fix fill value (treat as saturation)
      band[band==(-28672)] <- stretch[2]
      # fix extreme value
      band[band>stretch[2]] <- stretch[2]
      band[band<stretch[1]] <- stretch[1]
      # stretch the band
      band <- ((band-stretch[1])/(stretch[2]-stretch[1]))*(band!=0)
      # apply no data area
      band[cbind(matrix(1,line,samp+10),band[,1:samp])==0]<-0
      # apply cloud mask
      band[cbind(matrix(0,line,samp+10),sr[,,3])==1]<-1
      # assign image
      preview[,,i] <- band
    }
    rm(band)
  
  # generate image
    # remove the trailing .png extension from output file name
    if(strRight(outFile,4)=='.png'){outFile<-trimRight(outFile,4)}
    # calculate cloud cover percent
    cc <- floor(sum(sr[,,3])/(line*samp)*100)
    # forge output file name
    outFile <- paste(outFile,'_',cc,'C.png',sep='')
    # write output
    writePNG(preview,outFile)
  
  # done
  return(0)
  
}

#------------------------------------------------------------

# batch generate preview of all mat files in a folder
#
# Input Arguments: 
#   path (String) - path to all input files
#   output (String) - output location
#   plat (String) - platform ('MOD' or 'MYD')
#   res (Integer) - resolution of the image (250 or 500)
#   comp (Vector) - composite of the preview image (default 5,4,3)
#   stretch (Vector) - stretch of the image (default 0-5000)
#   cband (Integer) - the band to show change and difference image (ndvi is 8)
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
batch_gen_preview <- function(path,output,plat='MOD',res=500,
                              comp=c(5,4,3),stretch=c(0,5000)){
  
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
    outFile <- paste(output,'/PREV_',plat,subType,'_',res,'m_',date,'_',time,'.png',sep='')
    gen_preview(fileList[i],outFile,subType,plat,res,comp,stretch)
    cat(paste(outFile,'...done\n'))
  }
  
  # done
  return(0)
  
}

#------------------------------------------------------------