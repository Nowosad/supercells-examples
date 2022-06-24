library(terra)
library(sf)
library(supercells)
library(rgeoda)
library(purrr)
library(tmap)
# create helper functions -------------------------------------------------
get_dtw2d = function(x){
  dist_mat = matrix(nrow = nrow(x), ncol = nrow(x))
  for (i in seq_len(nrow(x))){
    mat1 = matrix(unlist(x[i, ]), ncol = 2)
    for (j in seq_len(nrow(x))){
      mat2 = matrix(unlist(x[j, ]), ncol = 2)
      dist_mat[i, j] = dtwclust::dtw_basic(mat1, mat2, norm = "L2", step.pattern = dtw::symmetric2)
    }
  }
  stats::as.dist(dist_mat)
}
dtw_2d = function(x, y){
  dtw2ddistance = dtwclust::dtw_basic(x = matrix(x, ncol = 2), y = matrix(y, ncol = 2),
                                      norm = "L2", step.pattern = dtw::symmetric2,
                                      error.check = FALSE)
  return(dtw2ddistance)
}
regionalize_dtw_2d = function(k, superpixels, ...){
  weight_df = st_drop_geometry(superpixels[, !colnames(superpixels) %in% c("supercells", "x", "y")])
  weight_dist = get_dtw2d(weight_df)
  rook_w = rook_weights(superpixels)
  skater_results = skater(k, rook_w, weight_df, random_seed = 1, cpu_threads = 1, scale_method = "raw",
                          rdist = weight_dist)
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

# create supercells based on the 2D time-series ---------------------------
sp = supercells(c(ta, pr), step = 15, compactness = 0.01, dist_fun = dtw_2d)

# create 3, 7, 11, and 15 regions based on the 2D time-series -------------
sp_regions = map_dfr(c(3, 7, 11, 15), regionalize_dtw_2d, sp)

tm_shape(sp_regions) +
  tm_polygons() +
  tm_facets("k")
