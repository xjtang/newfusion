#!/bin/bash

# submit n jobs to run fusion
# n defines number of jobs in total
# Input Arguments: 
#   1.Data path
#   2.Platform
#   3.BRDF switch
#   4.Resolusion
#   5.Discard rate
#   6.n jobs

echo 'Total jobs to submit is' $6
for i in $(seq 1 $6); do
    echo 'Submitting job no.' $i 'out of' $6
    chmod u+x ./fusion_qsub.sh
    qsub ./fusion_qsub.sh $1 $2 $3 $4 $5 $i $6
done

# end
