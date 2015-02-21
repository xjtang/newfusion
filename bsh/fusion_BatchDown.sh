#!/bin/bash

# submit n jobs to download MODIS data
# n defines number of jobs in total
# Input Arguments: 
#   1.input 
#   2.Data path
#   3.n jobs

echo 'Total jobs to submit is' $3
for i in $(seq 1 $3); do
    echo 'Submitting job no.' $i 'out of' $3
    chmod u+x ./fusion_Download.sh
    qsub ./fusion_Download.sh $1 $2 $3 $i
done

# end
