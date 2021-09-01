###
# prep dataset for the carpentry lessons 
# carverd@colostate.edu
# 20210331
### 
#install.packages("rnaturalearthhires", repos = "http://packages.ropensci.org", type = "source")
library(sf)
library(raster)
library(tidyverse)
library(tidycensus)
library(rnaturalearth)
options(tigris_use_cache = TRUE)
baseDir <- "D:/geoSpatialCentroid/softwareCarpentry/intermediateGeospatialR"

#######
## These functions are not really reusable piece of code because that are built to
## run on a specific machine with a known file structure and established series of files. 
## The hope in sharing the functions is to show how the content for this training was 
## developed. Many of the processes can be adapted to your own work. 
#######

### This function was used to pull specific rasters of interest that were used in the 
### the lesson. Because there are both radiance and count images associate with the 
### monthly average this function has a filtering element base on user condition 
grapImages <- function(imageFolder, radiance){
  ## imageFolder - location of files of interest 
  ## radiance - binary value; if true images of radiance are called, else counts 
  ## returns : a vector of full paths to all images of interest 
  if(radiance == TRUE){
    # Process image to texas and resample to 1km cells 
    im <- list.files(path = imageFolder,
                     full.names = TRUE,
                     recursive = TRUE, 
                     pattern = "avg_rade9h.tif")
  }else{
    ### process counts data 
    im <- list.files(path = imageFolder,
                     full.names = TRUE,
                     recursive = TRUE, 
                     pattern = "cf_cvg.tif")
  }
  return(im)
}

stateFips <- "48"

processImagery <- function(outputLocation, images, stateFips, radiance){
  ### clips mask and resamples based on a state boundary
  ###  
  ###
  ###
  # get natural earth data
  admin1 <- rnaturalearth::ne_states()  
  # pull specific state based on used input 
  state <- admin1[grepl(pattern = paste0("US",stateFips),x = admin1$code_local),]
  # define months of the year for image indexing and naming 
  months <- c("january", "feburary", "march", "april", "may", "june", "july","august", "september", "october", "november", "december")
  # read in a template image for CRS information 
  template <- raster::raster(images[1])
  # loop over all images 
  for(i in seq_along(images)){
    # use pattern matching to identify the correct month
    for(j in months){
      if(grepl(pattern = j, x = images[i])){
        m1 <- j
      }
    }
    # process the radiance imagery 
    if(radiance == TRUE){
      r1 <- raster::raster(images[i]) %>% # read in image
        raster::crop(bigTex) %>% # limited extent 
        raster::mask(bigTex) %>% # remove area outside of state
        raster::projectRaster(res = c(0.01666667,0.01666667), 
                              crs = template@crs,
                              method = "bilinear") # resample to 10 arc secs for file size
      raster::writeRaster(x = r1, filename = paste0(outputLocation, "/",m1,"_10arc.tif"))
    }else{# process the counts imagery 
      r1 <- raster::raster(images[i]) %>% # read in image
        raster::crop(bigTex) %>% # limited extent 
        raster::mask(bigTex) %>% # remove area outside of state
        raster::projectRaster(res = c(0.01666667,0.01666667), 
                              crs = template@crs,
                              method = "ngb") # resample to 10 arc secs for file size
      raster::writeRaster(x = r1, filename = paste0(outputLocation, "/",m1,"_10arc_counts.tif"), overwrite = TRUE)
    }
  }
}



### preps county data and census tract data within the county 
countyName <- c("Bexar", "Brazoria","Harris")

# select poverty level 
ct <- tidycensus::load_variables(year = 2015, dataset = "acs5")
write.csv(ct,file = paste0(outputLocation,"/censusVariables.csv"))


processCensus <- function(outputLocation, stateFips, countyName){
  # selects poverty and age demographics at the census track level for all
  #counties of interest within a specific state. 
  # writes out both county and census track spatial features. 
  ### outputLocation : where files will be saved 
  ### countyName : vector of counties within a given state 
  ### tidycensus::census_api_key("you need to apply for one here https://api.census.gov/data/key_signup.html", install = TRUE)
  ### pull counties for texas, get county fips 
  
  # county level shapefile can be found https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html
  cont <- sf::st_read("D:/genericSpatialData/US/counties/tl_2017_us_county.shp")%>%
    dplyr::filter(STATEFP == stateFips & NAME %in% countyName)
  # write out the counties for use later 
  sf::write_sf(cont[], dsn = paste0(outputLocation,"/",stateFips,"_countiesOfInterest.shp"))
  
  # headers within the ACS data
  areas <- tidycensus::get_acs(geography = "tract",
                   variables = c("B01002_001","B17001_002"),
                   state = state$name,
                   county = paste0(countyName," County"),
                   geometry = TRUE)
  ### B01002_001 == median age 
  ### B17001_002 == poverty
  # write out data 
  sf::write_sf(areas, dsn = paste0paste0(outputLocation,"/poverty_age.shp"))
}




