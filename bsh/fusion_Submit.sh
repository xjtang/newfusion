#!/bin/bash

# Launch Matlab in Bash and run Fusion.

matlab -nodisplay -nojvm -singleCompThread << MATLAB_ENV
cd ../
main = fusion_Inputs('$1','$2',$3,$4,$5,[$6 $7])
fusion_BRDF(main)
fusion_SwathSub(main)
fusion_Fusion(main)
fusion_BRDFusion(main)
fusion_WriteHDF(main)
quit
MATLAB_ENV

echo 'Done!'

# End
