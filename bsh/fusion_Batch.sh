#!/bin/bash

# submit n jobs to run fusion
# n defines number of jobs in total
# Input Arguments: 
#   -c run compiled version (optional)
#   -m request extra memory (optional)
#   1.Function to execute
#   2.Config File
#   3.n jobs

while [[ $# > 0 ]]; do

    InArg="$1"
    VER=Submit
    SLOT=1
    
    case $InArg in
        -c)
            echo 'Running standalone job.'
	    VER=Standalone
            ;;
        -m)
            echo 'Requesting extra memory.'
	    SLOT=3
            ;;
        *)
            FUNC=$1
	    CONFIle=$2
	    NJOB=$3
	    break
    esac

    shift

done

echo 'Total jobs to submit is' $NJOB
for i in $(seq 1 $NJOB); do
    echo 'Submitting job no.' $i 'out of' $NJOB
    qsub -N fusion_$i -pe omp $SLOT ./fusion_${VER}.sh $CONFILE $i $NJOB $FUNC
done

# end
