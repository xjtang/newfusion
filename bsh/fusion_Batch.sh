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
    
    case $InArg in
        -c)
            echo 'Running standalone job.'
            ;;
        -m)
            echo 'Requesting extra memory.'
            ;;
        *)
            echo 'Something else.'
            ;;
    esac

    shift

done

# end
