#!/bin/bash

# Submit qsub job 

# Specify which shell to use
#$ -S /bin/bash

# Run for 24 hours
#$ -l h_rt=24:00:00

# Forward my current environment
#$ -V

# Give this job a name
#$ -N fusion_download

# Join standard output and error to a single file
#$ -j y

# Name the file where to redirect standard output and error
#$ -o download.qlog

# Now let's keep track of some information just in case anything goes wrong

echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "Task index number : $SGE_TASK_ID"
echo "=========================================================="

# Run the bash script
module load R
R --slave --vanilla --quiet --no-save  <<EEE
install.packages("RCurl",repos="http://cran.rstudio.com/")
source('https://raw.githubusercontent.com/xjtang/fusion/master/tool/swath_download.R')
swathDownload($1,$2)
EEE

echo "=========================================================="
echo "Finished on : $(date)"
echo "=="
