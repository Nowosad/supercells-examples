library(terra)
library(sf)
library(motif)
library(supercells)
library(tmap)

geom = rast("raw-data/geom_s3.tif")
tm_shape(geom) +
  tm_raster(drop.levels = TRUE, title = "Geomorphons:") +
  tm_layout(legend.outside = TRUE)

geom_cove = lsp_signature(geom, type = "cove", window = 5, threshold = 0)
geom_cove = lsp_restructure(geom_cove)
geom_cove = lsp_add_terra(geom_cove)
geom_cove = geom_cove[[-c(1:2)]]
geom_cove

geom_sp = supercells(geom_cove, step = 9, compactness = 0.6, 
                     iter = 4, dist_fun = "jsd")

tm_shape(geom) +
  tm_raster(drop.levels = TRUE, title = "Geomorphons:") +
  tm_shape(geom_sp) +
  tm_borders() +
  tm_layout(legend.outside = TRUE)
