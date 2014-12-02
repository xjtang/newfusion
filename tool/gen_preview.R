# gen_preview.R
# Version 1.1
# Tools
#
# Project: Fusion
# By Xiaojing Tang
# Created On: 11/30/2014
# Last Update: 12/02/2014
#
# Input Arguments: 
#   See specific function.
#   
# Output Arguments: 
#   See specific function.
#
# Usage: 
#   1.Generate SwathSub with fusion program.
#   2.Use this script to generate preview image.
#
# Version 1.0 - 12/01/2014
#   This script generates preview images for SwathSub.
#
# Updates of Version 1.1 - 12/02/2014
#   1.Added cloud mask feature.
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
#   subType (String) - the type of the input SwathSub ('SUB','FUS', or 'BRDF')
#   comp (Vector) - composite of the preview image (default 4,3,2)
#   stretch (Vector) - stretch of the image (default 0-3000)
#   cmask (Logical) - apply cloud mask or not
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
gen_preview <- function(file,outFile,subType='SUB',
                        comp=c(5,4,3),stretch=c(0,5000),cmask=F){
  
  # check subType
  if(subType=='SUB'){
    MOD <- 'MOD09'
  }else if(subType=='FUS'){
    MOD <- 'FUS09' 
  }else if(subType=='BRDF'){
    MOD <- 'FUSB9' 
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
    line <- length(unlist(MOD09SUB['MODLine'],use.names=F))
    samp <- length(unlist(MOD09SUB['MODSamp'],use.names=F))
    # initiate surface reflectance array
    sr <- array(0,c(line,samp,7))
    # grab each band
    sr[,,1] <- matrix(unlist(MOD09SUB[paste(MOD,'BLU',sep='')],use.names=F),line,samp)
    sr[,,2] <- matrix(unlist(MOD09SUB[paste(MOD,'GRE',sep='')],use.names=F),line,samp)
    sr[,,3] <- matrix(unlist(MOD09SUB[paste(MOD,'RED',sep='')],use.names=F),line,samp)
    sr[,,4] <- matrix(unlist(MOD09SUB[paste(MOD,'NIR',sep='')],use.names=F),line,samp)
    sr[,,5] <- matrix(unlist(MOD09SUB[paste(MOD,'SWIR',sep='')],use.names=F),line,samp)
    sr[,,6] <- matrix(unlist(MOD09SUB[paste(MOD,'SWIR2',sep='')],use.names=F),line,samp)
    sr[,,7] <- matrix(unlist(MOD09SUB['QACloud'],use.names=F),line,samp)
  
  # forge preview image
    #initiate preview image
    preview <- array(0,c(line,samp,3))
    # insert each band
    for(i in 1:3){
      # grab band
      band <- sr[,,comp[i]]
      # fix na
      band[is.na(band)] <- 0
      # fix extreme value
      band[band>stretch[2]] <- stretch[2]
      band[band<stretch[1]] <- stretch[1]
      # stretch the band
      band <- ((band-stretch[1])/(stretch[2]-stretch[1]))*(band!=0)
      # apply cloud mask
      if(cmask){band[sr[,,7]==1]<-1}
      # assign to preview
      preview[,,i] <- band
    }
    rm(band)
  
  # generate image
  writePNG(preview,outFile)
  
  # done
  return(0)
  
}

#------------------------------------------------------------

# batch generate preview of all mat files in a folder
#
# Input Arguments: 
#   path (String) - path to all input files
#   pattern (String) pattern to search for file
#   output (String) - output location
#   subType (String) - the type of the input SwathSub ('SUB','SUBF', or 'BRDF')
#   comp (Vector) - composite of the preview image (default 4,3,2)
#   stretch (Vector) - stretch of the image (default 0-3000)
#   cmask (Logical) - apply cloud mask or not
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
batch_gen_preview <- function(path,pattern='MOD09SUB*500m*',output,subType='SUB',
                              comp=c(4,3,2),stretch=c(0,3000),cmask=F){
  
  # find all files
  pattern <- paste(pattern,'*mat',sep='')
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
    outFile <- paste(output,subType,'_',date,'.png',sep='')
    gen_preview(fileList[i],outFile,subType,comp,stretch,cmask)
    cat(paste(outFile,'...done\n'))
  }
  
  # done
  return(0)
  
}

#------------------------------------------------------------
