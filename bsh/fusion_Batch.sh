#!/bin/bash

# submit n jobs to run fusion
# n defines number of jobs in total
# Input Arguments: 
#   1.Function to execute
#   2.Config File
#   3.n jobs

echo 'Total jobs to submit is' $3
for i in $(seq 1 $3); do
    echo 'Submitting job no.' $i 'out of' $3
    chmod u+x ./fusion_qsub.sh
    qsub -N fusion_$i ./fusion_qsub.sh $1 $2 $i $3
done

# end
