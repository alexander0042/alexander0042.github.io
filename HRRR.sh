#!/bin/sh

wget -O /grib/fcst.grib 'https://nomads.ncep.noaa.gov/cgi-bin/filter_hrrr_2d.pl?file=hrrr.t00z.wrfsfcf00.grib2&lev_10_m_above_ground=on&lev_2_m_above_ground=on&lev_surface=on&var_APCP=on&var_CFRZR=on&var_CICEP=on&var_CRAIN=on&var_CSNOW=on&var_DPT=on&var_GUST=on&var_PRATE=on&var_PRES=on&var_RH=on&var_TMP=on&var_UGRD=on&var_VGRD=on&var_VIS=on&leftlon=0&rightlon=360&toplat=90&bottomlat=-90&dir=%2Fhrrr.20200717%2Fconus'
wgrib2 /grib/fcst.grib -match ':CFRZR:' -csv /grib/fcstCFRZR00.csv; (awk -F',' '{print \$5\",\"\$6\",\"\$7}' /grib/fcstCFRZR00.csv)>/grib/outCFRZR00.csv
rm -rf /grib/fcstCFRZR00.csv

wgrib2 /grib/fcst.grib -match ':CRAIN:' -csv /grib/fcstCRAIN00.csv
(awk -F',' '{print \$7}' /grib/fcstCRAIN00.csv)>/grib/outCRAIN00.csv
rm -rf /grib/fcstCRAIN00.csv

wgrib2 /grib/fcst.grib -match ':VIS:' -csv /grib/fcstVIS00.csv
(awk -F',' '{print \$7}' /grib/fcstVIS00.csv)>/grib/outVIS00.csv
rm -rf /grib/fcstVIS00.csv

wgrib2 /grib/fcst.grib -match ':CSNOW:' -csv /grib/fcstCSNOW00.csv
(awk -F',' '{print \$7}' /grib/fcstCSNOW00.csv)>/grib/outCSNOW00.csv
rm -rf /grib/fcstCSNOW00.csv

wgrib2 /grib/fcst.grib -match ':PRATE:' -csv /grib/fcstPRATE00.csv
(awk -F',' '{print \$7}' /grib/fcstPRATE00.csv)>/grib/outPRATE00.csv
rm -rf /grib/fcstPRATE00.csv

wgrib2 /grib/fcst.grib -match ':TMP:2 m above ground:' -csv /grib/fcstTMP00.csv
(awk -F',' '{print \$7}' /grib/fcstTMP00.csv)>/grib/outTMP00.csv
rm -rf /grib/fcstTMP00.csv

wgrib2 /grib/fcst.grib -match ':UGRD:10 m above ground:anl:' -csv /grib/fcstUGRD00.csv
(awk -F',' '{print \$7}' /grib/fcstUGRD00.csv)>/grib/outUGRD00.csv
rm -rf /grib/fcstUGRD00

wgrib2 /grib/fcst.grib -match ':VGRD:10 m above ground:anl:' -csv /grib/fcstVGRD00.csv
(awk -F',' '{print \$7}' /grib/fcstVGRD00.csv)>/grib/outVGRD00.csv
rm -rf /grib/fcstVGRD00; wgrib2 /grib/fcst.grib -match ':PRES:' -csv /grib/fcstPRES00.csv
(awk -F',' '{print \$7}' /grib/fcstPRES00.csv)>/grib/outPRES00.csv
rm -rf /grib/fcstPRES00.csv

wgrib2 /grib/fcst.grib -match ':APCP:' -csv /grib/fcstAPCP00.csv
(awk -F',' '{print \$7}' /grib/fcstAPCP00.csv)>/grib/outAPCP00.csv
rm -rf /grib/fcstAPCP00.csv
wgrib2 /grib/fcst.grib -match ':CICEP:' -csv /grib/fcstCICEP00.csv
(awk -F',' '{print \$7}' /grib/fcstCICEP00.csv)>/grib/outCICEP00.csv
rm -rf /grib/fcstCICEP00.csv

wgrib2 /grib/fcst.grib -match ':DPT:' -csv /grib/fcstDPT00.csv
(awk -F',' '{print \$7}' /grib/fcstDPT00.csv)>/grib/outDPT00.csv
rm -rf /grib/fcstDPT00

wgrib2 /grib/fcst.grib -match ':GUST:' -csv /grib/fcstGUST00.csv
(awk -F',' '{print \$7}' /grib/fcstGUST00.csv)>/grib/outGUST00.csv
rm -rf /grib/fcstGUST00.csv

wgrib2 /grib/fcst.grib -match ':RH:' -csv /grib/fcstRH00.csv
(awk -F',' '{print \$7}' /grib/fcstRH00.csv)>/grib/outRH00.csv
rm -rf /grib/fcstRH00.csv

paste -d ',' /grib/outCFRZR00.csv /grib/outCRAIN00.csv /grib/outVIS00.csv /grib/outCSNOW00.csv /grib/outPRATE00.csv /grib/outTMP00.csv /grib/outUGRD00.csv /grib/outVGRD00.csv /grib/outPRES00.csv /grib/outAPCP00.csv /grib/outCICEP00.csv /grib/outDPT00.csv /grib/outGUST00.csv /grib/outRH00.csv> /grib2/merged_hrrr00.csv
