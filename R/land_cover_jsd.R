library(supercells)
library(rgeoda)
library(terra)
library(sf)
library(regional)
# read input multidimensional raster data ---------------------------------
input_raster = rast("raw-data/all_ned.tif")
plot(input_raster)

# create superpixels ------------------------------------------------------
superpixels = supercells(x = input_raster, step = 15, compactness = 0.1,
                         dist_fun = "jensen-shannon", minarea = 12)

# prepare skater regionalization ------------------------------------------
weight_df = st_drop_geometry(superpixels[, !colnames(superpixels) %in% c("supercells", "x", "y")])
weight_dist = philentropy::distance(weight_df, method = "jensen-shannon", as.dist.obj = TRUE)
weight_dist = as.vector(weight_dist)
rook_w = rook_weights(superpixels)

# perform skater regionalization ------------------------------------------
skater_results = skater(468, rook_w, weight_df,
                        random_seed = 1, cpu_threads = 1,
                        rdist = weight_dist)

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

# > weighted.mean(regions$inh, regions$area_km2)
# [1] 0.1367045
# > mean(regions$iso)
# [1] 0.4767688