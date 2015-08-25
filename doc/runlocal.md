# The New Fusion
## Run on Local Computer

It is not recommended to run the New Fusion model on your local computer for the following reasons. Remote sensing images usually takes a lot of disk space to store. Input data for a single Landsat scene study site and one year of study time period usually takes about 200GB of disk space, and 400GB of space if you add all the results. Besides, the New Fusion model is computationally intensive. It will accupy a lot of CPU resource of your computer for a relatively long period of time. But in some cases it is still possible to run the model on your local computer. You will need to make sure that you have the [proper environment](installation.md) installed and enough disk space for the input and output data.

#### Initialize Model

Here we assume that you already have prepared all the input data and you have customized your config file. Open a MATLAB session and either add all the codes to your path, or switch the current folder to where you stored all the codes. The first step we need to do is initialize your model:

    matlab >> model = fusion_Inputs('YourConfigFile');
    
The initialization process returns a MATLAB structure that contains all the information that the New Fusion model need for all the following steps, and it will be used as the only input for all following steps. 

#### Run Each Step
The whole fusion process is divided into several steps. You are free to stop in between two steps and continue later. Just keep in mind that everytime you restart a MATLAB session you will need to initialize the model again. To run all the fusion steps, enter the following commands in your MATLAB session, make sure you wither have added the codes to your path or changed your current folder to where you store the codes.

    matlab >> fusion_BRDF(model);       % this step is optional and is not recommended
                                          when running fusion on your local computer
           >> fusion_SwathSub(model);
           >> fusion_Cloud(model);      % you can skip this step if you want to force
                                          the model to use all data.
           >> fusion_Fusion(model);     % if you are applying BRDF corrention
                                          use fusion_BRDFusion instead.
           >> fusion_Dif(model);
           >> fusion_WriteHDF(model);   % this step is optional and is not recommended
                                          when running fusion on your local computer
           >> fusion_WriteETM(model);
           >> fusion_Cache(model);
           >> fusion_Change(model);
           >> fusion_GenMap(model);
