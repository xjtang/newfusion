#!/bin/bash

# submit n jobs to run fusion
# n defines number of jobs in total
# Input Arguments: 
#   1.Function to execute
#   2.Data path
#   3.Platform
#   4.BRDF switch
#   5.Resolusion
#   6.Discard rate
#   7.n jobs

echo 'Total jobs to submit is' $5
for i in $(seq 1 $5); do
    echo 'Submitting job no.' $i 'out of' $5
    chmod u+x ./fusion_qsub.sh
    qsub -N fusion_$i ./fusion_qsub.sh $1 $2 $3 $4 $i $5
done

# end
