#!/bin/bash

# submit n jobs to run fusion
# n defines number of jobs in total
# Input Arguments: 
#   -c run compiled version (optional)
#   -s request extra slots (optional)
#   -m request extra memory (optional)
#   1.Function to execute
#   2.Config File
#   3.n jobs

VER=Submit
SLOT=1
MEM=1

while [[ $# > 0 ]]; do

    InArg="$1"
    
    case $InArg in
        -c)
            echo 'Running standalone job.'
            VER=Standalone
            ;;
        -m)
            echo 'Requesting extra memory.'
            MEM=94
            ;;
        -s)
            echo 'Requesting extra slots.'
            SLOT=3
            ;;
        *)
            FUNC=$1
            CONFILE=$2
            NJOB=$3
            break
    esac

    shift

done

echo 'Total jobs to submit is' $NJOB
for i in $(seq 1 $NJOB); do
    echo 'Submitting job no.' $i 'out of' $NJOB
    echo 'qsub -N fusion_'$i' -pe omp '$SLOT' -l mem_total='$MEM'G ./fusion_'${VER}'.sh '$CONFILE' '$i' '$NJOB' '$FUNC
    qsub -N fusion_$i -pe omp $SLOT -l mem_total=${MEM}G ./fusion_${VER}.sh $CONFILE $i $NJOB $FUNC
done

# end
