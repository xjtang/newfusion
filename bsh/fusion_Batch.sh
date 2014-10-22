#!/bin/bash

# submit n jobs to run fusion
# n defines number of jobs in total
# Input Arguments: 
#   1.Data path
#   2.BRDF switch
#   3.Resolusion
#   4.Discard rate
#   5.n jobs

for i in $(seq 1 $5); do
    qsub ./fusion_qsub.sh $1 $2 $3 $4 $i $5
done

# end
