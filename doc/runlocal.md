# The New Fusion
## Run on Local Computer

It is not recommended to run the New Fusion model on your local computer for the following reasons. Remote sensing images usually takes a lot of disk space to store. Input data for a single Landsat scene study site and one year of study time period usually takes about 200GB of disk space, and 400GB of space if you add all the results. Besides, the New Fusion model is computationally intensive. It will occupy a lot of CPU resource of your computer for a relatively long period of time. But in some cases it is still possible to run the model on your local computer. You will need to make sure that you have the [proper environment](installation.md) installed and enough disk space for the input and output data.

#### Run Regular Version

Here we assume that you already have prepared all the input data and you have customized your config file. Open a MATLAB session and either add all the codes to your path, or switch the current folder to where you stored all the codes. You can use the [fusion_Run.m](../fusion_Run.m) function to run a specific step of the fusion process with the correct inputs.

    matlab >> model = fusion_Run('YourConfigFile',1,1,'Step');
    
The first input argument is the path to your config file for your project. The second and third input arguments handles parallel jobs. It's usually used for running fusion on computing clusters, so you won't use it here. Just use 1 for both. The fourth input arguments is the step that you are running. The whole fusion process is divided into several steps (e.g. SwathSub, Dif, WriteETM, etc.). You are free to stop in between two steps and continue later as long as you don't change anything in your config file in which case you should rerun all the steps. To run all a complete fusion, enter the following commands in your MATLAB session, make sure you either have added the codes to your path or changed your current folder to where you store the codes.

    matlab >> fusion_Run('YourConfigFile',1,1,'BRDF');      % optional
           >> fusion_Run('YourConfigFile',1,1,'SwathSub');  
           >> fusion_Run('YourConfigFile',1,1,'Cloud');  
           >> fusion_Run('YourConfigFile',1,1,'Fusion');    % BRDFusion if you want BRDF correction
           >> fusion_Run('YourConfigFile',1,1,'Dif');  
           >> fusion_Run('YourConfigFile',1,1,'WriteHDF');  % Optional
           >> fusion_Run('YourConfigFile',1,1,'WriteETM');  
           >> fusion_Run('YourConfigFile',1,1,'Cache');  
           >> fusion_Run('YourConfigFile',1,1,'Change');  
           >> fusion_Run('YourConfigFile',1,1,'GenMap');  

#### Run Compiled Version

It is possible to run the standalone compiled version of fusion. Depending on what system you are using you might have to recompile the model using [compile.m](../compile.m). Make sure you have MATLAB Compiler Runtime ([MCR](http://www.mathworks.com/products/compiler/mcr/)) installed. You can run your compiled version in command line using the same input parameters as the regular version.

    >> YourCompiledVersion YourConfigFile 1 1 Step
