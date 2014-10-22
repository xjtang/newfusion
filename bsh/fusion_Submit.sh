#!/bin/bash

# Launch Matlab in Bash and run Fusion.

# cd $1

matlab -nodisplay -nojvm << MATLAB_ENV
main = fusion_Inputs()
fusion_Fusion(main)
quit
MATLAB_ENV

echo 'Done!'

# End
