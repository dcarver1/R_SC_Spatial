###
# function for cliping and masking rasters
# carverd@colostate.edu 
# 20210331 
###


clipMask2 <- function(raster, extent){
  # raster : a raster object 
  # extent : a spatial feature or extent object 
  if(raster::extent(raster)< raster::extent(extent)){
    print("The raster may be smaller then the extent object")
  }
  if(!raster::compareCRS(x = raster, y = extent)){
    return("The crs of the objects to not overlap")
  }else{
    return(raster%>%
      raster::crop(y = extent)%>%
      raster::mask(mask = extent))
  }
}

