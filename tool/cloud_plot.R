# cloud_plot.R
# Version 1.0
# Tools
#
# Project: Fusion
# By Xiaojing Tang
# Created On: 11/26/2014
# Last Update: 12/02/2014
#
# Input Arguments: 
#   file - a csv file with the cloud states
#   outFile - the output file for saving the plot
#   
# Output Arguments: NA
#
# Usage: 
#   1.Generate cloud stats with other tools.
#   2.Use this script to make plot.
#
# Version 1.0 - 12/02/2014
#   This script makes a lot for the cloud stats of swath data.
#   
# Released on Github on 11/30/2014, check Github Commits for updates afterwards.
#------------------------------------------------------------

# library and sourcing
library(RCurl)
script <- getURL('https://raw.githubusercontent.com/xjtang/rTools/master/source_all.R',ssl.verifypeer=F)
eval(parse(text=script),envir=.GlobalEnv)

#--------------------------------------

# main function
cloud_plot <- function(file,outFile){
  
  # set style
  classColor <- c(258,88,90,503,326) 
  lineColor <- 231
  labelColor <- 523
  pointMarker <- 16
  
  # check if file exist
  if(!file.exists(file)){
    cat('Can not find input file.\n')
    return(-1)
  }
  
  # read input
  data <- read.csv(file,header=F)
  year <- data[1,1]
  
  # initial plot
  png(file=outFile,width=1920,height=1080,pointsize=24)
  c1 <- data[data[,3]<=20,]
  plot(c1[,2],c1[,3],type='p',col=colors()[classColor[1]],pch=pointMarker,
       main=paste('Cloud Cover of MODIS Swath Data (',year,')',sep=''),
       xlab='Day of Year',ylab='Percent Cloud',
       xlim=c(-10,365),ylim=c(-5,100)
      )
       
  # continue plots
  c2 <- data[(data[,3]>20&data[,3]<=40),]
  points(c2[,2],c2[,3],col=colors()[classColor[2]],pch=pointMarker)
  c3 <- data[(data[,3]>40&data[,3]<=60),]
  points(c3[,2],c3[,3],col=colors()[classColor[3]],pch=pointMarker)
  c4 <- data[(data[,3]>60&data[,3]<=80),]
  points(c4[,2],c4[,3],col=colors()[classColor[4]],pch=pointMarker)
  c5 <- data[(data[,3]>80),]
  points(c5[,2],c5[,3],col=colors()[classColor[5]],pch=pointMarker)
  
  # add legend
  text(-15,90,nrow(c5),col=colors()[classColor[5]])
  text(-15,70,nrow(c4),col=colors()[classColor[4]])
  text(-15,50,nrow(c3),col=colors()[classColor[3]])
  text(-15,30,nrow(c2),col=colors()[classColor[2]])
  text(-15,10,nrow(c1),col=colors()[classColor[1]])
  text(-15,-5,nrow(data),col=colors()[labelColor])
  
  # add month split
  months <- c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')
  for(i in 1:12){
    abline(v=dateToDOY(year,i,1,T)-1,col=colors()[lineColor]) 
    text(dateToDOY(year,i,1,T)+15,-5,months[i],col=colors()[labelColor])
  }
  abline(v=dateToDOY(year,12,31,T),col=colors()[lineColor]) 
  
  # save plot
  dev.off()
  
  # done
  return(0)
  
}

#--------------------------------------
