#!/bin/bash
# checksum.sh
# Version 1.0
# Tools
#
# Project: New Fusion
# By xjtang
# Created On: 3/1/2015
# Last Update: 3/1/2015
#
# Input Arguments: 
#   chsumfile - the check sum file 
#   path - path to data
#   
# Output Arguments: 
#   NA
#
# Instruction: 
#   1.Download data and checksum file from LAADS ftp.
#   2.Validate checksum for downloaded MODIS data.
#
# Version 1.0 - 3/1/2015
#   This script validates checksum of MODIS data.
#
# Released on Github on 3/1/2015, check Github Commits for updates afterwards.
#------------------------------------------------------------

# check if folder exist
if [ ! -d $2 ]; then
    echo "Error - $2 is not a directory"
fi
# set working directory
cd $2

# read the checksum by line
file=$1
while read line; do
  # extract information
  info=($line)
  archive=${info[2]}
  # test to see if archive exists
  if [ ! -f $archive ]; then
    echo "Can not find $archive"
    continue
  fi
  # if archive exists, then validate checksum
  test=$(cksum $archive)
  if [ "$test" != "$(echo $line)" ]; then
    echo "!!!!! WARNING $archive may be corrupted !!!!!"
  else
    echo "$archive is ok"
  fi
done < $file

# done
echo "done!"

