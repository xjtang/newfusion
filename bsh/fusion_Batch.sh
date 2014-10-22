#!/bin/bash

# submit n jobs to run fusion
# n defines number of jobs in total
# Input Arguments: 
#   1.Data path
#   2.BRDF switch
#   3.Resolusion
#   4.Discard rate
#   5.n jobs

echo 'Total jobs to submit is' $5
for i in $(seq 1 $5); do
    echo 'Submitting job no.' $i 'out of' $5
    chmod u+x ./fusion_qsub.sh
    qsub ./fusion_qsub.sh $1 $2 $3 $4 $i $5
done

# end
