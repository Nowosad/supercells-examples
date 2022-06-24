library(terra)
library(sf)
library(supercells)
library(rgeoda)
library(purrr)
library(tmap)
# create helper functions -------------------------------------------------
scale_01_indepenent = function(x, min_x, max_x){
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}
rast_to_LAB = function(x) {
  x_vals = as.data.frame(x, na.rm = FALSE)
  x2_vals = apply(x_vals, 2, scale_01_indepenent)
  x2_vals = grDevices::convertColor(x2_vals, from = "sRGB", to = "Lab")
  x2 = x
  values(x2) = x2_vals
  return(x2)
}
regionalize_euc = function(k, superpixels, ...){
  weight_df = st_drop_geometry(superpixels[, !colnames(superpixels) %in% c("supercells", "x", "y")])
  rook_w = rook_weights(superpixels)
  skater_results = skater(k, rook_w, weight_df, random_seed = 1, cpu_threads = 1, scale_method = "raw")
  superpixels$cluster = skater_results$Clusters
  regions = aggregate(superpixels, by = list(superpixels$cluster), mean)
  regions = st_cast(regions, "POLYGON")
  regions$k = k
  return(regions)
}

# read scaled time-series of temperature and precipitation ----------------
ta = rast("raw-data/ta_scaled.tif")
pr = rast("raw-data/pr_scaled.tif")

tm_shape(ta) + 
  tm_raster(style = "cont")
tm_shape(pr) + 
  tm_raster(style = "cont")

# extract their first three principal components (PCs) --------------------
ta_pca = prcomp(as.data.frame(ta))
ta_pca_rast = predict(ta, ta_pca)
pr_pca = prcomp(as.data.frame(pr))
pr_pca_rast = predict(pr, pr_pca)
all_rast = c(ta_pca_rast[[1:3]], pr_pca_rast[[1:3]])
names(all_rast) = LETTERS[1:6]
all_pca = prcomp(as.data.frame(all_rast))
all_pca3_rast = predict(all_rast, all_pca)[[1:3]]
all_pca3_rast_lab = rast_to_LAB(all_pca3_rast)

plotRGB(all_pca3_rast_lab, stretch = TRUE) 

# create supercells based on the first three PCs --------------------------
sp = supercells(all_pca3_rast_lab, step = 15, compactness = 0.05)

# create 3, 7, 11, and 15 regions based on the first three PCs ------------
sp_regions = map_dfr(c(3, 7, 11, 15), regionalize_euc, sp)

tm_shape(sp_regions) +
  tm_polygons() +
  tm_facets("k")
