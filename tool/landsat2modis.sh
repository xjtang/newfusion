#!/bin/bash
# landsat2modis.sh
# Version 2.0
# Tools
#
# Project: New Fusion
# By xjtang
# Created On: 2/15/2016
# Last Update: 3/1/2016
#
# Input Arguments: 
#   -i read srs from image
#   1.Source file
#   2.Target file
#   
# Output Arguments: 
#   NA
#
# Instruction: 
#   1.Run the new fusion model to generate result map.
#   2.Reproject result to MODIS scale using this script.
#
# Version 1.0 - 2/15/2016
#   This script reproject fusion result to MODIS scale.
#
# Updates of Version 2.0 - 3/1/2016
#   1.Added the ability to warp to the srs of a specific file.
#
# Released on Github on 2/15/2016, check Github Commits for updates afterwards.
#------------------------------------------------------------

# initialize
RESAMP=average

# check input arguments
while [[ $# > 0 ]]; do
    InArg="$1"
    case $InArg in
        -i)
            echo 'Read srs from file.'
            SRSFile=$2
            shift
            ;;
        -r)
            echo 'Custom resampling method.'
            RESAMP=$2
            shift
            ;;
        *)
            ori=$1
            des=$2
            break
    esac
    shift
done

# check if file exist
if [ ! -f $ori ]; then
    echo "Error - $ori does not exist"
fi

if [ -z $SRSFile ]; then
    # warp to MODIS
    echo "warping to default MODIS"
    gdalwarp -t_srs '+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs' -tr 231.656358263958 231.656358263958 -r $RESAMP -srcnodata -9999 -dstnodata -9999 -overwrite $ori $des 
else
    # warp to file
    # grab extent
    EXTENT=$(gdalinfo $SRSFile |\
        grep "Lower Left\|Upper Right" |\
        sed "s/Lower Left  //g;s/Upper Right //g;s/).*//g" |\
        tr "\n" " " |\
        sed 's/ *$//g' |\
        tr -d "[(,]")
    # grab resolution
    RES=$(gdalinfo $SRSFile |\
        grep "Pixel Size =" |\
        sed "s/Pixel Size = //g;s/).*//g" |\
        tr "\n" " " |\
        sed 's/ *$//g' |\
        tr -d "[(]-" |\
        tr "," " ")
    # grab srs
    SRS=$(gdalsrsinfo $SRSFile |\
        grep "PROJ.4" |\
        sed "s/PROJ.4 : //g;s/).*//g" |\
        tr "\n" " " |\
        sed 's/ *$//g')
    # warp
    gdalwarp -t_srs "$SRS" -tr $RES -te $EXTENT -r $RESAMP -srcnodata -9999 -dstnodata -9999 -overwrite $ori $des
fi

echo "done!"

# done
