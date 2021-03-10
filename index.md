Weather forecasts are primarily found using models run by government agencies, but the outputs aren't easy to use or in formats built for web hosting.
To try to address this, I've put together a service that reads weather forecasts and serves it following the [Dark Sky API](https://web.archive.org/web/20200723173936/https://darksky.net/dev/docs) style. Key details about setup/ usage of the API are on the main website <https://pirateweather.net/>, but I also wanted to give an overview of how I assembled all the pieces. I used many online guides during this process, so wanted to try to help someone else here! 

Before I go any farther, I wanted to add a link to support this project. Running this on AWS means that it scales beautifully and is incredibly reliable, but also costs real money. I'd love to keep this project going long-term, but I'm still paying back my student loans, which limits how much I can spend on this! Anything helps, and a $2 monthly donation lets me raise your API limit from 1,000 calls/ month to 50,000 calls per month.

<a href="https://www.buymeacoffee.com/pirateweather" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>
## Background
This project started from two points: as part of my [PhD](https://coastlines.engineering.queensu.ca/dunexrt), I had to become very familiar with working with NOAA forecast results (<https://orcid.org/0000-0003-4725-3251>)
). Separately, an old tablet set up as a "Magic Mirror,” and was using a [weather module](https://github.com/jclarke0000/MMM-DarkSkyForecast) that relied on the Dark Sky API. So when I heard that it was [shutting down](https://blog.darksky.net/dark-sky-has-a-new-home/), I thought, "I wonder if I could do this.” Plus, I had been looking for a project to learn Python on, so this seemed like a perfect opportunity! 

Spoiler alert, but it was much, much more difficult than I thought, but learned a lot throughout the process, and I think the end result turned out really well! 


### First Attempt- Microsoft Azure
My first attempt at setting this up was on [Microsoft Azure](https://azure.microsoft.com/en-ca/). They had a great [student credit offer](https://azure.microsoft.com/en-ca/free/students/), and running docker containers worked really well. 

However, I ran into issues with data ingest, and couldn't figure out a good way to store the files in a way that I could easily read them later. There is probably a solution to this, but I got distracted with other work and my student credit ran out. Of the three clouds that I tried, I loved the interface, and it had the least complex networking and permission setup! 

### Second Attempt- Google Cloud
My next attempt was to try [Google's Cloud](https://cloud.google.com/). Their BigQuery GIS product looked really interesting, since it handled large georeferenced datasets naturally. Google also stored the weather model data in their cloud already, simplifying data transfer.

What I found was that BigQuery works with point or feature data, and not particularly well with raster (gridded) data. However, it [can be done](https://medium.com/google-cloud/how-to-query-geographic-raster-data-in-bigquery-efficiently-b178b1a5e723) by treating each grid node as a separate point! Then, by running the [st_distance](https://cloud.google.com/bigquery/docs/reference/standard-sql/geography_functions#st_distance) function against each point, it's very easy to find the nearest one. I also optimized this method by [partitioning](https://cloud.google.com/bigquery/docs/partitioned-tables) the globe into sections based on latitude and longitude, which made searches very fast. 

This was all working well, but where this approach broke down was on data ingest. The best way I could find to load data into BigQuery was by saving each grid node as a line on a csv file and importing that. The easiest way was to do this for each forecast time step and then import each step separately and merging them in BigQuery. However, this didn't work, since the [order of the points](https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-csv) does not stay the same. I also tried this with spatial joins, but the costs quickly get prohibitive.

What ended up "working" was merging the csv files, and then uploading that file. This required an incredibly messy bash script, and meant spinning up a VM with a ton of memory and processing in order to make it reasonably fast. So despite this approach almost working, and being very cool (weather maps would have been very easy), I ended up abandoning it. 

## Current Process- AWS 
What ended up working here was discovering the AWS Elastic File System [(EFS)](https://aws.amazon.com/efs/). I wanted to avoid "reinventing the wheel" as much as possible, and there is already a great tool for extracting data from forecast files- [WGRIB2](https://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/)! Moreover, NOAA data was [already being stored](https://registry.opendata.aws/collab/noaa/) on AWS. This meant that, from the 10,000 ft perspective, data could be downloaded and stored on a filesystem that could then be easily accessed by a serverless function, instead of trying to move it to a database.

That is the "one-sentence" explanation of how this is set up, but for more details, read on!

<iframe src="https://app.cloudcraft.co/view/a7efdf8d-2e5d-42aa-a4af-f2580ed530a0?key=reaYW5VNqfox1POlY7AwQw&interactive=true&embed=true" width="375" height="500">
</iframe>

### Data Sources
Starting from the beginning, two NOAA models are used for the raw forecast data: HRRR and GFS.

#### HRRR
The High Resolution Rapid Refresh [(HRRR)](https://rapidrefresh.noaa.gov/hrrr/) provides forecasts over all of the continental US, as well as most of the Canadian population. 15-minute forecasts every 3 km are provided every hour for 18 hours, and every 6 hours a 48-hour forecast is run, all at a 3 km resolution. This was perfect for this project, since Dark Sky provided a minute-by-minute forecast for 1 hour, which can be loosely approximated using the 15-minute HRRR forecasts. HRRR has almost all of the variables required for the API, with the exception of UV radiation and ozone. Personally, this is my favourite weather model, and the one that produced the best results during my thesis research on Hurricane Dorian <https://doi.org/10.1029/2020JC016489>. 

#### GFS
The Global Forecast System [(GFS)](https://www.ncdc.noaa.gov/data-access/model-data/model-datasets/global-forcast-system-gfs) is NOAA's global weather model. Running with a resolution of about 30 km (0.25 degrees), the GFS model provides hourly forecasts out of 120 hours, and 3-hour forecasts out to 240 hours. Here, GFS data is used for anywhere in the world not covered by the HRRR model, and for all results past 48 hours. 

The GFS model also underpins the Global Ensemble Forecast System [(GEFS)](https://www.ncdc.noaa.gov/data-access/model-data/model-datasets/global-ensemble-forecast-system-gefs), which is the 30-member ensemble (the website says 21, but there are 30 data files)  version of the GFS. This means that 30 different "versions" of the model are run, each with slightly starting assumptions. The API uses the GEFS to get precipitation type, quantity, and probability, since it seemed like the most accurate way of determining this. I have no idea how Dark Sky did it, and I am very open to feedback about other ways it could be assigned, since getting the precipitation probability number turned out to be one of the most complex parts of the entire setup! 

#### Others
There are a number of other models that I could have used as part of this API. The Canadian model [(HRDPS)](https://weather.gc.ca/grib/grib2_HRDPS_HR_e.html) is even higher resolution (2.5 km), and seems to do particularly well with precipitation. Also, the [European models](https://www.ecmwf.int/en/forecasts) are sometimes considered better global models than the GFS model is, which would make it a great addition. However, HRRR and GFS were enough to get things working, and since they are stored on AWS already, there were no data transfer costs! 

Forecast data is provided by NOAA in [GRIB2 format](https://en.wikipedia.org/wiki/GRIB). This file type has a steep learning curve, but is brilliant once I realized how it worked. In short, it saves all the forecast parameters, and includes metadata on their names and units. GRIB files are compressed to save space, but are referenced in a way that lets individual parameters be quickly extracted. In order to see what is going on in a GRIB file, the NASA [Panoply](https://www.giss.nasa.gov/tools/panoply/) reader works incredibly well.


### Lambda and WGRIB2 Setup

AWS [Lambda](https://aws.amazon.com/lambda/) allows code to run without requring any underlying server infastructure (*serverless*). In my case, I used Python as the target language, since I was interested in learning it! Once triggered, a Lambda function will run with the configured memory. It can pull data from S3 or the Elastic File System [(EFS)](https://aws.amazon.com/efs/), and can use information passed as part of the trigger. Lambda functions can depend on layers, or supporting code packages. In Python, almost anything that that comes via an `import` line needs to be added as a layer. However, the total size of these layers can't exceed [250 mb](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html), which seems like a lot of space until it isn't. 

For this application, I wanted to use the [WGRIB2](https://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/) application as much as I could, since it has been extensievly optamized for this sort of work. Convinetly enough, [pywgrib2](https://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/pywgrib2.html) was recently released, which is the Python interface for working with WGRIB2 files. I used the [pywgrib2_s](https://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/pywgrib2_s.html) flavour, and then always called it using the `.wgrib2` [method](https://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/pywgrib2_s_wgrib2.html). The package has some interesting tools for reading gribs without having to call the C routines directly (and an xarray version), which would be faster; however, I couldn't get them to work. There are several great [guides](https://wahlnetwork.com/2020/07/28/how-to-create-aws-lambda-layers-for-python/) on how to do this, but in short:

* Create a Python virtual enviorment in an Amazon Linux EC2 instance
* `pip install` the package that's needed
* Zip tht `site-packages` folder
* Import to AWS

There were two magor issues I ran into. One was that running out of space for the layer, which I solved by going through the `site-packages` and removing anything that seemed unnecessary, the testing the function and hoping that everything worked. Particularly with pywgrib2, there were several large test/ documentation/ resources that are not required for every case, so I could get the layer to fit within the limit. The second problem was fixed by adding enviormental variables for `PATH` and `LD_LIBRARY_PATH` pointing to subfolders with important libaries. I also found [this GitHub repo](https://github.com/mthenw/awesome-layers) of helpful Lambda layers, and the [GeoLambda](https://github.com/developmentseed/geolambda) project. GeoLambda *almost* worked for everything, and would have been much easier, but unforuntily didn't leave enough space to install WGRIB2. 

Beyond WGRIB2, I also created layers for [NetCDF4](https://unidata.github.io/netcdf4-python/), [Astral](https://pypi.org/project/astral/), [pytz](https://pypi.org/project/pytz/), and [timezonefinder](https://pypi.org/project/timezonefinder/). 

### Data Ingest

Forecasts are saved from NOAA onto the [AWS Public Cloud](https://registry.opendata.aws/collab/noaa/) into two buckets for the [HRRR](https://registry.opendata.aws/noaa-hrrr-pds/) and [GFS](https://registry.opendata.aws/noaa-gfs-bdp-pds/) models. Each time a new file is added to these buckets, S3 sends a notification using AWS's [SNS](https://aws.amazon.com/sns/?whats-new-cards.sort-by=item.additionalFields.postDateTime&whats-new-cards.sort-order=desc), which triggers a Lambda function. 

This function first checks if the file added to NOAA's bucket (that triggered the function) meets the a list of requirements- there are a lot more files added to the buckets than are needed for weather forecasting, so a regex is used to filter out unnecessary ones. If the grib file is needed, then the function extracts the forecast time and run time (ex. a file for forecast hour 6 from a model run a 18:00 UTC would be T18Z, F006). The grib file is downloaded to the Lambda `/tmp/` directory, then the `-match` [command](https://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/match.html) runs to extract the required parameters (2 m temperature, wind, precipitation type, pressure, visibility, dewpoint, cloud cover, relative humidity, etc.). 

For the HRRR model, the wind directions need to be converted from [grid relative to earth relative](https://github.com/blaylockbk/pyBKB_v2/blob/master/demos/HRRR_earthRelative_vs_gridRelative_winds.ipynb), using the wgrib2 `-new_grid_winds` [command](https://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/new_grid_winds.html). For the GFS model, there are two accumilated precipitation fields (`APCP`), one representing 3 hours of accumilation, and one represeting 0 to the forecast hour. wgrib2 has a `-ncep_norm` [command](https://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/ncep_norm.html); however, it requires that all the time steps are in the same grib file, which isn't how they're saved to the buckets. Instead, I used tip #66 from the (ever handy) [wgrib2 tricks](https://www.ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/tricks.wgrib2) site, and added the `-quit` command to stop wgrib2 from processing the second `APCP` record. 

My complete pywgrib2_s command ended up looking like this:
`pywgrib2_s.wgrib2([download_path, '-new_grid_winds', 'earth', '-new_grid_interpolation', 'neighbor', '-match', matchString, '-new_grid', HRRR_grid1, HRRR_grid2, HRRR_grid3, download_path_GB])`
`pywgrib2_s.wgrib2([download_path, '-rewind_init', download_path, '-new_grid_winds', 'earth', '-new_grid_interpolation', 'neighbor', '-match', 'APCP', '-append','-new_grid', HRRR_grid1, HRRR_grid2, HRRR_grid3, download_path_GB, '-quit'])`
Where `matchString` was the list of parameters, `HRRR_grid1, HRRR_grid2, HRRR_grid3` are the HRRR grid parameters, and `download_path_GB` was the output file location.

Once wgrib2 has run, the function then uploads the processed grib file to my own s3 bucket. Since only the key parameters are included, the bucket size is fairly small (<15 GB), but it does generate a **lot** of `PUT` requests, particularly for the ensemble forecast (240 hours/ 3 hours per forecast step is 80 files, multiplied by 4 model runs per day, multiplied by 30 ensemble members gives 9,600 actions a day, or about 300,000 per month). 

### Data Processing
* POP- ensemble
* WGRIB2 to NetCDF
* In-memory operations
* NetCDF chunking 
* NetCDF compression

### Data Retrieval

* NetCDF read
* Interpolate 
* Calculate other parameters
* Icons
* Sunrise/sunset

### AWS API

* API Gateway 
* Developer Portal

## Next Steps


















 