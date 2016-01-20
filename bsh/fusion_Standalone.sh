#!/bin/bash -l

# Submit qsub job 

# Specify which shell to use
#$ -S /bin/bash

# Run for 24 hours
#$ -l h_rt=48:00:00

# Forward my current environment
#$ -V

# Join standard output and error to a single file
#$ -j y

# Name the file where to redirect standard output and error
#$ -o fusion.qlog

# Now let's keep track of some information just in case anything goes wrong

echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "Task index number : $SGE_TASK_ID"
echo "=========================================================="

# load module
module load hdf/4.2.5
module load gdal/1.10.0
module load mcr/8.1_2013a
# module load mcr/9.0_2015b

# Run the standalone versiopn
cd ../mcc/
./fusion_v130 $1 $2 $3 $4

echo "=========================================================="
echo "Finished on : $(date)"
echo "=="
