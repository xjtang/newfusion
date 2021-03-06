# The New Fusion
## Prepare Input Data
Preparingth input data is a key process before you can run the New Fusion model. The quality of the input data is essential to the model results. You only need to prepare data for your study area and study time period, however a minimun study period of 1 year is recommneded. Even if you are just looking for deforestation that happened in the recent 3 months, it is still better if you prepare the data of the past year so that the model can have a more stable initialization. The New Fusion model uses Landsat Synthetic Images as a key input, so your study area should be one single Landsat [WRS2](http://landsat.usgs.gov/worldwide_reference_system_WRS.php) scene or several adjacent scenes.

#### Input Data
The input data can be divided into two groups. The required data is required for all fusion process while the optional data is only needed for specific functions. You will be to run a complete fusion change detection process with only the required data. However utilizing the optional data may give you better results.  

Required Data:  
- MODIS Swath Data ([MOD09](http://modis-sr.ltdri.org/guide/MOD09_UserGuide_v1_3.pdf))
- Landsat Synthetic Images (from [CCDC](http://www.sciencedirect.com/science/article/pii/S0034425714000248))

Optional Data:  
- MODIS BRDF Product ([MCD43A1](https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mcd43a1))
- MODIS Daily Gridded Data ([MOD09GA](https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mod09ga))

#### MODIS Swath Data
The MODIS Terra/Aqua Surface Reflectance 5-minute L2 Swath Data (MOD09) provides MODIS surface reflectance for bands 1 and 2 (at 250m), bands 1 – 7 (at 500 m) and bands 1 – 16 (at 1 km resolution), multiresolution QA, and 1 km observation statistics. The swath data, different from commonly used gridded product, is the un-projected raw scan of the instrument (spectrally processed). It is stored in raster format but each pixel actually covers different sizes of area on the ground. The swath data come withs the location (lat, lon) of the center of each scan.   

The Swath data can be downloaded from the NASA [LAADS](https://ladsweb.nascom.nasa.gov/data/search.html) website. You need to fill out an order indicating your study area and study time period as well as the satellite (Terra/Aqua), collection (5), and product (MOD09) that you are looking for. You will recieve an email once your order is ready for download. Follow the link in the email and download the data that you ordered.  

It is recommended that you download all available swath data for you study area and study time period so that the New Fusion model can build a denser time series and get more accurate results. A single MODIS Swath images covers a very large area comparing to a Landsat scene. In most cases, the same swath will cover all your adjacent Landsat scenes so that you only need to download one set of Swath data even if your study area consists of multiple Landsat scenes.   

#### Landsat Synthetic Images
The Landsat synthetic images are byproduct of the Continuous Change Detection and Classification ([CCDC](http://www.sciencedirect.com/science/article/pii/S0034425714000248)) model. You can find more details about the technical details about the Landsat synthetic images in [this paper](http://www.sciencedirect.com/science/article/pii/S0034425715000590). We will not discuss the details here, the New Fusion model just uses the Landsat synthetic images product as a key input data. The Landsat synthetic images can be produced using the original CCDC program. Another alternative is to use the [YATSM](https://github.com/ceholden/yatsm) model. YATSM is open source, easy to use and there are excellent [documentation](http://ceholden.github.io/yatsm/).

#### Optional Data
MODIS BRDF product (MCD43A1) and MODIS gridded daily product (MOD09GA) are needed to simulate [BRDF](http://www.sciencedirect.com/science/article/pii/S0034425702000913) effect to the predicted MODIS swath. This process is optional and in our current study we haven't found significant improvement in the result by applying BRDF correction.  

Both products can be downloaded from the NASA [LAADS](https://ladsweb.nascom.nasa.gov/data/search.html) website. All available MOD09GA (Daily) and MCD43A1(every 16 days) should be downloaded for the same study area and study time period. Note that both products are stored in the format of MODIS Tile. The New Fusion model only supports single tile analysis for now. If your study area lays in between two MODIS tile, you can not use the BRDF correction feature of the New Fusion model.

#### Organize Data
All MODIS input data should be put into separate folders and keep their original names (e.g. MOD09, MCD43A1).The synthetic image of day xxx year yyyy should be named as "predyyyyxxx" and "predyyyyxxx.hdr". Images of each Landsat scene should be put in separate folder that is names with the path row of the scene (e.g. P227R065). And then all scenes need to be kept in one single folder named "ETMSYN".

You will also need to create one single parent work folder to store all different types of inpur data mentioned above. Your work folder should look like the following example. All the outputs from the New Fusion Model will be saved in this output folder as well. The model will create necessary folders to organize the outputs.

    workfolder/
        ./MOD09/
            ./MOD09.A2013001.1335.005.2015058030428.hdf
              ...
        ./ETMSYN/P227R065/
            ./pred2013070
            ./pred2013070.hdr
              ...
        ./MOD09GA/
            ./MOD09GA.A2013001.h12v09.005.2015077040350.hdf
              ...
        ./MCD43A1/
            ./MCD43A1.A2013001.h12v09.005.2013018090048.hdf
              ...



