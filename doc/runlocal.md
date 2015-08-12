# The New Fusion
## Run on Local Computer

It is not recommended to run the New Fusion model on your local computer for the following reasons. Remote sensing images usually takes a lot of disk space to store. Input data for a single Landsat scene study site and one year of study time period usually takes about 5GB of disk space, and 10GB of space if you add all the results. Besides, the New Fusion model is computationally intensive. It will accupy a lot of CPU resource of your computer for a relatively long period of time. But in some cases it is still possible to run the model on your local computer. You will need to make sure that you have the [proper environment](installation.md) installed and enough disk space for the input and output data.

#### Initialize Model

Here we assume that you already have prepared all the input data and you have customized your config file. Open a MATLAB session and either add all the codes to your path, or switch the current folder to where you stored all the codes. The first step we need to do is initialize your model:

    matlab >> model = fusion_Inputs('YourConfigFile');
    


#### Run Each Step



####
