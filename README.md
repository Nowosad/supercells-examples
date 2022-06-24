# Extended SLIC superpixels algorithm for applications to non-imagery geospatial rasters

<!--[![DOI](https://img.shields.io/badge/DOI-10.1007%2Fs10980--020--01135--0-blue)](https://doi.org/10.1007/s10980-020-01135-0)-->

This repository contains the code and data for application examples presented in Nowosad and Stepinski *Extended SLIC superpixels algorithm for applications to non-imagery geospatial rasters*

## Requirements

To reproduce the following case studies, you need to install several R packages.
You can find the packages' installation code in [`R/package-installation.R`](R/package-installation.R).

## Data

1. Fractional land cover data - this example is based on the Copernicus Global Land Service: Land Cover 100m data for the year 2019. 
The study area is about 4200 km2 located in the eastern Netherlands. 
The input data is located in `raw-data/all_ned.tif`.
The original data can be found at https://lcviewer.vito.be/2015.
2. Time-series data - this example is based on the WorldClim 1.4 gridded climate data. 
Data of average monthly temperature and average monthly precipitation was cropped to the area of the island of Great Britain and was normalized to be between 0 and 1.
The input data files are located in `raw-data/ta_scaled.tif` and `raw-data/pr_scaled.tif`.
The original data can be found at https://www.worldclim.org/data/v1.4/worldclim14.html.
3. Pattern data - this example is based on the 30m-resolution raster of the Copernicus GLO-30 Digital Elevation Model.
The study area of ∼38×21 km is located in western Algeria and features a field of dunes; the raster size is 690×1260 cells.
DEM was converted into the same resolution categorical raster of landscape elements using the geomorphon method
The input data files are located in `raw-data/dem30m.tif` and `raw-data/geom_s3.tif`.
The original data can be found at https://doi.org/10.5270/ESA-c5d3d65.

## Application examples

1. Fractional land cover data - [`R/fractional_land_cover_data/large_regions_jsd.R`](R/fractional_land_cover_data/large_regions_jsd.R), [`R/fractional_land_cover_data/large_regions_euclidean.R`](R/fractional_land_cover_data/large_regions_euclidean.R), [`R/fractional_land_cover_data/small_regions_jsd.R`](R/fractional_land_cover_data/small_regions_jsd.R), [`R/fractional_land_cover_data/small_regions_euclidean.R`](R/fractional_land_cover_data/small_regions_euclidean.R)
2. Time-series data - [`R/time-series_data/climate_euc.R`](R/time-series_data/climate_euc.R) and [`R/time-series_data/climate_dtw.R`](R/time-series_data/climate_dtw.R)
3. Pattern data - [`R/pattern_data/dunes.R`](R/pattern_data/dunes.R)