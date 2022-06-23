library(supercells)
library(rgeoda)
library(terra)
library(sf)
library(regional)
create_raster_pca = function(x, no_pc = 3){
  pca = prcomp(as.data.frame(x))
  cf_pca = terra::predict(x, pca)
  cf_pca[[1:no_pc]]
}

# read input multidimensional raster data ---------------------------------
input_raster = rast("raw-data/all_ned.tif")
input_raster_pca = create_raster_pca(input_raster)

# create superpixels ------------------------------------------------------
superpixels = supercells(x = input_raster_pca, 
                         step = 15, compactness = 0.2, dist_fun = "euclidean",
                         minarea = 12, transform = "to_LAB")

# prepare skater regionalization ------------------------------------------
weight_df = st_drop_geometry(superpixels[, !colnames(superpixels) %in% c("supercells", "x", "y")])
rook_w = rook_weights(superpixels)

# perform skater regionalization ------------------------------------------
skater_results = skater(468, rook_w, weight_df, random_seed = 1, cpu_threads = 1)

# split clusters into separate polygons -----------------------------------
superpixels$cluster = skater_results$Clusters
regions = aggregate(superpixels, by = list(superpixels$cluster), mean)
regions = st_cast(regions, "POLYGON")

# add average cover fractions ---------------------------------------------
regions_vals = extract(input_raster, vect(regions))
regions_vals = aggregate(regions_vals, by = list(regions_vals$ID), mean)
regions = cbind(regions["cluster"], regions_vals)

# clean data --------------------------------------------------------------
regions$Group.1 = NULL
regions$ID = NULL
regions$cluster = NULL
regions$area_km2 = as.numeric(st_area(regions)) / 1000000

# calculate quality metrics -----------------------------------------------
vars = c("Forest", "Shrubland", "Grassland", "Bare.Sparse.vegatation", 
         "Cropland", "Built.up", "Seasonal.inland.water", "Permanent.inland.water")
regions$inh = reg_inhomogeneity(regions[vars], input_raster, 
                                dist_fun = "jensen-shannon", sample_size = 200)
regions$iso = reg_isolation(regions[vars], input_raster, 
                            dist_fun = "jensen-shannon", sample_size = 200)

weighted.mean(regions$inh, regions$area_km2)
mean(regions$iso)
# > round(weighted.mean(regions$inh, regions$area_km2), 2)
# [1] 0.17
# > round(mean(regions$iso), 2)
# [1] 0.35
