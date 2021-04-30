###
# script to call summary html
# 20210428
# carverd@colostate.edu 
### 
install.packages("rmarkdown")
library(rmarkdown)

#set base directory 
baseDir <<- "F:/geoSpatialCentroid/softwareCarpentry/intermediateGeospatialR"

#define input rmd 
inputFile <- paste0(baseDir,"/src/countySummaries.Rmd")

## <<- define a global variable so elements edited here will be observed within the rmd 

# all datasets will be defined in the RMD as relative locations to the baseDir defined here

### select county 
county <<- 
### select Months of interest 
# pass a vector of numbers
months <<- 
### filter levels
filters <<- c(2,6,10)

# generate the file  
rmarkdown::render(inputFile,
                  output_file=paste0("summary_",county))
## or itorate the process 
counties <- c()
for(i in counties){
  county <<- i 
  # generate the file  
  rmarkdown::render(inputFile,
                  output_file=paste0("summary_",county))
}


