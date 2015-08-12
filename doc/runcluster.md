# The New Fusion
## Run on Local Computer

The demonstration here uses the computer cluster od Boston University. Your working environment might be different so please check with your IT support for more details. Running the New Fusion model on computer cluster where you have larger storage and computational capacities is always recommended. You will need a [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) shell to submit jobs to process each step of the fusion process.

You can write your own bash script to run each step or you can also use the [built-in bash scripts](../bsh/). In your Bash shell, you need to change the current folder to where the built-in scripts are stored.

    [bash]$ cd YourFusionProgram/bsh/
    
The script that you should use to submit jobs to run the fusion process. The fusion program will allocate the work equally across jobs. Theoretically you can submit as much jobs as you want. However it is usually limited by the number of available nods and software license that you have on the computer cluster. It is recommended that you use 20-50 jobs to run the New Fusion model on study area of a single Landsat scene. It is fast enough that the whole process should be done within several hours.

Before you run anything, make sure that you have enough disk space and permission to run this project. Also make sure that all the bahs scripts are executable. 

The whole fusion process is divided into several steps. You are free to stop in between two steps and continue later. You will NOT need to initialize the model since the built-in script initializes the model automatically. Here we assume that you already have prepared all the input data and you have customized your config file. The script that you should use is [fusion_Batch.sh](../bsh/fusion_Batch.sh). You will need to specify which step you want to run, the location of your config file, as well as the number of jobs that you want to run:

    [bash]$ ./fusion_Batch.sh FusionStep YourConfigFile NumberOfJobs
    
Since the model is automatically initialized, you don't need to run fusion_Inputs in this case. To run a complete fusion process with 50 jobs, use the following commands:

    [bash]$ ./fusion_Batch.sh fusion_BRDF YourConfigFile 50     # optional
    [bash]$ ./fusion_Batch.sh fusion_SwathSub YourConfigFile 50
    [bash]$ ./fusion_Batch.sh fusion_Fusion YourConfigFile 50   # use fusion_BRDFusion if need BRDF correction
    [bash]$ ./fusion_Batch.sh fusion_Dif YourConfigFile 50
    [bash]$ ./fusion_Batch.sh fusion_WriteHDF YourConfigFile 50 # optional
    [bash]$ ./fusion_Batch.sh fusion_WriteETM YourConfigFile 50 
    [bash]$ ./fusion_Batch.sh fusion_Cache YourConfigFile 50
    [bash]$ ./fusion_Batch.sh fusion_Change YourConfigFile 50
    [bash]$ ./fusion_Batch.sh fusion_GenMap YourConfigFile 1    # ONE job only
    
Note that BRDF correction is optional and does not have significant impact of the result in our test studies. You must wait until the previous step is completely finished before you run the next step. Check the status of the jobs to make sure that they are finished. The last step, fusion_GenMap, can only be processed by one single job.


