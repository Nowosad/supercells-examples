library(terra)
library(sf)
library(motif)
library(supercells)
library(tmap)
# create helper functions -------------------------------------------------
get_k = function(x, k = 2){
  weight = sf::st_drop_geometry(x[, !colnames(x) %in% c("supercells", "x", "y")])
  set.seed(2022-06-07)
  kmeans(weight, k)$cluster
}
scale_values = function(x){
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

# read DEM data -----------------------------------------------------------
dem = rast("raw-data/dem30m.tif")

# create hillshade --------------------------------------------------------
rs = terra::terrain(dem, "slope", unit = "radians")
ra = terra::terrain(dem, "aspect", unit = "radians")
hillshade = shade(rs, ra, angle = 68, direction = 315)

tm_hill = tm_shape(hillshade) +
  tm_raster(palette = gray(0:100 / 100), style = "cont", legend.show = FALSE)
tm_hill

# read geomorphon data ----------------------------------------------------
geom = rast("raw-data/geom_s3.tif")

tm_shape(geom) +
  tm_raster(drop.levels = TRUE, title = "Geomorphons:") +
  tm_layout(legend.outside = TRUE)

# calculate cooccurrence histogram ----------------------------------------
geom_cove = lsp_signature(geom, type = "cove", window = 5, threshold = 0)
geom_cove = lsp_restructure(geom_cove)
geom_cove = lsp_add_terra(geom_cove)
geom_cove = geom_cove[[-c(1:2)]]
geom_cove

# create supercells based on the cooccurrence histogram -------------------
sp = supercells(geom_cove, step = 9, compactness = 0.6, 
                iter = 4, dist_fun = "jsd")
sp$k = get_k(sp, k = 4)

# extract the first three principal components (PCs) ----------------------
pca = prcomp(as.data.frame(geom_cove))
geom_cove_pca = predict(geom_cove, pca)[[1:3]]
geom_cove_pca = scale_values(geom_cove_pca)

tm_shape(geom_cove_pca) +
  tm_rgb(max.value = 1)

# create supercells based on the first three PCs --------------------------
sp_euc = supercells(geom_cove_pca, step = 9, compactness = 1.35, 
                    iter = 4, dist_fun = "euclidean")
sp_euc$k = get_k(sp_euc, k = 4)

# visualize the results ---------------------------------------------------
tm1 = tm_hill +
  tm_shape(sp) +
  tm_borders(col = "red")
tm2 = tm_hill +
  tm_shape(sp_euc) +
  tm_borders(col = "red")
tmap_arrange(tm1, tm2)
