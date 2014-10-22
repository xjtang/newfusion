#!/bin/bash

# Launch Matlab in Bash and run Fusion.

matlab -nodisplay -nojvm << MATLAB_ENV
main = fusion_Inputs()
fusion_Fusion(main)
quit
MATLAB_ENV

echo 'Done!'

# End
