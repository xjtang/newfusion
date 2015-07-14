# fusion_plot.R
# Version 1.4
# Tools
#
# Project: New Fusion
# By xjtang
# Created On: 12/02/2014
# Last Update: 4/7/2015
#
# Input Arguments: 
#   See specific function.
#   
# Output Arguments: 
#   See specific function.
#
# Instruction: 
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
#   2.Bugs fixed.
#
# Updates of Version 1.3 - 12/28/2014
#   1.Added support for 250m resolution.
#   2.Bugs fixed.
#
# Updates of Version 1.4 - 4/7/2015
#   1.Adjusted for major updated in the main program.
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
#   plat (String) - platform ('MOD' or 'MYD')
#   res (Integer) - resolution of the image (250 or 500).
#   cmask (Logical) - apply cloud mask or not
#   rs (Logical) - do regression or not
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
fusion_plot <- function(file,outFile,plat='MOD',res=500,cmask=T,rs=T){
  
  # set style
  pointMarker <- 16
  lineColor <- 300
  pointColor <- 29
  rsColor <- 46
  rslineColor <- 133
  axisLim <- c(0,5000)
  
  # check resolution
  if(res!=500&res!=250){
    cat('Invalid resolution.\n')
    return(-1)
  }
  
  # check platform
  # plat <- strLeft(gsub('.*(M.*D09SUB).*','\\1',file),3)
  if(plat=='MOD'){
    MODIS <- 'Terra' 
  }else if(plat=='MYD'){
    MODIS <-'Aqua' 
  }else{
    cat('Can not figure our the platform.\n')
    return(-1)
  }
  
  # check if file exist
  if(!file.exists(file)){
    cat('Can not find input file.\n')
    return(-1)
  }
   
  # read in .mat file
  MOD09SUB <- readMat(file)
  
  # grab dimension information
  line <- length(unlist(MOD09SUB[paste('MODLine',res,sep='')],use.names=F))
  samp <- length(unlist(MOD09SUB[paste('MODSamp',res,sep='')],use.names=F))
  
  # initiate surface reflectance array
  if(res==500){
    sr <- matrix(0,line*samp,9)
  }else if(res==250){
    sr <- matrix(0,line*samp,7)
  }
  
  # grab each band
  sr[,1] <- unlist(MOD09SUB[paste('MOD09','RED',res,sep='')],use.names=F)
  sr[,3] <- unlist(MOD09SUB[paste('MOD09','NIR',res,sep='')],use.names=F)
  sr[,2] <- unlist(MOD09SUB[paste(MOD,'RED',res,sep='')],use.names=F)
  sr[,4] <- unlist(MOD09SUB[paste(MOD,'NIR',res,sep='')],use.names=F)
  sr[,7] <- unlist(MOD09SUB[paste('QACloud',res,sep='')],use.names=F)
  # calculate ndvi
  sr[,5] <- (sr[,3]-sr[,1])/(sr[,3]+sr[,1])
  sr[,6] <- (sr[,4]-sr[,2])/(sr[,4]+sr[,2])
  # calculate SWIR if 500m resolution
  if(res==500){
    sr[,8] <- unlist(MOD09SUB[paste('MOD09','SWIR',res,sep='')],use.names=F)
    sr[,9] <- unlist(MOD09SUB[paste(MOD,'SWIR',res,sep='')],use.names=F)
  }
  
  # cloud masking
  if(cmask){
    sr <- sr[sr[,7]==0,]
  }

  # run regression
  if(rs){
    lmred <- lm(sr[,1]~sr[,2],na.action=na.omit)
    lmnir <- lm(sr[,3]~sr[,4],na.action=na.omit)
    lmndvi <- lm(sr[,5]~sr[,6],na.action=na.omit)
    if(res==500){lmswir<-lm(sr[,8]~sr[,9],na.action=na.omit)}
  }
  
  # generate plot
  
    # initiate plot
    png(file=outFile,width=1600,height=1600,pointsize=20)
    cPar <- par(mfrow=c(2,2),oma=c(0,0,3,0))
  
    # plot red
    plot(sr[,2],sr[,1],type='p',col=colors()[pointColor],pch=pointMarker,
         main=paste('MODIS ',MODIS,' vs. Fusion (Red Band)',sep=''),
         ylab=paste('MODIS ',MODIS,sep=''),xlab='Fusion',
         xlim=axisLim,ylim=axisLim
        )
    abline(0,1,col=colors()[lineColor])
    if(rs){
      abline(coef(lmred)[1],coef(lmred)[2],col=colors()[rslineColor])
      eq <- paste('MOD = ',round(coef(lmred)[2],2),'*','FUS','+(',round(coef(lmred)[1],1),')',sep='')
      text(0,axisLim[2],eq,col=colors()[rsColor],pos=4,cex=1.5)
      text(0,axisLim[2]-200,paste('R2=',round(summary(lmred)$r.squared,2),sep=''),col=colors()[rsColor],pos=4,cex=1.5)
    }
  
    # plot NIR
    plot(sr[,4],sr[,3],type='p',col=colors()[pointColor],pch=pointMarker,
         main=paste('MODIS ',MODIS,' vs. Fusion (NIR Band)',sep=''),
         ylab=paste('MODIS ',MODIS,sep=''),xlab='Fusion',
         xlim=axisLim,ylim=axisLim
    )
    abline(0,1,col=colors()[lineColor])
    if(rs){
      abline(coef(lmnir)[1],coef(lmnir)[2],col=colors()[rslineColor])
      eq <- paste('MOD = ',round(coef(lmnir)[2],2),'*','FUS','+(',round(coef(lmnir)[1],1),')',sep='')
      text(0,axisLim[2],eq,col=colors()[rsColor],pos=4,cex=1.5)
      text(0,axisLim[2]-200,paste('R2=',round(summary(lmnir)$r.squared,2),sep=''),col=colors()[rsColor],pos=4,cex=1.5)
    }
      
    # plot NDVI
    plot(sr[,6],sr[,5],type='p',col=colors()[pointColor],pch=pointMarker,
         main=paste('MODIS ',MODIS,' vs. Fusion (NDVI)',sep=''),
         ylab=paste('MODIS ',MODIS,sep=''),xlab='Fusion',
         xlim=c(-1,1),ylim=c(-1,1)
    )
    abline(0,1,col=colors()[lineColor])
    if(rs){
      abline(coef(lmndvi)[1],coef(lmndvi)[2],col=colors()[rslineColor])
      eq <- paste('MOD = ',round(coef(lmndvi)[2],2),'*','FUS','+(',round(coef(lmndvi)[1],1),')',sep='')
      text(-1,1,eq,col=colors()[rsColor],pos=4,cex=1.5)
      text(-1,0.92,paste('R2=',round(summary(lmndvi)$r.squared,2),sep=''),col=colors()[rsColor],pos=4,cex=1.5)
    }
    
  if(res==500){
    # plot SWIR
    plot(sr[,9],sr[,8],type='p',col=colors()[pointColor],pch=pointMarker,
         main=paste('MODIS ',MODIS,' vs. Fusion (SWIR Band)',sep=''),
         ylab=paste('MODIS ',MODIS,sep=''),xlab='Fusion',
         xlim=axisLim,ylim=axisLim
    )
    abline(0,1,col=colors()[lineColor])
    if(rs){
      abline(coef(lmswir)[1],coef(lmswir)[2],col=colors()[rslineColor])
      eq <- paste('MOD = ',round(coef(lmswir)[2],2),'*','FUS','+(',round(coef(lmswir)[1],1),')',sep='')
      text(0,axisLim[2],eq,col=colors()[rsColor],pos=4,cex=1.5)
      text(0,axisLim[2]-200,paste('R2=',round(summary(lmswir)$r.squared,2),sep=''),col=colors()[rsColor],pos=4,cex=1.5)
    }
  }
  
    # add overall title
    fileDate <- gsub('.*(\\d\\d\\d\\d\\d\\d\\d).*','\\1',file)
    mTitle <- paste('MODIS ',MODIS,' ',fileDate,' TYPE=',''FUS,' Res=',res,'m CMASK=',strLeft(cmask,1),sep='')
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
#   output (String) - output location
#   plat (String) - platform ('MOD' or 'MYD')
#   res (Integer) - resolution of the image (250 or 500).
#   cmask (Logical) - apply cloud mask or not
#   rs (Logical) - do regression or not
#
# Output Arguments: 
#   r (Integer) - 0: Successful
#
batch_fusion_plot <- function(path,output,plat='MOD',res=500,
                              cmask=T,rs=T){
  
  # find all files
  pattern <- paste('.*',plat,'.*','ALL','m.*.mat',sep='')
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
    outFile <- paste(output,'/PLOT_',plat,'_',res,'m_',date,'_',time,'.png',sep='')
    fusion_plot(fileList[i],outFile,plat,res,cmask,rs)
    cat(paste(outFile,'...done\n'))
  }
  
  # done
  return(0)
  
}

#------------------------------------------------------------
