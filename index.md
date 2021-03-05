## PirateWeather API

Weather forecasts are is primarily found using models run by goverment agencies, but the outputs aern't easy to use or in formats built for web hosting.

To try to address this, I've put together a service that reads weather forecasts and serves it following the [Dark Sky API](https://web.archive.org/web/20200723173936/https://darksky.net/dev/docs) style. Key details about setup/ usage of the API are on the main website <https://pirateweather.net/>, but I also wanted to give an overview of how I assembled all the pieces. I used a ton of online guides during this process, so wanted to try to help someone else here! 

### Background




### Previous Methods


#### First Attempt- Microsoft Azure




#### Second Attempt- Google Cloud



### Current Process- AWS 

### Data Sources

* HRRR
* HRRR-subH
* GFS
* GFES

#### Data Ingest

* AWS Public Cloud
* SNS Alerts
* pyWGRIB2
* Lambda

#### Data Processing

* POP- ensemble
* WGRIB2 to NetCDF
* In-memory operations
* NetCDF chunking 
* NetCDF compression

#### Data Retrieval

* NetCDF read
* Interpolate 
* Calculate other parameters
* Icons
* Sunrise/sunset

#### AWS API

* API Gateway 
* Developer Portal







































 