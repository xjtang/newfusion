# gen_preview.R
# Version 1.5
# Tools
#
# Project: New Fusion
# By xjtang
# Created On: 11/30/2014
# Last Update: 9/25/2015
#
# Input Arguments: 
#   See specific function.
#   
# Output Arguments: 
#   See specific function.
#
# Instruction: 
#   1.Generate SwathSub with fusion program.
#   2.Use this script to generate preview image.
#   3.NDVI grey scale image at 250 resolution.
#
# Version 1.0 - 12/01/2014
#   This script generates preview images for SwathSub.
#
# Updates of Version 1.1 - 12/05/2014
#   1.Added cloud mask feature.
#   2.Checks if input file exist before processing.
#   3.Append cloud percent into output file name.
#   4.Bugs fixed.
#   
# Updates of Version 1.2 - 12/13/2014
#   1.Make cloud and mask preview in one file.
#   2.Added gap between two images.
#   3.Added support for dealing with fill value
#
# Updates of Version 1.3 - 1/21/2015
#   1.Added support for 250m resolution.
#   2.Bugs fixed.
#   3.Updated comments.
#
# Updates of Version 1.4 - 4/7/2015
#   1.Adjusted for a major update in the main program.
#
# Updates of Version 1.5 - 9/25/2015
#   1.Adjusted for a major update in the main program.
#
# Released on Github on 11/30/2014, check Github Commits for updates afterwards.
#------------------------------------------------------------

# library and sourcing
library(R.matlab)
library(RCurl)
library(png)
script <- getURL('https://raw.githubusercontent.com/xjtang/rTools/master/source_all.R',ssl.verifypeer=F)
eval(parse(text=script),envir=.GlobalEnv)

#------------------------------------------------------------

# generate preview image based on SwathSub file
#
# Input Arguments: 
#   file (String) - input SwathSub .mat file
#   outFile (String) - output file with .png extension
#   subType (String) - the type of the input SwathSub ('SUB' or 'FUS')
#   res (Integer) - resolution of the image (250 or 500)
#   comp (Vector) - composite of the preview image (default 5,4,3)
#   stretch (Vector) - stretch of the image (default 0-5000)
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
gen_preview <- function(file,outFile,subType='SUB',res=500,
                        comp=c(5,4,3),stretch=c(0,5000)){
  
  # check subType
  if(subType=='SUB'){
    MOD <- 'MOD09'
  }else if(subType=='FUS'){
    MOD <- 'FUS09' 
  }else if(subType=='DIF'){
    MOD <- 'DIF09'
  }else{
    cat('Invalid subType.\n')
    return(-1)
  }
  
  # interpret the mat file
    # check if file exist
    if(!file.exists(file)){
      cat('Can not find input file.\n')
      return(-1)
    }
  
    # read the mat file
    MOD09SUB <- readMat(file)
  
    # grab dimension information
    line <- length(unlist(MOD09SUB[paste('MODLine',res,sep='')],use.names=F))
    samp <- length(unlist(MOD09SUB[paste('MODSamp',res,sep='')],use.names=F))
  
    # initiate surface reflectance array
    if(res==500){
      sr <- array(0,c(line,samp,7))
      sr2 <- array(0,c(line,samp,6))
    }else if(res==250){
      sr <- array(0,c(line,samp,4))
      sr2 <- array(0,c(line,samp,3))
      comp <- 8
    }else{
      cat('Invalid resolution.\n')
      return(-1)
    }
  
    # grab each band
    sr[,,1] <- matrix(unlist(MOD09SUB[paste('MOD09','RED',res,sep='')],use.names=F),line,samp)
    sr[,,2] <- matrix(unlist(MOD09SUB[paste('MOD09','NIR',res,sep='')],use.names=F),line,samp)
    sr[,,3] <- matrix(unlist(MOD09SUB[paste('QACloud',res,sep='')],use.names=F),line,samp)
    if(res==500){  
      sr[,,4] <- matrix(unlist(MOD09SUB[paste('MOD09','BLU',res,sep='')],use.names=F),line,samp)
      sr[,,5] <- matrix(unlist(MOD09SUB[paste('MOD09','GRE',res,sep='')],use.names=F),line,samp)
      sr[,,6] <- matrix(unlist(MOD09SUB[paste('MOD09','SWIR',res,sep='')],use.names=F),line,samp)
      sr[,,7] <- matrix(unlist(MOD09SUB[paste('MOD09','SWIR2',res,sep='')],use.names=F),line,samp)
    }else{
      # calculate ndvi
      sr[,,4] <- (sr[,,2]-sr[,,1])/(sr[,,2]+sr[,,1])
    }
  
    # read fus data if subType is FUS or BRDF
    sr2[,,1] <- matrix(unlist(MOD09SUB[paste(MOD,'RED',res,sep='')],use.names=F),line,samp)
    sr2[,,2] <- matrix(unlist(MOD09SUB[paste(MOD,'NIR',res,sep='')],use.names=F),line,samp)
    if(res==500){
      sr2[,,3] <- matrix(unlist(MOD09SUB[paste(MOD,'BLU',res,sep='')],use.names=F),line,samp)
      sr2[,,4] <- matrix(unlist(MOD09SUB[paste(MOD,'GRE',res,sep='')],use.names=F),line,samp)
      sr2[,,5] <- matrix(unlist(MOD09SUB[paste(MOD,'SWIR',res,sep='')],use.names=F),line,samp)
      sr2[,,6] <- matrix(unlist(MOD09SUB[paste(MOD,'SWIR2',res,sep='')],use.names=F),line,samp)
    }else{
      sr2[,,3] <- (sr2[,,2]-sr2[,,1])/(sr2[,,2]+sr2[,,1])
    }
  
  # forge preview image
    #initiate preview image
    if(res==500){imax<-3}else{imax<-1}
    preview <- array(0,c(line,samp*2+10,imax))
    sr1b <- c(4,5,1,2,6,7,7,4)
    sr2b <- c(3,4,1,2,5,6,6,3)
    # insert each band
    for(i in 1:imax){
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
#   subType (String) - the type of the input SwathSub ('SUB',or,'FUS')
#   plat (String) - platform ('MOD' or 'MYD')
#   res (Integer) - resolution of the image (250 or 500)
#   comp (Vector) - composite of the preview image (default 5,4,3)
#   stretch (Vector) - stretch of the image (default 0-5000)
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
batch_gen_preview <- function(path,output,subType='SUB',plat='MOD',res=500,
                              comp=c(5,4,3),stretch=c(0,5000)){
  
  # find all files
  pattern <- paste('.*',plat,'.*','ALL','*.mat',sep='')
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
    gen_preview(fileList[i],outFile,subType,res,comp,stretch)
    cat(paste(outFile,'...done\n'))
  }
  
  # done
  return(0)
  
}

#------------------------------------------------------------
