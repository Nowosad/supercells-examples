library(terra)
library(sf)
library(supercells)
library(rgeoda)
library(tmap)

ta = rast("raw-data/ta_scaled.tif")
pr = rast("raw-data/pr_scaled.tif")

clim = c(ta, pr)

sp = supercells(clim, step = 15, compactness = 0.01, dist_fun = dtw_2d)

tm_shape(clim) +
  tm_raster(title = "Values:") +
  tm_facets(nrow = 4) +
  tm_shape(sp) +
  tm_borders()
