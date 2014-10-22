#!/bin/bash

# Launch Matlab in Bash and run Fusion.

matlab -nodisplay -nojvm -singleCompThread << MATLAB_ENV
main = fusion_Inputs($1,$2,$3,$4,[$5 $6])
fusion_Fusion(main)
quit
MATLAB_ENV

echo 'Done!'

# End
