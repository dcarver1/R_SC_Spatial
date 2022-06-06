###
# function for cliping and masking rasters
# carverd@colostate.edu 
# 20210331 
###


clipMask2 <- function(raster, extent){
  # raster : a raster object 
  # extent : a spatial feature or extent object 
  if(terra::ext(raster) < terra::ext(extent)){
    print("The raster may be smaller then the extent object")
  }
  if(terra::crs(raster) != terra::crs(extent)){
    return("The crs of the objects to not overlap")
  }else{
    return(raster %>%
      terra::crop(y = extent) %>%
      terra::mask(mask = extent))
  }
}

