## PirateWeather API

Weather forecasts are is primarily found using models run by goverment agencies, but the outputs aern't easy to use or in formats built for web hosting.

To try to address this, I've put together a service that reads weather forecasts and serves it following the [Dark Sky API](https://web.archive.org/web/20200723173936/https://darksky.net/dev/docs) style. Key details about setup/ usage of the API are on the main website <https://pirateweather.net/>, but I also wanted to give an overview of how I assembled all the pieces. I used a ton of online guides during this process, so wanted to try to help someone else here! 

### Source Models 

* HRRR
* NAM
* GFS
