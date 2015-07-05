# BRDFReproj.sh
# Version 1.0.1
# Core
#
# Project: New fusion
# By: xjtang
# Created On: 11/5/2014
# Last Update: 7/5/2015
#
# Input Arguments:
#   1.Input HDF File
#   2.UTM Zone
#   3,4,5,6.Extent
#   7,8.Resolution
#   9.Output
#   10.Job ID
# 
# Output Arguments: NA
#
# Instruction: 
#   1.Call by other scripts with correct input and output arguments.
#
# Version 1.0 - 11/5/2014
#   Reproject BRDF coefficients to Landsat scale
#
# Updates of Version 1.0.1 - 7/5/2015
#   1.Fixed a major bug that may cause error when running multiple jobs.
#
# Created on Github on 11/5/2014, check Github Commits for updates afterwards.
#----------------------------------------------------------------

#!/bin/bash

# load module
module load gdal/1.10.0

# move to uotput directory
cd $(dirname $9)

# make temp folder
if [ ! -d ./temp$10/ ]; then
    mkdir ./temp$10
fi

# grab inputs
file='"'$1'"'
zone=$2
extent=$3' '$4' '$5' '$6
res=$7' '$8

# reproject all bands
gdalwarp -t_srs '+proj=utm +zone='$zone' +datum=WGS84' -te $extent -tr $res HDF4_EOS:EOS_GRID:$file:MODIS_Grid_500m_2D:sur_refl_b03_1 ./temp/BRDFCoef_band1.tif
gdalwarp -t_srs '+proj=utm +zone='$zone' +datum=WGS84' -te $extent -tr $res HDF4_EOS:EOS_GRID:$file:MODIS_Grid_500m_2D:sur_refl_b04_1 ./temp/BRDFCoef_band2.tif
gdalwarp -t_srs '+proj=utm +zone='$zone' +datum=WGS84' -te $extent -tr $res HDF4_EOS:EOS_GRID:$file:MODIS_Grid_500m_2D:sur_refl_b01_1 ./temp/BRDFCoef_band3.tif
gdalwarp -t_srs '+proj=utm +zone='$zone' +datum=WGS84' -te $extent -tr $res HDF4_EOS:EOS_GRID:$file:MODIS_Grid_500m_2D:sur_refl_b02_1 ./temp/BRDFCoef_band4.tif
gdalwarp -t_srs '+proj=utm +zone='$zone' +datum=WGS84' -te $extent -tr $res HDF4_EOS:EOS_GRID:$file:MODIS_Grid_500m_2D:sur_refl_b06_1 ./temp/BRDFCoef_band5.tif
gdalwarp -t_srs '+proj=utm +zone='$zone' +datum=WGS84' -te $extent -tr $res HDF4_EOS:EOS_GRID:$file:MODIS_Grid_500m_2D:sur_refl_b07_1 ./temp/BRDFCoef_band7.tif

# stack results
cd ./temp$10/
gdal_merge.py -o $9 -of ENVI -init 1000 -n 1000 -separate ./BRDFCoef_band1.tif ./BRDFCoef_band2.tif ./BRDFCoef_band3.tif ./BRDFCoef_band4.tif ./BRDFCoef_band5.tif ./BRDFCoef_band7.tif

# delete temp file
cd ../
rm -r ./temp$10

echo 'done!'

# done
