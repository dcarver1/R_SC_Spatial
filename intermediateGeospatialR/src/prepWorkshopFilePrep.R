###
# prep dataset for the carpentry lessons 
# carverd@colostate.edu
# 20210331
### 

library(sf)
library(raster)
library(tidyverse)
library(tidycensus)
options(tigris_use_cache = TRUE)
baseDir <- "D:/geoSpatialCentroid/softwareCarpentry/intermediateGeospatialR"

## these function are not really reusable peice of code. I'm mostly using the funtion 
## structure for the storage of the work. That way this script can we much cleaner looking 

### preps night light image to texas 
processImagery<- function(baseDir, radiance){
  if(radiance == TRUE){
    # Process image to texas and resample to 1km cells 
    im <- list.files(path = "F:/geoSpatialCentroid/covidNightLights/data/2019",
                     full.names = TRUE,
                     recursive = TRUE, 
                     pattern = "avg_rade9h.tif")
  }else{
    ### proces counts data 
    im <- list.files(path = "F:/geoSpatialCentroid/covidNightLights/data/2019",
                     full.names = TRUE,
                     recursive = TRUE, 
                     pattern = "cf_cvg.tif")
  }

  

  
  # pull spatial feature for the lone star star 
  bigTex <- sf::st_read("F:/genericSpatialData/US/states/tl_2017_us_state.shp")%>%
    dplyr::filter(NAME == "Texas")
  
  
  output <- paste0(baseDir,"/data/nightLights")
  months <- c("janurary", "feburary", "march", "april", "may", "june", "july","august", "september", "october", "november", "december")
  template <- raster::raster(im[1])
  for(i in seq_along(im)){
    for(j in months){
      if(grepl(pattern = j, x = im[i])){
        m1 <- j
      }
    }
    if(radiance == TRUE){
      r1 <- raster::raster(im[i]) %>% # read in image
        raster::crop(bigTex) %>% # limited extent 
        raster::mask(bigTex) %>% # remove area outside of state
        raster::projectRaster(res = c(0.01666667,0.01666667), 
                              crs = template@crs,
                              method = "bilinear") # resample to 10 arc secs for file size
      raster::writeRaster(x = r1, filename = paste0(output, "/",m1,"_10arc.tif"))
    }else{
      r1 <- raster::raster(im[i]) %>% # read in image
        raster::crop(bigTex) %>% # limited extent 
        raster::mask(bigTex) %>% # remove area outside of state
        raster::projectRaster(res = c(0.01666667,0.01666667), 
                              crs = template@crs,
                              method = "ngb") # resample to 10 arc secs for file size
      raster::writeRaster(x = r1, filename = paste0(output, "/",m1,"_10arc_counts.tif"), overwrite = TRUE)
    }
  }
}



### preps county data and census tract data within the county 
processCensus <- function(){
  # tidycensus::census_api_key("you need to apply for one here https://api.census.gov/data/key_signup.html", install = TRUE)
  
  # pull counties for texas, get county fips 
  countyName <- c("Bexar", "Brazoria","Harris")
  cont <- sf::st_read("D:/genericSpatialData/US/counties/tl_2017_us_county.shp")%>%
    dplyr::filter(STATEFP == 48 & NAME %in% countyName)
  # write out the counties for use later 
  sf::write_sf(cont[], dsn = paste0(baseDir, "/data/counties/countyTex.shp"))
  
  # select poverty level 
  ct <- tidycensus::load_variables(year = 2015, dataset = "acs5")
  write.csv(ct,file = "F:/geoSpatialCentroid/covidNightLights/data/houstonPoverty/censusVariables.csv")
  # headers within the ACS data
  areas <- get_acs(geography = "tract",
                   variables = c("B01002_001","B17001_002"),
                   state = "Texas",
                   county = paste0(countyName," County"),
                   geometry = TRUE)
  ### B01002_001 == median age 
  ### B17001_002 == poverty
  # write out data 
  sf::write_sf(areas, dsn = paste0(baseDir,"/data/census/ageAndPoverty.shp"))
}




