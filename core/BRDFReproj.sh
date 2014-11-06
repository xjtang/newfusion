# BRDFReproj.sh
# Version 1.0
# Core
#
# Project: Fusion
# By: Xiaojing Tang
# Created On: 11/5/2014
#
# Input Arguments:
#   1.Input HDF File
#   2.UTM Zone
#   3.Extent
#   4.Resolution
#   5.Output
# 
# Output Arguments: NA
#
# Usage: 
#   1.Call by other scripts with correct input and output arguments.
#
# Version 1.0 - 11/5/2014
#   Reproject BRDF coefficients to Landsat scale
#
#----------------------------------------------------------------
#

#!/bin/bash

# load module
module load gdal/1.10.0

# make temp folder
if [ ! -d ./temp/ ]; then
    mkdir ./temp
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
gdal_merge.py -o $9 -of ENVI -init 10000 -n 10000 -separete ./BRDFCoef_band1.tif ./BRDFCoef_band2.tif ./BRDFCoef_band3.tif ./BRDFCoef_band4.tif ./BRDFCoef_band5.tif ./BRDFCoef_band7.tif

# delete temp file

echo 'done!'

# done
