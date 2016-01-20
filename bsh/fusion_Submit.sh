#!/bin/bash

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

# Run the bash script
matlab -nodisplay -nojvm -singleCompThread << MATLAB_ENV
cd ../
fusion_Run('$2',$3,$4,'$1')
quit
MATLAB_ENV

echo "=========================================================="
echo "Finished on : $(date)"
echo "=="
