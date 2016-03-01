#!/bin/bash
# landsat2modis.sh
# Version 1.0
# Tools
#
# Project: New Fusion
# By xjtang
# Created On: 2/15/2016
# Last Update: 2/15/2016
#
# Input Arguments: 
#   file - the input file
#   result - the result file 
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
# Released on Github on 2/15/2016, check Github Commits for updates afterwards.
#------------------------------------------------------------

# check if file exist
if [ ! -f $1 ]; then
    echo "Error - $1 does not exist"
fi

# warp
echo "warping"
gdalwarp -t_srs '+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs' -te $3 $4 $5 $6 -tr 231.656358263958452 231.656358263958339 -r average -srcnodata -9999 -dstnodata -9999 -overwrite $1 $2 

echo "done!"

# done