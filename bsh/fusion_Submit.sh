#!/bin/bash

# Launch Matlab in Bash and run Fusion.

matlab -nodisplay -nojvm -singleCompThread << MATLAB_ENV
cd ../
main = fusion_Inputs('$2',[$3 $4])
$1(main)
quit
MATLAB_ENV

echo 'Done!'

# End
