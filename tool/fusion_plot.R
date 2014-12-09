# fusion_plot.R
# Version 1.2
# Tools
#
# Project: Fusion
# By Xiaojing Tang
# Created On: 12/02/2014
# Last Update: 12/09/2014
#
# Input Arguments: 
#   See specific function.
#   
# Output Arguments: 
#   See specific function.
#
# Usage: 
#   1.Generate fusion results with fusion program.
#   2.Use this script to generate plots of the results.
#
# Version 1.0 - 12/05/2014
#   This script generates plots for the fusion results.
#   The script will fit a simple linear model and display the result.
#   Only plot for red, nir and swir are generated.
#   
# Updates of Version 1.1 - 12/06/2014
#   1.Added batch processing.
#   2.Bugs fixed.
#   3.Added overall title.
#
# Updates of Version 1.2 - 12/09/2014
#   1.Added a NDVI plot.
#   2.Bugs fixed
#
# Released on Github on 12/05/2014, check Github Commits for updates afterwards.
#------------------------------------------------------------

# library and sourcing
library(R.matlab)
library(RCurl)
library(png)
script <- getURL('https://raw.githubusercontent.com/xjtang/rTools/master/source_all.R',ssl.verifypeer=F)
eval(parse(text=script),envir=.GlobalEnv)

#------------------------------------------------------------

# generate preview plots for the fusion results
#
# Input Arguments: 
#   file (String) - input fusion result .mat file
#   outFile (String) - output file with .png extension
#   fusType (String) - the type of the fusion result ('FUS', or 'BRDF')
#   cmask (Logical) - apply cloud mask or not
#   rs (Logical) - do regression or not
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
fusion_plot <- function(file,outFile,fusType='FUS',cmask=T,rs=T){
  
  # set style
  pointMarker <- 16
  lineColor <- 300
  pointColor <- 29
  rsColor <- 46
  rslineColor <- 133
  axisLim <- c(0,5000)
  
  # check fusType
  if(fusType=='FUS'){
    MOD <- 'FUS09' 
  }else if(fusType=='BRDF'){
    MOD <- 'FUSB9' 
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
  
  # read in .mat file
  MOD09SUB <- readMat(file)
  
  # grab dimension information
  line <- length(unlist(MOD09SUB['MODLine'],use.names=F))
  samp <- length(unlist(MOD09SUB['MODSamp'],use.names=F))
  
  # initiate surface reflectance array
  sr <- matrix(0,line*samp,9)
  
  # grab each band
  sr[,1] <- unlist(MOD09SUB[paste('MOD09','RED',sep='')],use.names=F)
  sr[,2] <- unlist(MOD09SUB[paste('MOD09','NIR',sep='')],use.names=F)
  sr[,3] <- unlist(MOD09SUB[paste('MOD09','SWIR',sep='')],use.names=F)
  sr[,4] <- unlist(MOD09SUB[paste(MOD,'RED',sep='')],use.names=F)
  sr[,5] <- unlist(MOD09SUB[paste(MOD,'NIR',sep='')],use.names=F)
  sr[,6] <- unlist(MOD09SUB[paste(MOD,'SWIR',sep='')],use.names=F)
  sr[,7] <- unlist(MOD09SUB['QACloud'],use.names=F)
  # calculate ndvi
  sr[,8] <- (sr[,2]-sr[,1])/(sr[,2]+sr[,1])
  sr[,9] <- (sr[,5]-sr[,4])/(sr[,5]+sr[,4])
  
  # cloud masking
  if(cmask){
    sr <- sr[sr[,7]==0,]
  }

  # run regression
  if(rs){
    lmred <- lm(sr[,1]~sr[,4])
    lmnir <- lm(sr[,2]~sr[,5])
    lmswir <- lm(sr[,3]~sr[,6])
    lmndvi <- lm(sr[,9]~sr[,8])
  }
  
  # generate plot
  
    # initiate plot
    png(file=outFile,width=1600,height=1600,pointsize=20)
    cPar <- par(mfrow=c(2,2),oma=c(0,0,3,0))
  
    # plot red
    plot(sr[,4],sr[,1],type='p',col=colors()[pointColor],pch=pointMarker,
         main=paste('MODIS ',MODIS,' vs. Fusion (Red Band)',sep=''),
         ylab=paste('MODIS ',MODIS,sep=''),xlab='Fusion',
         xlim=axisLim,ylim=axisLim
        )
    abline(0,1,col=colors()[lineColor])
    if(rs){
      abline(coef(lmred)[1],coef(lmred)[2],col=colors()[rslineColor])
      eq <- paste('MOD = ',round(coef(lmred)[2],2),'*',fusType,'+',round(coef(lmred)[1],1),sep='')
      text(0,axisLim[2],eq,col=colors()[rsColor],pos=4,cex=1.5)
      text(0,axisLim[2]-200,paste('R2=',round(summary(lmred)$r.squared,2),sep=''),col=colors()[rsColor],pos=4,cex=1.5)
    }
  
    # plot NIR
    plot(sr[,5],sr[,2],type='p',col=colors()[pointColor],pch=pointMarker,
         main=paste('MODIS ',MODIS,' vs. Fusion (NIR Band)',sep=''),
         ylab=paste('MODIS ',MODIS,sep=''),xlab='Fusion',
         xlim=axisLim,ylim=axisLim
    )
    abline(0,1,col=colors()[lineColor])
    if(rs){
      abline(coef(lmnir)[1],coef(lmnir)[2],col=colors()[rslineColor])
      eq <- paste('MOD = ',round(coef(lmnir)[2],2),'*',fusType,'+',round(coef(lmnir)[1],1),sep='')
      text(0,axisLim[2],eq,col=colors()[rsColor],pos=4,cex=1.5)
      text(0,axisLim[2]-200,paste('R2=',round(summary(lmnir)$r.squared,2),sep=''),col=colors()[rsColor],pos=4,cex=1.5)
    }
  
    # plot SWIR
    plot(sr[,6],sr[,3],type='p',col=colors()[pointColor],pch=pointMarker,
         main=paste('MODIS ',MODIS,' vs. Fusion (SWIR Band)',sep=''),
         ylab=paste('MODIS ',MODIS,sep=''),xlab='Fusion',
         xlim=axisLim,ylim=axisLim
    )
    abline(0,1,col=colors()[lineColor])
    if(rs){
      abline(coef(lmswir)[1],coef(lmswir)[2],col=colors()[rslineColor])
      eq <- paste('MOD = ',round(coef(lmswir)[2],2),'*',fusType,'+',round(coef(lmswir)[1],1),sep='')
      text(0,axisLim[2],eq,col=colors()[rsColor],pos=4,cex=1.5)
      text(0,axisLim[2]-200,paste('R2=',round(summary(lmswir)$r.squared,2),sep=''),col=colors()[rsColor],pos=4,cex=1.5)
    }
      
    # plot NDVI
    plot(sr[,9],sr[,8],type='p',col=colors()[pointColor],pch=pointMarker,
         main=paste('MODIS ',MODIS,' vs. Fusion (NDVI)',sep=''),
         ylab=paste('MODIS ',MODIS,sep=''),xlab='Fusion',
         xlim=c(-1,1),ylim=c(-1,1)
    )
    abline(0,1,col=colors()[lineColor])
    if(rs){
      abline(coef(lmndvi)[1],coef(lmndvi)[2],col=colors()[rslineColor])
      eq <- paste('MOD = ',round(coef(lmndvi)[2],2),'*',fusType,'+',round(coef(lmndvi)[1],1),sep='')
      text(-1,1,eq,col=colors()[rsColor],pos=4,cex=1.5)
      text(-1,0.96,paste('R2=',round(summary(lmndvi)$r.squared,2),sep=''),col=colors()[rsColor],pos=4,cex=1.5)
    }
      
    # add overall title
    fileDate <- gsub('.*(\\d\\d\\d\\d\\d\\d\\d).*','\\1',file)
    mTitle <- paste('MODIS ',MODIS,' ',fileDate,' TYPE=',fusType,' CMASK=',strLeft(cmask,1),sep='')
    mtext(mTitle,outer = TRUE, cex = 1.5)
  
  # save plot
  dev.off()
  
  # reset par
  par(cPar) 
  
  # done
  return(0)
  
}

#------------------------------------------------------------

# batch generate fusion plot of all mat files in a folder
#
# Input Arguments: 
#   path (String) - path to all input files
#   pattern (String) pattern to search for file
#   output (String) - output location
#   fusType (String) - the type of the fusion result ('FUS', or 'BRDF')
#   cmask (Logical) - apply cloud mask or not
#   rs (Logical) - do regression or not
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
batch_fusion_plot <- function(path,output,pattern='MOD09SUB.*500m.*',
                              fusType='FUS',cmask=T,rs=T){
  
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
    outFile <- paste(output,fusType,'_',date,'_',time,'_plot.png',sep='')
    fusion_plot(fileList[i],outFile,fusType,cmask,rs)
    cat(paste(outFile,'...done\n'))
  }
  
  # done
  return(0)
  
}

#------------------------------------------------------------
