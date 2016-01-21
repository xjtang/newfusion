# cloud_plot.R
# Version 1.3
# Tools
#
# Project: New Fusion
# By xjtang
# Created On: 11/26/2014
# Last Update: 12/23/2015
#
# Input Arguments: 
#   file - a csv file with the cloud states
#   
# Output Arguments: NA
#
# Instruction: 
#   1.Generate cloud stats with other tools.
#   2.Use this script to make plot.
#
# Version 1.0 - 12/02/2014
#   This script makes a lot for the cloud stats of swath data.
#
# Updates of Version 1.1 - 12/14/2014
#   1.Bugs fixed.
#   2.Added platform information into title
#
# Updates of Version 1.2 - 9/24/2015
#   1.Added support for multiyear
#
# Updates of Version 1.3 - 12/23/2015
#   1.Added support for combining terra and aqua.
#   
# Released on Github on 11/30/2014, check Github Commits for updates afterwards.
#------------------------------------------------------------

# library and sourcing
library(RCurl)
script <- getURL('https://raw.githubusercontent.com/xjtang/rTools/master/source_all.R',ssl.verifypeer=F)
eval(parse(text=script),envir=.GlobalEnv)

#--------------------------------------

# main function
cloud_plot <- function(file){
  
  # set style
  classColor <- c(258,90,326) 
  lineColor <- 231
  labelColor <- 523
  pointMarker <- c(1,15,17)
  
  # check if file exist
  if(!file.exists(file)){
    cat('Can not find input file.\n')
    return(-1)
  }
  
  # read input
  rawdata <- read.csv(file,header=F)
  year <- sort(unique(rawdata[,1]))
  plat <- unique(rawdata[,4])
  date <- rawdata[,1]+rawdata[,2]/366
  data <- cbind(rawdata,date)
  
  # scale dot size
  if(length(year)<=1){
    pointSize <- 1
  }else{
    pointSize <- 0.65
  }
  
  # initial plot
  png(file=paste(trimRight(file,4),'.png',sep=''),width=1920,height=1080,pointsize=24)
  # plot data
  for(i in 1:length(plat)){
    # plot first set of data
    c1 <- data[(data[,3]<=50)&(data[,4]==plat[i]),] 
    if(i==1){
      plot(c1[,5],c1[,3],type='p',col=colors()[classColor[1]],pch=pointMarker[plat[i]+1],cex=pointSize,
           main='Cloud Cover of MODIS Swath Data',xlab='Day of Year',ylab='Percent Cloud',
           xlim=c(year[1]-0.05,year[length(year)]+1),ylim=c(-5,100))
    }else{
      points(c1[,5],c1[,3],col=colors()[classColor[1]],pch=pointMarker[plat[i]+1],cex=pointSize)
    }
    # continue plots
    c2 <- data[(data[,3]>50)&(data[,3]<=80)&(data[,4]==plat[i]),]
    points(c2[,5],c2[,3],col=colors()[classColor[2]],pch=pointMarker[plat[i]+1],cex=pointSize)
    c3 <- data[(data[,3]>80)&(data[,4]==plat[i]),]
    points(c3[,5],c3[,3],col=colors()[classColor[3]],pch=pointMarker[plat[i]+1],cex=pointSize)
  }
  
  # add legend
  text(year[1]-0.1,90,nrow(data[data[,3]>80,]),col=colors()[classColor[3]])
  text(year[1]-0.1,70,nrow(data[(data[,3]>50)&(data[,3]<=80),]),col=colors()[classColor[2]])
  text(year[1]-0.1,30,nrow(data[data[,3]<=50,]),col=colors()[classColor[1]])
  text(year[1]-0.1,-5,nrow(data),col=colors()[labelColor])
  
  if(length(year)<=1){
    # add month split
    months <- c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')
    for(j in 1:12){
      abline(v=year+(dateToDOY(i,j,1,T)-1)/366,col=colors()[lineColor]) 
      text(year+(dateToDOY(i,j,1,T)+15)/366,-5,months[j],col=colors()[labelColor])
    }
    abline(v=year+1,col=colors()[lineColor]) 
  }else{
    # add annual split
    for(j in 1:(length(year)+1)){
      abline(v=year[j],col=colors()[lineColor]) 
      # text(year[j]+0.5,-5,year[j],col=colors()[labelColor])
    }
  }
  
  # save plot
  dev.off()
  
  # done
  return(0)
  
}

#--------------------------------------
