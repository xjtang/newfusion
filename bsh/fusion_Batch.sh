#!/bin/bash

# submit n jobs to run fusion
# n defines number of jobs in total
# Input Arguments: 
#   -c run compiled version (optional)
#   1.Function to execute
#   2.Config File
#   3.n jobs

if [ $1 = '-c' ]; then
    echo 'Running standalone job.'
    echo 'Total jobs to submit is' $4
    for i in $(seq 1 $4); do
        echo 'Submitting job no.' $i 'out of' $4
        qsub -N fusion_$i ./fusion_Standalone.sh $3 $i $4 $2 
    done
else
    echo 'Running regular job.'
    echo 'Total jobs to submit is' $3
    for i in $(seq 1 $3); do
        echo 'Submitting job no.' $i 'out of' $3
        qsub -N fusion_$i ./fusion_Submit.sh $1 $2 $i $3
    done
fi

# end
